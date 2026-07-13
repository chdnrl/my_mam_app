import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_mam_app/stores/InvoiceController.dart';

class ReceiptDetailPage extends StatefulWidget {
  const ReceiptDetailPage({super.key});

  @override
  State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  // 1️⃣ InvoiceController find로 주입 연결
  final InvoiceController _invoiceController = Get.find<InvoiceController>();

  late String billingId;

  @override
  void initState() {
    super.initState();

    // 2️⃣ 아규먼트에서 넘겨받은 billingId 안전하게 추출
    final Map<String, dynamic> args = Get.arguments ?? {"billingId": ""};
    billingId = args["billingId"] ?? "";

    // 3️⃣ 화면이 완전히 열린 직후 자바 백엔드 영수증 상세 정보 API 가동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (billingId.isNotEmpty) {
        _invoiceController.loadInvoiceDetail(billingId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

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
          "매출전표 보기",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          // ⏳ 컨트롤러가 API 로딩 중일 때 서클 바 가동
          if (_invoiceController.isDetailLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF785186)));
          }

          // 🚨 데이터가 유실되었거나 null일 때 방어 처리
          final detailData = _invoiceController.selectedDetail.value;
          if (detailData == null) {
            return const Center(
              child: Text("매출전표 데이터를 불러오지 못했습니다.", style: TextStyle(color: Colors.grey, fontSize: 15)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 타이틀
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "신용·체크카드 매출전표",
                    style: TextStyle(color: Color(0xFF243447), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. 주문 정보 섹션 (실서버 데이터 매핑)
                _buildReceiptRow("주문번호", detailData.billingId),
                _buildReceiptRow("구매자", detailData.custName),
                _buildReceiptRow("구매상품", detailData.goodsName.isNotEmpty ? detailData.goodsName : "조리원 비용 청구 항목"),

                _buildDivider(),

                // 3. 카드 및 승인 정보 섹션 (실서버 데이터 매핑)
                _buildReceiptRow("카드종류", detailData.payKind.name), // SubCode 객체의 국문 이름 매핑
                _buildReceiptRow("카드번호", detailData.payAccno.isNotEmpty ? detailData.payAccno : "-"),
                _buildReceiptRow("할부", detailData.subPayKind.isNotEmpty ? detailData.subPayKind : "일시불"),
                _buildReceiptRow("결제상태", detailData.payStatus.name), // "납부완료", "승인" 등 한글 바인딩
                _buildReceiptRow("승인번호", detailData.autNo.isNotEmpty ? detailData.autNo : "-"),
                _buildReceiptRow("결제일시", detailData.payDate.isNotEmpty ? detailData.payDate : "-"),

                _buildDivider(),

                // 4. 금액 정산 섹션 (실서버 데이터 매핑)
                _buildReceiptRow("공급가액", "${formatter.format(detailData.baseAmt)}원"),
                _buildReceiptRow("면세가액", "${formatter.format(detailData.taxExemptAmt)}원"),
                _buildReceiptRow("부가세", "${formatter.format(detailData.vatAmt)}원"),
                _buildReceiptRow("합계", "${formatter.format(detailData.totAmt)}원", isTotal: true),

                _buildDivider(),

                // 5. 이용상점 / 결제서비스업체 안내문 섹션 (실제 상점 데이터가 필요할 시 추가 수정)
                const SizedBox(height: 8),
                _buildCompanyInfo(
                  title: "이용상점",
                  content: "마더맘 산후조리원 | 대표자명: 이땡땡 | 사업자등록번호: 124-81-00000 | 전화: 02-123-4567 | 주소: 서울특별시 강남구 조리원길 10",
                ),
                const SizedBox(height: 16),
                _buildCompanyInfo(
                  title: "결제서비스업체",
                  content: "토스페이먼츠(주) | 대표자명: 이엔이 | 사업자등록번호: 211-88-33312 | 전화: 1544-7777 | 주소: 서울특별시 강남구 테헤란로 131",
                ),
                const SizedBox(height: 20),

                // 부가세법 안내 텍스트
                const Text(
                  "부가가치세법 제46조 3항에 따라 신용카드 매출전표도 매입세금계산서로 사용할 수 있습니다.",
                  style: TextStyle(color: Colors.black38, fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 32),

                // 6. 하단 토스페이먼츠 로고 영역
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      "toss payments",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40), // 하단 여백 확보
              ],
            ),
          );
        }),
      ),
    );
  }

  // 전표 데이터 표현용 좌우 정렬 Row 위젯
  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? const Color(0xFF4E7FFF) : const Color(0xFF6B7684),
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFF4E7FFF) : const Color(0xFF333D4B),
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 구분선 위젯
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Divider(color: Colors.grey[200], thickness: 1),
    );
  }

  // 이용상점 및 결제업체 가이드 텍스트 위젯
  Widget _buildCompanyInfo({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF6B7684), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(color: Colors.black45, fontSize: 12, height: 1.4)),
      ],
    );
  }
}

