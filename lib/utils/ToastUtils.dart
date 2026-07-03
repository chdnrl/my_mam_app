import 'package:flutter/material.dart';

class ToastUtils {
  // 阀门控制
  static bool showLoading = false;
  static void showToast(BuildContext context, String? msg) {
    if (ToastUtils.showLoading) {
      return;
    }
    ToastUtils.showLoading = true;
    Future.delayed(Duration(seconds: 3), () {
      ToastUtils.showLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 180,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          // borderRadius: BorderRadiusGeometry.circular(40),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        content: Text(msg ?? "성공", textAlign: TextAlign.center),
      ),
    );
  }

  static void showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    // 기존에 떠 있는 스낵바가 있다면 즉시 제거
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            (isError ? const Color(0xFFF05656) : const Color(0xFF785186))
                .withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        duration: const Duration(seconds: 2), // 2초 후 자동 사라짐
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 10, // 기기 하단 여백 대응
        ),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
