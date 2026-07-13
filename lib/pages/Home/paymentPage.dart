// lib/pages/PaymentPage.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:my_mam_app/stores/PaymentController.dart';

class PaymentPage extends StatelessWidget {
  // 🎯 수정: Named 라우트 연동을 위해 생성자 파라미터를 제거합니다.
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎯 수정: Get.arguments로부터 이전 화면이 던져준 데이터를 안전하게 꺼냅니다.
    final Map<String, dynamic> args = Get.arguments ?? {"amount": 0, "orderName": "결제 상품"};
    final int amount = args["amount"] ?? 0;
    final String orderName = args["orderName"] ?? "결제 상품";
    final String billingId = args["billingId"];
    final String custName = args["custName"];
    final String custMobile = args["custMobile"];
    final String custEmail = args["custEmail"];
    final controller = Get.put(PaymentController());
    // 페이지가 열릴 때 안전하게 초기화 함수 예약 실행
    controller.initTossWidget(amount: amount);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "주문 결제",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        PaymentMethodWidget(paymentWidget: controller.paymentWidget, selector: 'methods'),
                        AgreementWidget(paymentWidget: controller.paymentWidget, selector: 'agreement'),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.isWidgetInitialized.value
                            ? () => controller.actionRequestPayment(
                                amount: amount,
                                orderName: orderName,
                                customerName: custName,
                                customerEmail: custEmail,
                                uniqueOrderId: billingId,
                              )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0053EA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "$amount원 결제하기",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (!controller.isWidgetInitialized.value)
                Container(
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFF785186))),
                ),

              if (controller.isLoadingApprove.value)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
            ],
          );
        }),
      ),
    );
  }
}
