import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:my_mam_app/routes/index.dart';
import 'package:my_mam_app/stores/TokenManager.dart';
import 'package:my_mam_app/stores/UserController.dart';
import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/utils/ForegroundServiceUtil.dart';

Future<void> main(List<String> args) async {
  // [추가] 비동기 플러그인 초기화를 위해 필수적으로 선언해야 합니다.
  WidgetsFlutterBinding.ensureInitialized();
  // 💡 [v9.x 필수] TaskHandler와 메인 UI Isolate 간의 통신 포트를 초기화합니다.
  FlutterForegroundTask.initCommunicationPort();

  // [추가] 이전에 utils 폴더에 정의했던 포그라운드 서비스 기본 환경 세팅
  await ForegroundServiceUtil.initService();
  //완전히 꺼졌다가 켤 때 자동 로그인 처리하기
  String initialRoute = "/login"; // 기본값은 로그인 페이지

  // 1. 유저 상태를 관리할 컨트롤러를 먼저 메모리에 올립니다. (서버 조회 메서드 사용을 위함)
  final userController = Get.put(UserController());
  // --------------------------------------------------------------------
  // 💾 [로그인 유지 로직 핵심 추가]
  // 앱이 완전히 껐다 켜질 때 로컬에 저장된 토큰이 있다면 쿠키를 자동으로 복원합니다.
  // --------------------------------------------------------------------
  try {
    String savedToken = await tokenManager.getToken();

    if (savedToken.isNotEmpty) {
      // 이전에 DioRequest 내부에 만들어둔 setAuthCookie 함수 호출
      dioRequest.setAuthCookie(savedToken);

      await userController.fetchUserInfo();
      initialRoute = "/home";
    } else {
      // print("🔐 [자동 로그인] 저장된 토큰이 없어 로그인 페이지 상태로 진입합니다.");
    }
  } catch (e) {
    // print("⚠️ [자동 로그인 오류] 토큰을 복원하는 중 에러가 발생했습니다: $e");
    initialRoute = "/login";
  }
  // --------------------------------------------------------------------
  // Get.put(UserController());
  // 💡 [핵심] 안드로이드 시스템 하단바(소프트키 영역)를 완전히 투명하게 선언합니다.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상단 바 투명
      systemNavigationBarColor: Colors.transparent, // 하단 네비게이션 바 투명
      systemNavigationBarIconBrightness: Brightness.dark, // 하단 소프트키 아이콘 색상 (어둡게/검은색 삼각·원·네모)
      systemNavigationBarDividerColor: Colors.transparent, // 네비게이션 바 경계선 투명
    ),
  );
  // 💡 [핵심] 앱의 레이아웃 영역을 기기의 실제 물리적인 화면 최하단 끝까지 확장(Edge-to-Edge)합니다.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // runApp
  runApp(getRootWidget("/home"));
  //완전히 꺼졌다가 켤 때 자동 로그인 처리하기
  // 🎯 runApp 호출 시 initialRoute 경로를 넘겨줍니다.
  // runApp(getRootWidget(initialRoute));
}
