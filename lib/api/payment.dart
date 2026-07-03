// lib/api/PaymentApi.dart
import 'package:my_mam_app/utils/DioRequest.dart'; // 기존에 구현된 전역 dioRequest 엔진 가정

class PaymentApi {
  /// 토스 결제 성공 후, Java 백엔드 서버에 최종 결제 승인 요청 및 DB 저장
  static Future<bool> verifyAndApprovePayment({
    required String paymentKey,
    required String orderId,
    required int amount,
  }) async {
    try {
      // 자바 컨트롤러 백엔드로 POST 요청 (DioRequest 가공 처리기 통과)
      final response = await dioRequest.post(
        "/cradle/payment/approve",
        data: {"paymentKey": paymentKey, "orderId": orderId, "amount": amount},
      );

      // 자바에서 status: 200 구조로 오면 dioRequest가 result 영역만 파싱해서 반환함
      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      print("자바 서버 결제 승인 에러: $e");
      return false;
    }
  }
}
