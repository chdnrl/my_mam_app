import 'package:dio/dio.dart';
import 'dart:io'; // 💡 필수: NetworkInterface 및 Platform 사용을 위해 반드시 필요합니다!
import 'package:device_info_plus/device_info_plus.dart'; // 💡 필수: 기기 정보 추출을 위한 패키지

/// 🌐 현재 스마트폰 기기의 공인 IP 주소를 반환하는 헬퍼 펑션
/// // [방법 1] 외부 파일에 선언된 공인 IP 에코 API 호출 방식 (현재 활성화)
// 전 세계 어디서든 유저가 접속한 실제 외부 '공인 IP'를 완벽하게 따옵니다.
Future<String> getClientIpAddress() async {
  try {
    // 전 세계적으로 사용되는 IP 에코 서비스 인프라 이용
    final response = await Dio().get('https://api.ipify.org?format=json');
    if (response.statusCode == 200) {
      return response.data['ip']?.toString() ?? "127.0.0.1";
    }
  } catch (e) {
    print("⚠️ [IP 획득 실패] 로컬 가상 루프백 IP로 대체합니다: $e");
  }
  return "127.0.0.1"; // 통신 실패나 오프라인 시 방어선 기본값
}

// ---------------------------------------------------------------------------
// 💡 [방법 2 - 주석 처리됨] 기기 내부 네트워크 인터페이스 기반 사설 IP 추출 함수
// ---------------------------------------------------------------------------
// Future<String> getInternalIpAddress() async {
//   try {
//     for (var interface in await NetworkInterface.list()) {
//       for (var addr in interface.addresses) {
//         if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
//           return addr.address;
//         }
//       }
//     }
//   } catch (_) {}
//   return "127.0.0.1";
// }

/// 🛰️ [신규 추가] Java 백엔드 전송용 기기 사양 정보 동적 추출 함수
Future<String> getMobileDeviceInfo() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // 출력 예시: "ANDROID_Samsung_SM-G991N_SDK_33"
      return "ANDROID_${androidInfo.manufacturer}_${androidInfo.model}_SDK_${androidInfo.version.sdkInt}";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // 출력 예시: "IOS_iPhone 14 Pro_v16.4"
      return "IOS_${iosInfo.name}_${iosInfo.model}_v${iosInfo.systemVersion}";
    }
  } catch (e) {
    print("⚠️ 기기 정보 추출 실패 (기본값 대체): $e");
  }
  return "FLUTTER_MOBILE_DEVICE"; // 예외 발생 시 서버 장애 방지용 fallback 기본값
}
