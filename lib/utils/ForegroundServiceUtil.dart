import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:web_socket_channel/io.dart';

// ⚠️ 주의: 반드시 최상위(Top-level) 함수여야 포그라운드 서비스가 인식합니다.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(CradleTaskHandler());
}

class ForegroundServiceUtil {
  // 포그라운드 서비스 초기화 설정
  static Future<void> initService() async {
    // FlutterForegroundTask.init은 void 함수이므로 앞에 'await'를 제거하여 컴파일 에러를 해결합니다.
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'mymam_cradle_channel',
        channelName: '마이맘 실시간 케어',
        channelDescription: '스마트 크래들 및 가족 모드 실시간 감지 서비스',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
      ),
    );
  }
}

// 백그라운드 단독 격리 공간(Isolate)에서 Java 서버와 24시간 소통할 핸들러
class CradleTaskHandler extends TaskHandler {
  IOWebSocketChannel? _channel;

  // [수정] 최신 패키지 명세에 따라 TaskNotification 대신 TaskStarter로 수정되었습니다.
  // [교정] 리턴 타입을 void에서 Future<void>로 명확하게 일치시켜 override 에러를 해결합니다.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    print("🚀 포그라운드 서비스 백그라운드 격리단 시작");

    try {
      // 본인의 Java Spring Boot WebSocket 서버 주소 입력
      _channel = IOWebSocketChannel.connect(
        Uri.parse('ws://192.168.0.10:8080/ws/cradle'),
      );

      _channel!.stream.listen(
        (message) {
          // Java 서버에서 온 실시간 데이터를 메인 UI 앱단(GetX 쪽)으로 던짐
          FlutterForegroundTask.sendDataToMain(message);
        },
        onError: (error) {
          print("소켓 에러 발생: $error");
        },
        onDone: () {
          print("소켓 연결 종료");
        },
      );
    } catch (e) {
      print("Java 서버 연결 실패: $e");
    }
  }

  // [수정] 최신 패키지 명세에 따라 파라미터가 DateTime 하나만 받도록 변경되었습니다.
  // [교정] 최신 스펙 명세에 맞춰 리턴 형식을 명확히 해줍니다.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // 주기적 타이머 작업이 필요 없다면 비워둡니다.
  }

  // [수정] 최신 패키지 명세에 따라 TaskNotification 대신 bool 타입을 받으며 Future<void>를 반환합니다.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isUserAction) async {
    print("🛑 포그라운드 서비스 백그라운드 격리단 종료");
    await _channel?.sink.close();
  }

  @override
  void onReceiveData(Object data) {
    // 메인 앱(GetX UI단)에서 '원격 제어 명령'을 보냈을 때 수신하여 Java 서버로 토스
    print("백그라운드가 UI단으로부터 명령 수신: $data");
    _channel?.sink.add(data.toString());
  }
}
