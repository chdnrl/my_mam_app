import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:my_mam_app/stores/CradleController.dart';

class SmartCradlePage extends StatelessWidget {
  const SmartCradlePage({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX 컨트롤러 주입 및 의존성 연결
    final controller = Get.put(CradleController());

    final String babyName = "새롬이";
    final String motherName = "최수영";
    final String gender = "male";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "실시간 스마트 크래들",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 상단 이름표
          _buildNameTag(gender, babyName, motherName),

          // 2. 실시간 영상 영역 및 캡처 버튼 (HLS 연동 코드로 전면 개편)
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: Obx(() {
                    if (controller.isVideoLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF785186)));
                    }
                    if (!controller.isVideoInitialized.value) {
                      return const Center(child: Icon(Icons.error_outline, size: 50, color: Colors.grey));
                    }
                    // 미디어 서버에서 온 가변 비율 HLS 스트림 출력
                    return AspectRatio(
                      aspectRatio: controller.videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(controller.videoPlayerController!),
                    );
                  }),
                ),
                // 썸네일 캡처 버튼
                Positioned(right: 20, bottom: 20, child: _buildCaptureButton()),
              ],
            ),
          ),

          // 3. 하단 데이터 그리드 (실시간 데이터 바인딩 적용)
          _buildDataGrid(controller),

          // 4. 하단 안내 문구
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "출력되는 데이터는 스마트 크래들에서\n측정한 최신 데이터입니다.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // 이름표 위젯
  Widget _buildNameTag(String gender, String babyName, String motherName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(gender == "male" ? Icons.male : Icons.female, color: Colors.grey[700], size: 25),
          const SizedBox(width: 10),
          Text(babyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 35),
          Container(width: 2, height: 23, color: Colors.grey[400]),
          const SizedBox(width: 25),
          Text("$motherName 산모님", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 캡처 버튼 위젯
  Widget _buildCaptureButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Get.snackbar("알림", "썸네일이 캡처되었습니다.");
      },
      icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF785186), size: 20),
      label: const Text(
        "썸네일 캡처하기",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }

  // 데이터 그리드 위젯 (모든 센서 값을 실시간 구독하도록 Obx 배치 완료)
  Widget _buildDataGrid(CradleController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 1. 체온 실시간 바인딩
              Obx(() => _dataItem("체온", "${controller.cradleData.temp.value}°C")),

              // 2. 체중 실시간 바인딩 (수정 완료)
              Obx(() => _dataItem("체중", "${controller.cradleData.weight.value}kg", hasLeftBorder: true)),
            ],
          ),
          Row(
            children: [
              // 3. 수유량 실시간 바인딩 (수정 완료)
              Obx(() => _dataItem("수유량", "${controller.cradleData.amount.value}ml", hasTopBorder: true)),

              Obx(() => _dataItem("수유시간", "${controller.cradleData.time.value}", hasTopBorder: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataItem(String label, String value, {bool hasLeftBorder = false, bool hasTopBorder = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            left: hasLeftBorder ? BorderSide(color: Colors.grey[300]!, width: 0.5) : BorderSide.none,
            top: hasTopBorder ? BorderSide(color: Colors.grey[300]!, width: 0.5) : BorderSide.none,
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Pretendard'),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendard',
                color: Color(0xFF785186),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
