// lib/stores/PaymentController.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/api/payment.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';

class PaymentController extends GetxController {
  late PaymentWidget paymentWidget; // 👈 나중에 객체가 담길 변수 공간

  var isWidgetInitialized = false.obs; // 반응형 로딩 상태 변수
  var isLoadingApprove = false.obs; // 자바 서버 승인 대기 상태 변수

  /// 토스 결제위젯 및 약관 초기화 프로세스
  void initTossWidget({required int amount}) async {
    try {
      isWidgetInitialized.value = false;

      // 1. 위젯 객체 생성
      paymentWidget = PaymentWidget(
        clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
        customerKey: "csUEdI4ylmuNQc2ISkma2",
      );

      // ⭐️ [UI 스레드 부하 분산]:
      // addPostFrameCallback 직후에 바로 실행하지 않고, 메인 스레드가
      // 화면 전환 애니메이션을 안전하게 끝낼 수 있도록 미세한 딜레이를 부여합니다.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        _startRenderingSafe(amount);
      });
    } catch (e) {
      Get.snackbar("오류", "결제 모듈을 불러오는 중 실패했습니다.");
    }
  }

  /// 메인 스레드를 가독성 있게 나누어 처리하는 안전한 렌더링 메서드
  void _startRenderingSafe(int amount) async {
    try {
      // 1. 결제 수단 UI 렌더링
      await paymentWidget.renderPaymentMethods(
        selector: 'methods',
        amount: Amount(value: amount, currency: Currency.KRW, country: "KR"),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // 2. 약관 UI 렌더링
      await paymentWidget.renderAgreement(selector: 'agreement');

      // 3. 성공 시에만 로딩 해제
      isWidgetInitialized.value = true;
    } catch (e) {
      // 로그에 찍힌 "Instance of 'Fail'" 캐치 처리
      print("토스 내부 위젯 렌더링 실패 에러 상세: $e");

      isWidgetInitialized.value = false;

      // 사용자에게 명확하게 에러 공지 후 페이지 나가기 또는 재시도 유도
      Get.defaultDialog(
        title: "결제 모듈 오류",
        middleText: "결제위젯 인증에 실패했습니다.\n상점 키(Client Key) 설정을 확인해주세요.",
        textConfirm: "확인",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // 결제 페이지 이탈
        },
      );
    }
  }

  /// 결제창 호출 및 자바 서버 검증 처리
  Future<void> actionRequestPayment({
    required int amount,
    required String orderName,
    required String customerName,
    required String customerEmail,
    required String uniqueOrderId,
  }) async {
    try {
      // final String uniqueOrderId = "order_${DateTime.now().millisecondsSinceEpoch}";

      // 1. 토스 결제창 실행
      final paymentResult = await paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: uniqueOrderId, // 필수: 가맹점에서 생성한 고유 주문번호
          orderName: orderName, // 필수: 결제할 상품명
          customerEmail: customerEmail, // 선택: 구매자 이메일
          customerName: customerName, // 선택: 구매자 이름
          appScheme: 'mymamapp://', // 선택: 앱 복귀용 스킴
        ),
      );

      // 2. 결과 후처리
      if (paymentResult.success != null) {
        final successData = paymentResult.success!;

        isLoadingApprove.value = true;
        // 3. ⭐️ Java 백엔드 서버에 승인 요청 API 호출
        bool isApproveSuccess = await PaymentApi.verifyAndApprovePayment(
          paymentKey: successData.paymentKey,
          orderId: successData.orderId,
          amount: successData.amount.toInt(),
        );
        isLoadingApprove.value = false;

        if (isApproveSuccess) {
          Get.defaultDialog(
            title: "결제 완료",
            middleText: "청구서 결제가 정상 완료되었습니다.",
            onConfirm: () => Get.offAllNamed('/home'), // 홈으로 이동하여 새로고침 유도
          );
        } else {
          Get.snackbar("서버 에러", "토스 결제는 성공했으나 상점 서버 승인에 실패했습니다. 고객센터에 문의하세요.");
        }
      } else if (paymentResult.pending != null) {
        Get.snackbar("대기", "해외 간편결제 승인 대기 중입니다.");
      } else if (paymentResult.fail != null) {
        Get.snackbar("결제 실패", "${paymentResult.fail?.errorMessage}");
      }
    } catch (e) {
      Get.snackbar("에러", "결제 요청 중 알 수 없는 문제가 발생했습니다.");
    }
  }
}
