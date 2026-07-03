import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CenterDetailPage extends StatefulWidget {
  const CenterDetailPage({super.key});

  @override
  State<CenterDetailPage> createState() => _CenterDetailPageState();
}

class _CenterDetailPageState extends State<CenterDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _localSliderImages = [
    "lib/assets/gangnam.png",
    "lib/assets/gangnam1.png",
    "lib/assets/gangnam2.png",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String centerName = Get.arguments?["centerName"] ?? "궁 산후조리원 강남본원";
    // 💡 기기 하단 네비게이션 바의 실제 높이를 가져옵니다.
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          centerName,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 스크롤 영역
          SingleChildScrollView(
            // 💡 버튼이 더 높아진 만큼 스크롤 아래 여백도 동적으로 늘려줍니다.
            padding: EdgeInsets.only(bottom: 120 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSlider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 25.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  centerName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "서울특별시 강남구 언주로107길 35 (역삼동 658-7)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "1.3km",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildInfoTable([
                        {"label": "전화번호", "value": "02-555-9550"},
                        {"label": "E-mail", "value": "mkt@goongs.com"},
                        {"label": "상담시간", "value": "09:00 ~ 18:00"},
                      ]),
                      const SizedBox(height: 40),
                      _buildSectionTitle("지점 소개"),
                      const Text(
                        "한 생명의 탄생은 산모님의 많은 희생으로 이루어지는 기적입니다.\n회복과 휴식에 집중합니다. 아기의 탄생, 그 기쁨을 온전히 축복하기 위해 마이맘이 함께 합니다.\n\n각 분야 전문가의 수준 높은 케어와 최고급 시설을 기반으로 약해진 몸을 세심하게 보살펴 드립니다.\n또한 단독 건물 and 프라이빗한 서비스는 휴양지에 온 듯한 편안한 휴식을 가능케 합니다.\n\n모든 산모님은 최고의 대우를 받으실 자격이 있습니다.\n\n\"황후를 대접하는 정성으로 여러분을 모시겠습니다.\"\n\n임직원 일동",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSectionTitle("프로그램"),
                      _buildLocalImage("lib/assets/gangnamroom.png"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "안정되고 편안한 상태에서 마음 편히 산후조리를 하실 수 있으며, 산모님의 빠른 회복을 위해 전문간호사 선생님들이 24시간 책임관리제로 산모님들을 돌보고 있습니다.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildLocalImage("lib/assets/gangnammasaji.png"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "풀바디 테라피 케어, 산후풍증, 가슴관리, 두피케어 등 산모를 위한 최상의 다양한 서비스를 제공합니다.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildLocalImage("lib/assets/gangnamfood1.png"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "어혈치료 - 의인탕\n적소두, 의이인, 차전차 등을 달인 보약으로, 출산 후 산모들의 부종을 제거하고 체중을 조절하는 데 효과적인 처방입니다.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildLocalImage("lib/assets/gangnamhori.png"),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "산후 골반교정\n산모는 출산 직후 전신의 인대가 약해져 관절이 느슨해져 있는 상태라 아기를 안고 있으면 척추와 골반에 가해지는 압력이 대폭 증가합니다. 또한, 수유하는 자세 역시 좌우 불균형 상태라서 골반이나 척추가 틀어지기 쉽고 골반이 상방으로 올라오기 쉬운 상태입니다.\n\n하지만, 신체가 변화하기 쉬운 시기이므로 출산 후 가능한 한 빨리 골반교정을 받는 것이 바람직합니다.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSectionTitle("시설"),
                      _buildLocalImage("lib/assets/gangnam1.png"),
                      const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      _buildLocalImage("lib/assets/gangnam2.png"),
                      const SizedBox(height: 40),
                      _buildSectionTitle("이용 요금 안내"),
                      _buildDesignPriceTable("Gold Room", "2주(13박 14일)", [
                        {"col1": "프로그램명", "col2": "금액"},
                        {"col1": "궁", "col2": "6,900,000"},
                        {"col1": "세자빈 A", "col2": "7,700,000"},
                        {"col1": "세자빈 B", "col2": "8,000,000"},
                        {"col1": "황후 A", "col2": "8,700,000"},
                        {"col1": "세자빈 B", "col2": "300,000"},
                        {"col1": "황후 B", "col2": "300,000"},
                      ]),
                      const SizedBox(height: 25),
                      _buildDesignPriceTable("Penthouse", "2주(13박 14일)", [
                        {"col1": "가격안내(정가)", "col2": "14,000,000"},
                        {"col1": "7개월 전", "col2": "11,000,000"},
                        {"col1": "6개월 전", "col2": "12,000,000"},
                        {"col1": "5개월 전", "col2": "12,500,000"},
                        {"col1": "4개월 전", "col2": "13,000,000"},
                        {"col1": "1~3개월 전", "col2": "13,500,000"},
                      ]),
                      const SizedBox(height: 25),
                      _buildDesignPriceTable("VIP Penthouse", "2주(13박 14일)", [
                        {"col1": "가격안내(정가)", "col2": "21,000,000"},
                        {"col1": "7개월 전", "col2": "15,000,000"},
                        {"col1": "6개월 전", "col2": "16,000,000"},
                        {"col1": "5개월 전", "col2": "17,000,000"},
                        {"col1": "4개월 전", "col2": "18,000,000"},
                        {"col1": "1~3개월 전", "col2": "19,000,000"},
                      ]),
                      const SizedBox(height: 40),
                      _buildSectionTitle("서비스 안내"),
                      _buildServiceTable(),
                      const SizedBox(height: 40),
                      _buildSectionTitle("사업자 정보"),
                      _buildBusinessInfoCard(),
                      const SizedBox(height: 5),
                      _buildFooterLogo(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 고정 하단 버튼 레이아웃
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                // 💡 기존 25 고정에서, 기기 하단 패딩(소프트키 영역)만큼 유동적으로 늘려줍니다.
                bottom: bottomPadding > 0 ? bottomPadding + 10 : 25,
              ),
              decoration: BoxDecoration(
                // 💡 소프트키 영역이 늘어날 때 하단이 투명하면 본문 글씨와 겹쳐 보이므로
                // 반투명 혹은 흰색 배경에 그라데이션을 살짝 주는 것이 UI적으로 훨씬 깔끔합니다.
                color: Colors.white.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => print("전화 발신 패키지 연동"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF785186),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "예약 상담하기 (전화)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => print("인증 코드 입력 팝업 띄우기"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black26, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "입실하기 (코드입력)",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 타이틀 스타일 공통화
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: Colors.black87),
        const SizedBox(height: 15),
      ],
    );
  }

  // 상단 이미지 슬라이더
  Widget _buildImageSlider() {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _localSliderImages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Image.asset(
                _localSliderImages[index],
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.black26,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_localSliderImages.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // 상단 기본 정보 테이블 위젯
  Widget _buildInfoTable(List<Map<String, String>> data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: data.map((item) {
          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
                  child: Text(
                    item["label"]!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Text(
                      item["value"]!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 로컬 이미지 공통 컴포넌트
  Widget _buildLocalImage(String path) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Image.asset(
        path,
        fit: BoxFit.fitWidth,
        errorBuilder: (c, e, s) => Container(
          height: 150,
          color: Colors.grey[100],
          child: const Center(child: Icon(Icons.image, color: Colors.black12)),
        ),
      ),
    );
  }

  // 이용요금 테이블
  Widget _buildDesignPriceTable(
    String mainTitle,
    String subTitle,
    List<Map<String, String>> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCDCDC)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: const BoxDecoration(color: Color(0xFF7A598E)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mainTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ...items.map((row) {
            bool isSubHeader = row["col1"] == "프로그램명";
            return Container(
              decoration: BoxDecoration(
                color: isSubHeader
                    ? const Color(0xFFFAFAFA)
                    : Colors.white, // 👈 여기로 이동!
                border: const Border(top: BorderSide(color: Color(0xFFE5E5E5))),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      row["col1"]!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: isSubHeader
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 16,
                    decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      row["col2"]!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSubHeader ? Colors.black87 : Colors.black,
                        fontWeight: isSubHeader
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 서비스 안내 테이블
  Widget _buildServiceTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCDCDC)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    "서비스항목",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
                ),
                const Expanded(
                  flex: 7,
                  child: Text(
                    "세부내용",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    "기본서비스",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 260,
                  decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
                ),
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      _buildSubServiceCell("숙박(13박14일)"),
                      _buildSubServiceCell("식사(1일3식 간식1회)"),
                      _buildSubServiceCell("신생아 케어"),
                      _buildSubServiceCell("산모 케어"),
                      _buildSubServiceCell("청소 및 세탁"),
                      _buildSubServiceCell("산전/산후 케어"),
                      _buildSubServiceCell("모유 수유 가슴 관리"),
                      _buildSubServiceCell("산모 교육 및 신생아 돌보기 교육"),
                      Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: const Text(
                          "비치 물품 (객실 내 좌욕기)",
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    "부가서비스",
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 45,
                  decoration: const BoxDecoration(color: Color(0xFFE5E5E5)),
                ),
                const Expanded(
                  flex: 7,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "신생아 케어 추가(다둥이)\n쌍둥이 추가 200만원 / 1인(13박14일 기준)",
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubServiceCell(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 사업자 정보 정보 카드
  Widget _buildBusinessInfoCard() {
    final List<Map<String, String>> infoItems = [
      {"label": "회사명", "value": "궁 산후조리원 화곡점"},
      {"label": "대표이사", "value": "장경희"},
      {"label": "정보관리책임자", "value": "장경희"},
      {"label": "사업자등록번호", "value": "478-85-00758"},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: infoItems.map((item) {
          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    item["label"]!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item["value"]!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🎨 9. 최하단 푸터 및 로고 배치

  Widget _buildFooterLogo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          //   const Text(
          //     "사업자 정보: 478-85-00758  |  대표이사: 장경희",
          //     style: TextStyle(fontSize: 11, color: Colors.black45),
          //   ),
          const SizedBox(height: 25),

          // 💡 [로고 이미지 배치 파트] 하단 브랜드 전용 로고 이미지 교체
          Image.asset(
            "lib/assets/gong_logo.png", // 👈 실제 로고 에셋 파일 경로로 수정하세요!

            width: 200,

            height: 70,

            fit: BoxFit.contain,

            errorBuilder: (c, e, s) => Column(
              children: [
                const Text(
                  "궁 산후조리원",

                  style: TextStyle(
                    fontSize: 20,

                    fontWeight: FontWeight.w300,

                    color: Colors.black38,

                    letterSpacing: 4,
                  ),
                ),

                Text(
                  "THE PUREMOM",

                  style: TextStyle(
                    fontSize: 9,

                    color: Colors.black26,

                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
