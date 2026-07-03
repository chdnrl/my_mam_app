import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';

enum ContractStatus { pre, staying, completed }

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ContractStatus currentStatus = ContractStatus.staying;
  bool isAuthenticated = false;
  bool isFamilyUser = false;
  bool showGiftIcon = false;
  bool isButtonEnabled = false;

  final TextEditingController _momController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();

  // ===========================================================================
  // [🔥 디자인 반영] 산모 모드용 아기 수에 따른 스마트 크래들 원본 소스 데이터
  // ===========================================================================
  final List<Map<String, dynamic>> babyCradleData = [
    {
      "title": "SMART CRADLE",
      "subtitle": "신생아 스마트 크래들",
      "babyName": "찰떡이(305)",
      "bgImage":
          "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?q=80&w=500",
      "type": "male",
      "isClickable": false,
    },
    // 만약 아기가 쌍둥이라면 여기에 데이터를 더 추가하면 자동으로 리스트가 늘어납니다.
  ];

  // ===========================================================================
  // [🔥 신규 추가] 스마트 크래들 권한 체크 및 페이지 이동 핸들러
  // ===========================================================================
  void _navigateToSmartCradle() {
    // 1. 산모(가족 관리자)는 권한 체크 없이 무조건 통과
    if (!isFamilyUser) {
      Get.toNamed("/smartCradlePage");
      return;
    }

    // 2. 가족 유저인 경우, 자바 API 등으로 받아온 실시간 영상 공유 상태값 확인
    bool isCradleShared = false; // 테스트를 위해 우선 false(차단)로 세팅

    if (!isCradleShared) {
      // 권한이 없으므로 안내 팝업을 띄우고 진입 차단
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "접근 제한 안내",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "현재 스마트 크래들 실시간 영상 보기 권한이 비활성화되어 있습니다.\n\n가족 관리자(산모)에게 권한 허용을 요청해 주세요.",
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "확인",
                style: TextStyle(
                  color: Color(0xFF785186),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 권한이 있으면 정상 진입
      Get.toNamed("/smartCradlePage");
    }
  }
  // ===========================================================================

  void _handleAuth(String code, bool isFamilyRequest) {
    if (code != "ABC12345") {
      ToastUtils.showCustomSnackBar(context, "맞지 않는 코드입니다. 확인 후 재입력해주세요.");
    } else {
      setState(() {
        isAuthenticated = true;
        isFamilyUser = isFamilyRequest;
        // [🛠️ 수정] 요구사항: 가족 모드로 인증할 때만 선물함 아이콘 노출/활성화 제어
        showGiftIcon = isFamilyUser;
        isButtonEnabled = true;
      });
      ToastUtils.showCustomSnackBar(
        context,
        "${isFamilyUser ? '가족' : '산모'} 인증에 성공하였습니다.",
        isError: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainBgColor = Color(0xFFF5F5F5);
    return Scaffold(
      backgroundColor: mainBgColor,
      appBar: _buildAppBar(mainBgColor),
      drawer: _buildSideMenu(),
      body: isAuthenticated ? _buildMainContent() : _buildAuthScreen(),
    );
  }

  // --- 왼쪽 사이드 메뉴 (Drawer) ---
  Widget _buildSideMenu() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'lib/assets/logo_mymam.svg',
                    width: 150,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      "MYMAM",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF785186),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildMenuTile(
                    title: "메인",
                    imagePath: "lib/assets/home_Icon.png",
                    onTap: () => Get.toNamed("termsAgree"),
                  ),
                  if (!isFamilyUser)
                    _buildMenuTile(
                      title: "계약서 보기",
                      imagePath: "lib/assets/terms_Icon.png",
                      onTap: () => Get.toNamed(
                        "contractPdfPage",
                        arguments: {
                          "pdfUrl":
                              'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
                          "pdfName": '궁 산후조리원.pdf',
                        },
                      ),
                    ),
                  _buildMenuTile(
                    title: "스마트 크래들 보기",
                    imagePath: "lib/assets/contact_Icon.png",
                    onTap: _navigateToSmartCradle,
                  ),
                  if (!isFamilyUser)
                    _buildMenuTile(
                      title: "가족모드 관리",
                      imagePath: "lib/assets/contact_Icon.png",
                      onTap: () => Get.toNamed("/familyManagementPage"),
                    ),
                  if (!isFamilyUser)
                    _buildMenuTile(
                      title: "내 청구서 목록",
                      imagePath: "lib/assets/invoice_Icon.png",
                      onTap: () => Get.toNamed("/invoiceListPage"),
                    ),
                ],
              ),
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
              thickness: 1,
              color: Color(0xFFF0F0F0),
            ),
            _buildMenuTile(
              title: "내 정보",
              imagePath: "lib/assets/contact_Icon.png",
              onTap: () => Get.toNamed(
                "/myInfoPage",
                arguments: {"isFamilyUser": isFamilyUser},
              ),
            ),
            if (!isFamilyUser)
              _buildMenuTile(
                title: "전체 계약서 목록",
                imagePath: "lib/assets/contact_Icon.png",
                onTap: () => Get.toNamed('/contractListPage'),
              ),
            const Divider(
              indent: 20,
              endIndent: 20,
              thickness: 1,
              color: Color(0xFFF0F0F0),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "고객센터",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => print("통화 실행"),
                    child: const Text(
                      "Tel. 판옵티콘 전화",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14),
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

  Widget _buildMenuTile({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(
        imagePath,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.circle, size: 10),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Pretendard',
          color: Color(0xFF333333),
        ),
      ),
      onTap: onTap,
    );
  }

  PreferredSizeWidget _buildAppBar(Color bgColor) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SvgPicture.asset(
          'lib/assets/logo_mymam.svg',
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          width: 120,
        ),
      ),
      leadingWidth: 150,
      actions: [
        // [🛠️ 수정] 요구사항 헤더 제어: 가족 모드 인증 시(showGiftIcon == true) 선물함 노출 활성화
        if (showGiftIcon)
          Builder(
            builder: (context) {
              bool isGiftDisabled = currentStatus == ContractStatus.completed;
              return Opacity(
                opacity: isGiftDisabled ? 0.4 : 1.0,
                child: _buildActionIcon(
                  "lib/assets/gift_Icon.png",
                  isGiftDisabled ? null : () => print("선물함 클릭"),
                ),
              );
            },
          ),
        Builder(
          builder: (context) => _buildActionIcon(
            "lib/assets/menu_Icon.png",
            isButtonEnabled ? () => Scaffold.of(context).openDrawer() : null,
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildActionIcon(String path, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(path, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 10),
      child: Column(
        children: [
          _buildUserProfile(),
          const SizedBox(height: 20),
          _buildAuthCard(
            isFamily: false,
            title: "산모 인증하기",
            description:
                "스마트한 엄마들만 사용하는 스마트한 마이맘!\n산모님의 소중한 데이터 보안을 위해\n제휴 산후조리원에서 발급하는\n신원인증 절차를 확인해야합니다.",
            hint: "산후조리원에서 발급한 인증코드 입력",
            controller: _momController,
            onPressed: () => _handleAuth(_momController.text, false),
          ),
          const SizedBox(height: 20),
          _buildAuthCard(
            isFamily: true,
            title: "가족모드 인증하기",
            description:
                "마이맘 가족모드는 산모님의 초대에 따라\n신생아의 실시간 카메라, 생체정보를 확인할 수 있는\n스마트 크래들과 산모님의 산후조리에 필요한\n선물을 간편하게 전달할 수 있는 모드입니다.",
            hint: "산모님이 발급한 인증코드 입력",
            controller: _familyController,
            onPressed: () => _handleAuth(_familyController.text, true),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // [🛠️ 핵심 리팩토링 및 수정] 조건부 동적 레이아웃 스위칭 뷰 구현 완료
  // ===========================================================================
  Widget _buildMainContent() {
    bool shouldDim =
        currentStatus == ContractStatus.pre ||
        currentStatus == ContractStatus.completed;

    // 1. 산모 모드 레이아웃 리스트 생성 빌더
    List<Widget> momLayoutItems = [
      _buildUserProfile(),
      _buildFixedPurpleCard(), // 보라색 계약 카드 기본 배치
    ];
    // 아기 수(리스트 데이터 개수)에 맞추어 스마트 크래들 카드가 동적으로 증가함
    for (var cradle in babyCradleData) {
      momLayoutItems.add(
        AbsorbPointer(
          absorbing: shouldDim,
          child: Opacity(
            opacity: shouldDim ? 0.5 : 1.0,
            child: _buildDynamicImageCard(cradle),
          ),
        ),
      );
    }
    // 최하단에 항상 가족 초대하기 카드가 안착
    momLayoutItems.add(
      _buildFamilyInviteCard({
        "title": "MYMAM 가족 초대하기",
        "subtitle": "스마트 크래들 화면 공유",
      }),
    );

    // 2. 가족 모드 레이아웃 리스트 생성 빌더
    List<Widget> familyLayoutItems = [_buildUserProfile()];
    // 크래들 카드가 상단(프로필 바로 밑)에 무조건 배치됨
    for (var cradle in babyCradleData) {
      familyLayoutItems.add(
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: _buildDynamicImageCard(cradle),
        ),
      );
    }
    // 두 번째 카드 포지션에 동적으로 'MYMAM MALL' 쇼핑몰 카드를 삽입
    familyLayoutItems.add(_buildMaltCard());

    // 3. 최종 인증 플래그값 상태에 따라 원하는 동적 리스트 렌더링
    List<Widget> currentLayout = isFamilyUser
        ? familyLayoutItems
        : momLayoutItems;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: currentLayout.length,
      itemBuilder: (context, index) {
        return currentLayout[index];
      },
    );
  }

  Widget _buildUserProfile() {
    String userName = "최수영";
    String familyName = "홍길동";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Image.asset("lib/assets/test_Image.png"),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFamilyUser ? "$familyName님" : "$userName님",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 111, 65, 128),
                ),
              ),
              const Text(
                "오늘도 좋은 하루 보내세요!",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          const Spacer(),
          if (isFamilyUser)
            Text(
              "$userName님 가족 모드",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF785186),
              ),
            )
          else
            OutlinedButton(
              onPressed: isButtonEnabled
                  ? () => Get.toNamed("/myInfoPage")
                  : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide.none,
                shape: const StadiumBorder(),
              ),
              child: const Text("내 정보"),
            ),
        ],
      ),
    );
  }

  Widget _buildFixedPurpleCard() {
    if (currentStatus == ContractStatus.staying) {
      return _buildStayingCard();
    } else {
      return _buildContractInfoCard();
    }
  }

  Widget _buildStayingCard() {
    int totalDays = 14;
    int currentDays = 4;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF785186),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCenterInfoText("산후조리원 퇴실 까지"),
              Row(
                children: [
                  ContractCircularChart(
                    totalDays: totalDays,
                    currentDays: currentDays,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "일",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildCardFooter("2025.05.18 ~ 2025.06.01"),
        ],
      ),
    );
  }

  Widget _buildContractInfoCard() {
    String statusText = currentStatus == ContractStatus.pre ? "입실 예정" : "이용 완료";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: const Color(0xFF785186),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCenterInfoText(statusText),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  currentStatus == ContractStatus.pre ? "입실전" : "퇴실함",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "계약이 안전하게 체결되었습니다.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 5),
              _buildCardFooter("2025.07.10 ~ 2025.07.24"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterInfoText(String topLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topLabel,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        const Text(
          "궁 산후조리원 삼성점",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "스탠다드 1302호",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCardFooter(String dateRange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          dateRange,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        ElevatedButton(
          onPressed: () => Get.toNamed(
            "/contractPdfPage",
            arguments: {
              "pdfUrl":
                  'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
              "pdfName": '궁 산후조리원.pdf',
            },
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            elevation: 0,
          ),
          child: const Text("계약서 보기", style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  // 동적 이미지 배경 카드 (스마트 크래들 렌더링용)
  Widget _buildDynamicImageCard(Map<String, dynamic> data) {
    String type = data['type'] ?? 'male';

    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: data['bgImage'].toString().startsWith('http')
              ? NetworkImage(data['bgImage']!)
              : AssetImage(data['bgImage']) as ImageProvider,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.darken,
          ),
        ),
        // 카드 입체 구분을 위한 그림자 디자인 설계 추가
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF785186),
            ),
          ),
          Text(data['subtitle']!, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 12,
                      child: Icon(
                        type == 'male' ? Icons.male : Icons.female,
                        size: 18,
                        color: type == 'male' ? Colors.blue : Colors.pink,
                      ),
                    ),
                    Text(
                      data['babyName']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _navigateToSmartCradle, // 상단 정의 권한 제어 함수 연동
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF785186).withOpacity(0.8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(120, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("자세히 보기"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // [🔥 신규 디자인 구현] 산모 전용 최하단 - 가족 초대하기 컴포넌트 카드 구조
  // ===========================================================================
  Widget _buildFamilyInviteCard(Map<String, dynamic> data) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage("lib/assets/family_card_image.png"),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title']!,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF785186),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data['subtitle']!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed("/familyManagementPage"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.85),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: const Color(0xFF785186).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      "가족모드 관리",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed("/inviteGuidePage"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF785186).withOpacity(0.8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "가족 초대하기",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // [🔥 신규 디자인 구현] 가족 모드 전용 두 번째 배치 - MYMAM MALL 전용 반반 버튼 카드 구조
  // ===========================================================================
  Widget _buildMaltCard() {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage("lib/assets/family_card_image.png"), // 쇼핑몰 배경 지정 매핑
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MYMAM MALL",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF785186),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "산모와 아기를 위한 맞춤형 선물",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // 요구사항 반영: 회색조 톤의 하단 하프(반반) 가로 정렬 버튼 레이아웃 설계
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => print("선물하기 클릭"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xEAEAEA,
                      ).withOpacity(0.9), // 회색조 배경 설계
                      foregroundColor: const Color(0xFF444444),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
                          color: Color(0xFFD5D5D5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      "선물하기",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => print("주문내역 클릭"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFDCDCDC,
                      ).withOpacity(0.9), // 조금 더 짙은 회색조 밸런스 잡기
                      foregroundColor: const Color(0xFF333333),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "주문내역",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard({
    required bool isFamily,
    required String title,
    required String description,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF785186),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          isFamily
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "lib/assets/logo_ImageWight.png",
                      width: 140,
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "가족모드",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Image.asset(
                  "lib/assets/logo_ImageWight.png",
                  width: 140,
                  height: 30,
                ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
          const Divider(color: Colors.white30, height: 40),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              UpperCaseTextFormatter(),
            ],
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF785186),
                shape: const StadiumBorder(),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class ContractCircularChart extends StatelessWidget {
  final int totalDays;
  final int currentDays;
  const ContractCircularChart({
    super.key,
    required this.totalDays,
    required this.currentDays,
  });

  @override
  Widget build(BuildContext context) {
    const double chartSize = 65.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: chartSize,
          height: chartSize,
          child: CircularProgressIndicator(
            value: currentDays / totalDays,
            backgroundColor: const Color(0xFF523463),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC19CCB)),
            strokeWidth: 5,
          ),
        ),
        Text(
          "$totalDays",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}