// class ReceiptDetailPage extends StatelessWidget {
//   const ReceiptDetailPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final formatter = NumberFormat('#,###');

//     // 💡 image_3a2cc6.png 시안 기준 가상 데이터 세팅
//     final receiptData = {
//       "orderNumber": "DKPG5507443463",
//       "buyer": "김*이",
//       "productName": "토스 티셔츠 외 2건",
//       "cardType": "삼성",
//       "cardNumber": "379183******588",
//       "installment": "일시불",
//       "status": "승인",
//       "approvalNumber": "02011276",
//       "approvalDate": "2022-07-26 17:48:48",
//       "supplyValue": 1545,
//       "taxFreeValue": 0,
//       "vat": 155,
//       "totalAmount": 1700,
//     };

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "매출전표 보기",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. 타이틀 (우측 아이콘 제외)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 12.0),
//                 child: Text(
//                   "신용·체크카드 매출전표",
//                   style: TextStyle(
//                     color: Color(0xFF243447),
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // 2. 주문 정보 섹션
//               _buildReceiptRow("주문번호", receiptData["orderNumber"].toString()),
//               _buildReceiptRow("구매자", receiptData["buyer"].toString()),
//               _buildReceiptRow("구매상품", receiptData["productName"].toString()),

//               _buildDivider(),

//               // 3. 카드 및 승인 정보 섹션
//               _buildReceiptRow("카드종류", receiptData["cardType"].toString()),
//               _buildReceiptRow("카드번호", receiptData["cardNumber"].toString()),
//               _buildReceiptRow("할부", receiptData["installment"].toString()),
//               _buildReceiptRow("결제상태", receiptData["status"].toString()),
//               _buildReceiptRow(
//                 "승인번호",
//                 receiptData["approvalNumber"].toString(),
//               ),
//               _buildReceiptRow("결제일시", receiptData["approvalDate"].toString()),

//               _buildDivider(),

//               // 4. 금액 정산 섹션
//               _buildReceiptRow(
//                 "공급가액",
//                 "${formatter.format(receiptData["supplyValue"])}원",
//               ),
//               _buildReceiptRow(
//                 "면세가액",
//                 "${formatter.format(receiptData["taxFreeValue"])}원",
//               ),
//               _buildReceiptRow(
//                 "부가세",
//                 "${formatter.format(receiptData["vat"])}원",
//               ),
//               _buildReceiptRow(
//                 "합계",
//                 "${formatter.format(receiptData["totalAmount"])}원",
//                 isTotal: true,
//               ),

//               _buildDivider(),

//               // 5. 이용상점 / 결제서비스업체 안내문 섹션
//               const SizedBox(height: 8),
//               _buildCompanyInfo(
//                 title: "이용상점",
//                 content:
//                     "(주)교보문고 | 대표자명: 김땡땡 | 사업자등록번호: 1230-123123-123 | 전화: 1544-1234 | 주소: 서울특별시 종로구 좋은동 좋은 빌딩",
//               ),
//               const SizedBox(height: 16),
//               _buildCompanyInfo(
//                 title: "결제서비스업체",
//                 content:
//                     "토스페이먼츠(주) | 대표자명: 김민표 | 사업자등록번호: 1230-123123-123 | 전화: 1544-1234 | 주소: 서울특별시 종로구 좋은동 좋은 빌딩",
//               ),
//               const SizedBox(height: 20),

//               // 부가세법 안내 텍스트
//               const Text(
//                 "부가가치세법 제46조 3항에 따라 신용카드 매출전표도 매입세금계산서로 사용할 수 있습니다.",
//                 style: TextStyle(
//                   color: Colors.black38,
//                   fontSize: 11,
//                   height: 1.4,
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // 6. 하단 토스페이먼츠 로고 영역
//               Row(
//                 children: [
//                   Icon(
//                     Icons.shield_outlined,
//                     size: 18,
//                     color: Colors.grey[700],
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     "toss payments",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w900,
//                       fontStyle: FontStyle.italic,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 40), // 하단 여백 확보
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // 전표 데이터 표현용 좌우 정렬 Row 위젯
//   Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 7.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: isTotal
//                   ? const Color(0xFF4E7FFF)
//                   : const Color(0xFF6B7684),
//               fontSize: 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: isTotal
//                   ? const Color(0xFF4E7FFF)
//                   : const Color(0xFF333D4B),
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 구분선 위젯
//   Widget _buildDivider() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 14.0),
//       child: Divider(color: Colors.grey[200], thickness: 1),
//     );
//   }

//   // 이용상점 및 결제업체 가이드 텍스트 위젯
//   Widget _buildCompanyInfo({required String title, required String content}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             color: Color(0xFF6B7684),
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           content,
//           style: const TextStyle(
//             color: Colors.black45,
//             fontSize: 12,
//             height: 1.4,
//           ),
//         ),
//       ],
//     );
//   }
// }
