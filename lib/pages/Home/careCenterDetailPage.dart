import 'package:flutter/material.dart';

class CareCenterDetailPage extends StatefulWidget {
  const CareCenterDetailPage({super.key});

  @override
  State<CareCenterDetailPage> createState() => _CareCenterDetailPageState();
}

class _CareCenterDetailPageState extends State<CareCenterDetailPage> {
  // 📸 상단 이미지 슬라이더를 위한 컨트롤러 및 데이터
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 더미 이미지 리스트 (실제 이미지 경로로 변경하여 사용하세요)
  final List<String> _images = ['lib/assets/gangnam.png', 'lib/assets/gangnam1.png', 'lib/assets/gangnam2.png'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. 앱바 (상단 타이틀 및 뒤로가기)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "궁 산후조리원 강남본원",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. 상단 이미지 슬라이더 영역 (PageView + Indicator)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        _images[index],
                        fit: BoxFit.cover,
                        // 💡 네트워크 이미지 로딩 실패 시 에러 핸들링
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                          );
                        },
                      );
                    },
                  ),
                ),
                // ⚪⚪⚫⚪ 인디케이터 도트
                Positioned(
                  bottom: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 3. 조리원 이름 및 주소 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "궁 산후조리원 강남본원",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "서울특별시 강남구 언주로107길 35 (역삼동 658-7)",
                    style: TextStyle(fontSize: 15, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 25),

                  // 4. 상세 정보 카드 리스트 영역
                  _buildInfoRow("전화번호", "02-555-9550"),
                  _buildInfoRow("대표이사", "장경희"),
                  _buildInfoRow("정보관리\n책임자", "장경희"),
                  _buildInfoRow("사업자\n등록번호", "478-85-00758"),
                  _buildInfoRow("E-mail", "mkt@goongs.com"),

                  const SizedBox(height: 10),

                  // 5. 최하단 브랜드 로고 배치 영역
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Image.asset(
                        "lib/assets/gong_logo.png", // 👈 준비하신 로고 이미지 경로로 대체하세요
                        width: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // 이미지가 없을 때 임시로 텍스트나 아이콘 표시 대체 구조
                          return const Text(
                            "[ 궁 산후조리원 LOGO ]",
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 시안의 둥근 모서리 박스 형태의 정보 한 줄을 그리는 공통 위젯입니다.
  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1), //  정상 코드 // 시안의 연한 테두리 색상 반영
      ),
      child: IntrinsicHeight(
        // 타이틀 행 높이에 맞춰 경계선과 밸런스를 맞추는 위젯
        child: Row(
          children: [
            // 좌측 타이틀 영역
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.3,
                ),
              ),
            ),
            // 우측 실제 값 영역
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
