import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/stores/ContractController.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ContractPdfScreen extends StatefulWidget {
  const ContractPdfScreen({super.key});

  @override
  State<ContractPdfScreen> createState() => _ContractPdfScreenState();
}

class _ContractPdfScreenState extends State<ContractPdfScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  // 1️⃣ 싱글톤 또는 주입된 ContractController 찾아오기
  final ContractController _contractController = Get.find<ContractController>();

  @override
  void initState() {
    super.initState();
    // 🚀 이전 화면에서 보낸 args에서 고유 파일 키(fid) 혹은 contractDoc 정보를 가로챕니다.
    final Map<String, dynamic> args = Get.arguments ?? {};

    // 넘어온 데이터 성격에 맞게 매핑 (예시: args["fid"] 또는 args["pdfUrl"] 자리에 담겨온 fid 매칭)
    String targetFid = args["fid"] ?? args["pdfUrl"] ?? "";
    print("-----------------------------------$targetFid");
    // 2️⃣ 화면 프레임이 구성된 직후 자바 서버 백엔드로 fullUri 스펙 획득 트랜잭션 가동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (targetFid.isNotEmpty) {
        _contractController.loadContractPdfFile(targetFid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color mainGrayBg = Color(0xFFD1D5DB);

    return Scaffold(
      backgroundColor: mainGrayBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "내 현재 계약서",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      // 3️⃣ Obx 관측 체계를 적용하여 데이터 상태에 따라 화면을 분기합니다.
      body: Obx(() {
        if (_contractController.isPdfLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF785186)));
        }

        final fileModel = _contractController.pdfFileData.value;

        if (fileModel == null || fileModel.fullUri.isEmpty) {
          return const Center(
            child: Text("계약서 파일을 불러오지 못했습니다.", style: TextStyle(color: Color(0xFF374151), fontSize: 16)),
          );
        }

        // 확장자 판별 (소문자 변환)
        final isImage =
            fileModel.mimeType.toLowerCase() == 'png' ||
            fileModel.mimeType.toLowerCase() == 'jpg' ||
            fileModel.mimeType.toLowerCase() == 'jpeg' ||
            fileModel.fullUri.contains('.png') ||
            fileModel.fullUri.contains('.jpg');

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: mainGrayBg,
              child: Text(
                fileModel.fname,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  // 💡 mimeType에 따라 뷰어를 스위칭합니다.
                  child: isImage
                      ? Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: InteractiveViewer(
                            // 이미지 줌 인/아웃 가능 가동
                            maxScale: 5.0,
                            child: Image.network(
                              fileModel.fullUri,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text("이미지를 로드할 수 없습니다.")),
                            ),
                          ),
                        )
                      : SfPdfViewer.network(fileModel.fullUri, key: _pdfViewerKey),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}
