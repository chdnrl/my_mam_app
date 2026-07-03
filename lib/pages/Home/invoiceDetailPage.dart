import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_mam_app/pages/Home/paymentPage.dart';
import 'package:my_mam_app/pages/Home/receiptDetailPage.dart';

class InvoiceDetailPage extends StatelessWidget {
  // 💡 명명된 라우트(Get.toNamed) 전환을 위해 생성자 필드를 제거하거나 기본값 처리합니다.
  const InvoiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    // 🎯 [수정] Get.arguments에서 넘겨받은 Map 데이터를 추출합니다.
    // 이전 화면에서 인자를 깜빡하고 안 보냈을 때를 대비해 안전하게 기본값(??)을 매핑합니다.
    final Map<String, dynamic> args =
        Get.arguments ?? {"isPaidMode": false, "testType": 1};

    final bool isPaidMode = args["isPaidMode"] ?? false;
    final int testType = args["testType"] ?? 1;

    // 💡 testType에 따라 다르게 빌드되는 테스트 데이터 세트
    final InvoiceDetailModel mockData = testType == 2
        ? InvoiceDetailModel(
            invoiceNumber: "CBID-2026052199x7741253",
            invoiceDate: "2026-05-21 14:19",
            items: [
              InvoiceItem(index: 1, itemName: "객실 잔금", amount: 600000),
              InvoiceItem(index: 2, itemName: "에스테틱 잔금", amount: 300000),
              InvoiceItem(index: 3, itemName: "아기용품 구매비", amount: 300000),
            ],
            totalAmount: 1200000,
            customerName: "김산모",
            phoneNumber: "010-4545-8523",
            email: "abc@gmail.com",
          )
        : InvoiceDetailModel(
            invoiceNumber: "CBID-2026060178b2164271",
            invoiceDate: "2026-06-10 14:19",
            items: [
              InvoiceItem(index: 1, itemName: "객실 잔금", amount: 300000),
              InvoiceItem(index: 2, itemName: "에스테틱 잔금", amount: 300000),
            ],
            totalAmount: 600000,
            customerName: "김산모",
            phoneNumber: "010-4545-8523",
            email: "abc@gmail.com",
          );

    // 💡 토스 결제창에 표시할 대표 주문명 동적 생성
    final String orderName = mockData.items.isNotEmpty
        ? (mockData.items.length > 1
              ? "${mockData.items[0].itemName} 외 ${mockData.items.length - 1}건"
              : mockData.items[0].itemName)
        : "조리원 청구 비용";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isPaidMode ? "청구서 내역 보기" : "청구서 결제하기",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("청구 정보"),
                    _buildInfoRow("청구번호", mockData.invoiceNumber),
                    _buildInfoRow("청구일시", mockData.invoiceDate),
                    const SizedBox(height: 24),

                    _buildSectionTitle("청구 항목"),
                    _buildDynamicTable(mockData.items, formatter),

                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xEFEFEFEF)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "총 금액",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                formatter.format(mockData.totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text("원", style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle("결제 고객 정보"),
                    _buildInfoRow("이름", mockData.customerName),
                    _buildInfoRow("전화번호", mockData.phoneNumber),
                    _buildInfoRow("이메일", mockData.email),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (isPaidMode) {
                      print("매출전표 페이지로 이동합니다.");
                      Get.toNamed("/receiptDetailPage");
                      // Get.to(() => const ReceiptDetailPage());
                    } else {
                      Get.toNamed(
                        "/paymentPage",
                        arguments: {
                          "amount": mockData.totalAmount,
                          "orderName": orderName,
                        },
                      );
                      // Get.to(
                      //   () => PaymentPage(
                      //     amount: mockData.totalAmount,
                      //     orderName: orderName,
                      //   ),
                      // );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF785186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isPaidMode ? "매출전표 보기" : "결제하기",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEFEFEF)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTable(List<InvoiceItem> items, NumberFormat formatter) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEFEFEF)),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(4),
          2: FlexColumnWidth(3.5),
        },
        border: TableBorder.all(color: const Color(0xFFEFEFEF), width: 1),
        children: [
          _buildTableHeaderRow(),
          ...items.map(
            (item) => TableRow(
              children: [
                _buildTableCell(item.index.toString(), isCenter: true),
                _buildTableCell(item.itemName, isCenter: true),
                _buildTableCell(formatter.format(item.amount), isCenter: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFFAFAFA)),
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "순번",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "청구 항목명",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "금액",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isCenter = false}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          textAlign: isCenter ? TextAlign.center : TextAlign.start,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }
}

// 모델 클래스 구조 (기존 유지)
class InvoiceItem {
  final int index;
  final String itemName;
  final int amount;
  InvoiceItem({
    required this.index,
    required this.itemName,
    required this.amount,
  });
}

class InvoiceDetailModel {
  final String invoiceNumber;
  final String invoiceDate;
  final List<InvoiceItem> items;
  final int totalAmount;
  final String customerName;
  final String phoneNumber;
  final String email;

  InvoiceDetailModel({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.items,
    required this.totalAmount,
    required this.customerName,
    required this.phoneNumber,
    required this.email,
  });
}
