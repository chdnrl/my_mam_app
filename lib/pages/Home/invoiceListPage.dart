import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 💡 GetX 이동을 위해 임포트 확인
import 'package:intl/intl.dart';
import 'package:my_mam_app/pages/Home/invoiceDetailPage.dart';

class InvoiceListPage extends StatelessWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Java API 연동 전 가상 데이터 리스트
    final List<InvoiceModel> invoices = [
      InvoiceModel(
        invoiceDate: "2026.05.21 14:19",
        centerName: "궁 산후조리원 삼성점",
        totalAmount: 1200000,
        isPaid: true, // 결제됨 -> 내역 보기 -> 1,200,000원 상세 화면 연결
      ),
      InvoiceModel(
        invoiceDate: "2026.06.10 12:02",
        centerName: "궁 산후조리원 삼성점",
        totalAmount: 600000,
        isPaid: false, // 결제전 -> 결제하기 -> 600,000원 상세 화면 연결
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "내 청구서 목록",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          return _buildInvoiceCard(
            invoices[index],
          ); // 👈 빌더 메서드에서 context 제거 가능 (GetX 활용)
        },
      ),
    );
  }

  // 시안 이미지 맞춤형 동적 청구서 카드 빌더
  Widget _buildInvoiceCard(InvoiceModel data) {
    final formatter = NumberFormat('#,###');
    String formattedAmount = formatter.format(data.totalAmount);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: ShapeDecoration(
        color: data.isPaid ? const Color(0xFF76657D) : const Color(0xFF785186),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        shadows: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 5,
            offset: Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 상단: 청구일시 및 결제 상태 태그
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "청구일시: ${data.invoiceDate}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontFamily: 'Pretendard',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54, width: 1.0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.isPaid ? "결제됨" : "결제 전",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 2. 중간: 조리원 이름
          Text(
            data.centerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 24),

          // 3. 하단: 총 금액 및 액션 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "총 금액",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formattedAmount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "원",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 결제 상태별 동적 버튼 생성
              _buildActionButton(data.isPaid),
            ],
          ),
        ],
      ),
    );
  }

  // 결제 여부에 따른 우측 하단 흰색 라운드 버튼
  Widget _buildActionButton(bool isPaid) {
    return ElevatedButton(
      onPressed: () {
        if (isPaid) {
          print("내역 보기 페이지 이동 (1,200,000원 테스트 데이터 데이터 연동)");
          // 💡arguments에 Map 형태나 객체 형태로 데이터를 담아 보냅니다.
          Get.toNamed(
            "/invoiceDetailPage",
            arguments: {"isPaidMode": true, "testType": 2},
          );
        } else {
          print("결제 페이지 이동 (600,000원 테스트 데이터 연동)");
          Get.toNamed(
            "/invoiceDetailPage",
            arguments: {"isPaidMode": false, "testType": 1},
          );
        }
        // if (isPaid) {
        //   print("내역 보기 페이지 이동 (1,200,000원 테스트 데이터 데이터 연동)");
        //   // 💡 testType: 2를 넘겨주어 상세화면에서 120만 원이 보이게 합니다.
        //   Get.to(() => const InvoiceDetailPage(isPaidMode: true, testType: 2));
        // } else {
        //   print("결제 페이지 이동 (600,000원 테스트 데이터 연동)");
        //   // 💡 testType: 1을 넘겨주어 상세화면에서 60만 원이 보이게 합니다.
        //   Get.to(() => const InvoiceDetailPage(isPaidMode: false, testType: 1));
        // }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size(120, 42),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        isPaid ? "내역 보기" : "결제하기",
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class InvoiceModel {
  final String invoiceDate;
  final String centerName;
  final int totalAmount;
  final bool isPaid;

  InvoiceModel({
    required this.invoiceDate,
    required this.centerName,
    required this.totalAmount,
    required this.isPaid,
  });
}
