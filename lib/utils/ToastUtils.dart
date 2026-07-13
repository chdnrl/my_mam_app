import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/utils/AppMessages.dart';

class ToastUtils {
  static bool showLoading = false;

  // 🎯 [수정] context 안전검사 장치 및 GetX 백업 시스템 가동
  static void showServerResponseSnackBar(BuildContext context, {required String status, String? serverMessage}) {
    // 1. 매핑 파일로부터 최종 사용자 출력 문구 획득
    final String finalMessage = AppMessages.getMessage(status, serverCustomMessage: serverMessage);

    // 2. 상태 코드에 따른 성공/실패 여부(색상 판단용) 획득
    final bool isError = AppMessages.checkIsError(status);

    // 3. 💡 [핵심] 현재 위젯 화면이 살아있는지 안전성 검사
    if (Navigator.of(context).mounted) {
      // 화면이 정상적이라면 기존에 잘 만들어두신 커스텀 스낵바 호출
      showCustomSnackBar(context, finalMessage, isError: isError);
    } else {
      // 🚨 만약 컨텍스트가 죽었다면(Unmounted), GetX 전역 엔진을 사용해 컨텍스트 없이 스낵바 강제 출력!
      Get.rawSnackbar(
        messageText: Text(
          finalMessage,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
        backgroundColor: (isError ? const Color(0xFFF05656) : const Color(0xFF785186)).withOpacity(0.8),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        borderRadius: 8,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
  // 🎯 [새로 추가] API 결과를 던져주면 한글 매핑 파일과 결합해 자동으로 스낵바를 띄우는 공통 메서드
  // static void showServerResponseSnackBar(BuildContext context, {required String status, String? serverMessage}) {
  //   // 1. 매핑 파일로부터 최종 사용자 출력 문구 획득
  //   final String finalMessage = AppMessages.getMessage(status, serverCustomMessage: serverMessage);

  //   // 2. 상태 코드에 따른 성공/실패 여부(색상 판단용) 획득
  //   final bool isError = AppMessages.checkIsError(status);

  //   // 3. 기존에 잘 만들어두신 기존 커스텀 스낵바 호출 로직으로 전달하여 출력
  //   showCustomSnackBar(context, finalMessage, isError: isError);
  // }

  // ------------------------------------------------------------
  // 🔒 아래는 기존에 사용하시던 코드 그대로 유지 (수정 없음)
  // ------------------------------------------------------------
  static void showToast(BuildContext context, String? msg) {
    if (ToastUtils.showLoading) return;
    ToastUtils.showLoading = true;
    Future.delayed(Duration(seconds: 3), () {
      ToastUtils.showLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 180,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        content: Text(msg ?? "성공", textAlign: TextAlign.center),
      ),
    );
  }

  static void showCustomSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: (isError ? const Color(0xFFF05656) : const Color(0xFF785186)).withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 10),
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
