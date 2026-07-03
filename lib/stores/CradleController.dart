import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/api/cradle.dart';
import 'package:my_mam_app/viewmodels/cradle.dart';
import 'package:video_player/video_player.dart';
import 'package:my_mam_app/utils/ForegroundServiceUtil.dart';

class CradleController extends GetxController with WidgetsBindingObserver {
  static CradleController get to => Get.find();

  // 🎯 [융합] 질문하신 CradleData 인스턴스를 컨트롤러 멤버로 등록합니다.
  // 이제 UI(View)단에서는 controller.cradleData.temp.value 형태로 실시간 접근이 가능합니다.
  final CradleData cradleData = CradleData();

  // 가족 모드 및 원격 제어 상태 변수들
  var isCradleRocking = false.obs;
  var activeFamilyMembers = <String>[].obs;

  // 🎥 HLS 스트리밍 제어 상태 변수들
  VideoPlayerController? videoPlayerController;
  var isVideoInitialized = false.obs;
  var isVideoLoading = true.obs;
  String hlsUrl = "";

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // 1. 백그라운드 소켓 리스너 가동
    _startListeningTaskData();

    // 2. 포그라운드 서비스 알림창 띄우기
    startCradleForegroundService();

    // 3. 앱 구동 시 공통 DioRequest 엔진을 거쳐 영상 HLS 주소 받아오기 (테스트 아기ID: "1")
    fetchHlsStreamUrl("1");
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskDataReceived);
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// [API 호출] 수정이 필요 없는 전역 dioRequest를 활용해 영상 주소를 받아오는 축
  Future<void> fetchHlsStreamUrl(String babyId) async {
    try {
      isVideoLoading.value = true;
      isVideoInitialized.value = false;

      // 수정 없는 DioRequest 인터셉터 덕분에 쿠키(mymam-auth)가 자동 세팅되어 요청됩니다.
      final responseData = await cradleApi.fetchCradleStreamUrl(babyId);

      if (responseData != null && responseData.containsKey('hlsUrl')) {
        hlsUrl = responseData['hlsUrl'].toString();
        print("🔗 [성공] 안전 인증된 HLS 비디오 경로 획득: $hlsUrl");

        await _initializeHlsPlayer(hlsUrl);
      } else {
        throw Exception("영상 주소 필드(hlsUrl) 누락");
      }
    } catch (e) {
      print("❌ HLS 스트리밍 URL 최종 조회 실패: $e");
      Get.snackbar("영상 오류", "실시간 크래들 스트리밍 주소를 불러오지 못했습니다.");
      isVideoLoading.value = false;
    }
  }

  /// HLS 동영상 플레이어 엔진 가동 헬퍼
  Future<void> _initializeHlsPlayer(String url) async {
    try {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoPlayerController!.initialize();

      isVideoInitialized.value = true;
      isVideoLoading.value = false;
      videoPlayerController!.play();
      videoPlayerController!.setLooping(true);
    } catch (e) {
      print("❌ 비디오 플레이어 초기화 에러: $e");
      isVideoLoading.value = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      sendControlCommand('{"command": "REFRESH_DATA"}');
      if (videoPlayerController != null && isVideoInitialized.value) {
        videoPlayerController!.play();
      }
    }
  }

  void startCradleForegroundService() async {
    if (await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.startService(
      notificationTitle: '마이맘 스마트 케어',
      notificationText: '아기 상태 및 가족 연결을 실시간 감지 중입니다.',
      callback: startCallback,
    );
  }

  void stopCradleForegroundService() async {
    await FlutterForegroundTask.stopService();
  }

  void _startListeningTaskData() {
    FlutterForegroundTask.addTaskDataCallback(_onTaskDataReceived);
  }

  /// 📥 백그라운드(Java 소켓) 실시간 데이터 파싱 및 가공
  void _onTaskDataReceived(Object data) {
    print("📩 [CradleController] 백그라운드 수신 데이터: $data");

    try {
      final Map<String, dynamic> decodedData = jsonDecode(data.toString());

      // 🎯 [연동 완료] 소켓에서 실시간 센서 데이터가 수신되면,
      // 질문하신 cradleData 내부의 updateFromApi() 함수로 토스하여 Rx 변수들을 일괄 동기화합니다.
      cradleData.updateFromApi(decodedData);

      // 2. 가족 원격 제어 상태 실시간 업데이트
      if (decodedData.containsKey('command')) {
        String command = decodedData['command'];
        if (command == "ROCKING_ON") {
          isCradleRocking.value = true;
        } else if (command == "ROCKING_OFF") {
          isCradleRocking.value = false;
        }
      }

      // 3. 현재 접속자 명단 업데이트
      if (decodedData.containsKey('familyList')) {
        final List<dynamic> list = decodedData['familyList'];
        activeFamilyMembers.value = list.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print("❌ 수신 데이터 파싱 에러: $e");
    }
  }

  void sendControlCommand(String jsonStringAction) {
    FlutterForegroundTask.sendDataToTask(jsonStringAction);
  }

  void toggleCradleRocking() {
    final String command = isCradleRocking.value
        ? '{"command": "STOP_ROCKING"}'
        : '{"command": "START_ROCKING"}';
    sendControlCommand(command);
  }
}
