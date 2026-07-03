import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ContractPdfScreen extends StatefulWidget {
  const ContractPdfScreen({super.key});

  @override
  State<ContractPdfScreen> createState() => _ContractPdfScreenState();
}

class _ContractPdfScreenState extends State<ContractPdfScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late String pdfUrl;
  late String pdfName;

  @override
  void initState() {
    super.initState();
    // 🚀 이전 화면(_buildMenuTile)에서 보낸 argument Map 데이터를 추출합니다.
    final Map<String, dynamic> args = Get.arguments ?? {};

    // 혹시라도 데이터가 비어서 넘어올 경우를 대비한 방어 코드(기본값) 선언
    pdfUrl =
        args["pdfUrl"] ??
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
    pdfName = args["pdfName"] ?? "계약서 파일";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1D5DB), // 이미지의 전체 연회색 배경색
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "내 현재 계약서",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 파일명 표시 영역 (연회색 배경)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: const Color(0xFFD1D5DB), // 이미지 배경색과 일치
            child: Text(
              pdfName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),

          // 2. PDF 뷰어 영역 (이미지처럼 좌우 여백을 주어 종이 느낌 강조)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15), // 좌우 여백
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                child: SfPdfViewer.network(
                  // 실제 PDF URL을 여기에 넣으시면 됩니다.
                  pdfUrl,
                  key: _pdfViewerKey,
                ),
              ),
            ),
          ),
          // 하단 여백 (이미지 느낌 유지)
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
