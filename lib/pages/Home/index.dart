import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/constants/index.dart';
import 'package:my_mam_app/pages/Home/contractListPage.dart';
import 'package:my_mam_app/pages/Home/myInfoPage.dart';
import 'package:my_mam_app/pages/Home/sideMenu.dart';
import 'package:my_mam_app/pages/searchAndReservation/centerDetailPage.dart';
import 'package:my_mam_app/pages/searchAndReservation/index.dart';
import 'package:my_mam_app/pages/searchAndReservation/searchPage.dart';
import 'package:my_mam_app/stores/ContractController.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';
import 'package:my_mam_app/stores/UserController.dart';

enum ContractStatus { pre, staying, completed }

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ContractStatus currentStatus = ContractStatus.staying;

  // 폼 제어용 컨트롤러 변수
  // final TextEditingController _momController = TextEditingController();
  // final TextEditingController _familyController = TextEditingController();

  // GetX UserController 싱글톤 인스턴스 연결
  final UserController _userController = UserController.to;
  // 푸터 펼침 상태 관리 변수
  bool _isFooterExpanded = false;

  final List<Map<String, dynamic>> babyCradleData = [
    {
      "title": "SMART CRADLE",
      "subtitle": "신생아 스마트 크래들",
      "babyName": "찰떡이(305)",
      "bgImage": "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?q=80&w=500",
      "type": "male",
      "isClickable": false,
    },
  ];

  void _navigateToSmartCradle() {
    if (!_userController.isFamilyUser.value) {
      Get.toNamed("/smartCradlePage");
      return;
    }

    bool isCradleShared = false;

    if (!isCradleShared) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("접근 제한 안내", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "현재 스마트 크래들 실시간 영상 보기 권한이 비활성화되어 있습니다.\n\n가족 관리자(산모)에게 권한 허용을 요청해 주세요.",
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "확인",
                style: TextStyle(color: Color(0xFF785186), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.toNamed("/smartCradlePage");
    }
  }

  // ===========================================================================
  // 🌐 UserController를 통한 백엔드 커맨드 연동 핸들러
  // ===========================================================================

  // 🎯 사이드 메뉴 전용 로그아웃 확인 창
  // void _showSideMenuLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("로그아웃"),
  //       content: const Text("정말 로그아웃 하시겠습니까?\n로그아웃 시 모든 데이터가 초기화됩니다."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: const Text("취소", style: TextStyle(color: Colors.grey)),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Get.back(); // 다이얼로그 닫기
  //             await _executeSideMenuLogoutWorkflow(); // 워크플로우 가동
  //           },
  //           child: const Text(
  //             "확인",
  //             style: TextStyle(
  //               color: Color(0xFF785186),
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // 🎯 로그아웃 실행 파이프라인
  // Future<void> _executeSideMenuLogoutWorkflow() async {
  //   bool logoutResult = await _userController.handleServerLogout();

  //   if (logoutResult) {
  //     print("🎉 원격 서버 및 로컬 인프라 초기화 완료 (사이드 메뉴)");
  //     Get.offAllNamed('/login'); // 전체 화면 스택 제거 후 로그인 이동
  //   } else {
  //     if (mounted) {
  //       ToastUtils.showCustomSnackBar(
  //         context,
  //         "서버와 통신이 불안정하여 로그아웃에 실패했습니다. 다시 시도해 주세요.",
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    const Color mainBgColor = Color(0xFFF5F5F5);

    // 🎯 [수정] PopScope로 감싸서 안드로이드 물리 뒤로가기 버튼 제어
    return PopScope(
      canPop: false, // 👈 기본 뒤로가기 동작(앱 종료)을 무력화합니다.
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 📱 안드로이드 기기인 경우 앱을 종료하지 않고 백그라운드(홈화면)로 보냅니다.
        if (Theme.of(context).platform == TargetPlatform.android) {
          SystemNavigator.pop(); // 👈 카카오톡이나 유튜브처럼 백그라운드로 내려감
        }
      },
      // 기존에 작동하던 Obx 구조를 그대로 child에 넣어 유지합니다.
      child: Obx(() {
        return Scaffold(
          backgroundColor: mainBgColor,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(mainBgColor),
          drawer: const SideMenuWidget(),
          body: SafeArea(
            bottom: false,
            child: _userController.isLoading.value
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF785186)))
                : (_userController.isAuthenticated.value ? _buildMainContent() : const AuthScreen()),
          ),
        );
      }),
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
        if (_userController.showGiftIcon.value)
          Builder(
            builder: (context) {
              bool isGiftDisabled = currentStatus == ContractStatus.completed;
              return Opacity(
                opacity: isGiftDisabled ? 0.4 : 1.0,
                child: _buildActionIcon("lib/assets/gift_Icon.png", isGiftDisabled ? null : () => print("선물함 클릭")),
              );
            },
          ),
        Builder(
          builder: (context) => _buildActionIcon("lib/assets/menu_Icon.png", () => Scaffold.of(context).openDrawer()),
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
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(path, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  // Widget _buildAuthScreen() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 10),
  //     child: Column(
  //       children: [
  //         _buildUserProfile(),
  //         const SizedBox(height: 20),
  //         _buildAuthCard(
  //           isFamily: false,
  //           title: "산모 인증하기",
  //           description: "스마트한 엄마들만 사용하는 스마트한 마이맘!\n산모님의 소중한 데이터 보안을 위해\n제휴 산후조리원에서 발급하는\n신원인증 절차를 확인해야합니다.",
  //           hint: "산후조리원에서 발급한 인증코드 입력",
  //           controller: _momController,
  //           onPressed: () => _handleAuthSubmit(_momController.text, false),
  //         ),
  //         const SizedBox(height: 20),
  //         _buildAuthCard(
  //           isFamily: true,
  //           title: "가족모드 인증하기",
  //           description:
  //               "마이맘 가족모드는 산모님의 초대에 따라\n신생아의 실시간 카메라, 생체정보를 확인할 수 있는\n스마트 크래들과 산모님의 산후조리에 필요한\n선물을 간편하게 전달할 수 있는 모드입니다.",
  //           hint: "산모님이 발급한 인증코드 입력",
  //           controller: _familyController,
  //           onPressed: () => _handleAuthSubmit(_familyController.text, true),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ===========================================================================
  // 📱 메인 콘텐츠 빌더 (회색 하단 푸터 통합 버전)
  // ===========================================================================
  Widget _buildMainContent() {
    // 💡 분리된 ContractController 인스턴스를 초기화 혹은 탐색합니다.
    final ContractController contractController = Get.put(ContractController());
    bool shouldDim = currentStatus == ContractStatus.pre || currentStatus == ContractStatus.completed;

    // 1. 본문에 들어갈 아이템들을 순서대로 적재할 리스트 생성
    List<Widget> bodyItems = [];

    // [1] 상단 프로필 영역 추가
    bodyItems.add(
      Padding(
        padding: const EdgeInsets.only(top: 12.0), // 전체 Sliver 패딩과 결합하여 상단 여백 조절
        child: _buildUserProfile(),
      ),
    );

    if (!_userController.isFamilyUser.value) {
      // 🤰 [산모 모드 레이아웃]
      // [2] 고정 보라색 카드 추가
      bodyItems.add(_buildFixedPurpleCard(contractController));

      // [3] 스마트 크래들 목록 루프 생성
      for (var cradle in babyCradleData) {
        bodyItems.add(
          AbsorbPointer(
            absorbing: shouldDim,
            child: Opacity(opacity: shouldDim ? 0.5 : 1.0, child: _buildDynamicImageCard(cradle)),
          ),
        );
      }

      // [4] 가족 초대 카드 추가
      bodyItems.add(_buildFamilyInviteCard({"title": "MYMAM 가족 초대하기", "subtitle": "스마트 크래들 화면 공유"}));
    } else {
      // 👨‍👩‍👧‍👦 [가족 모드 레이아웃]
      // [2] 가족 모드 전용 스마트 크래들 목록 루프 생성
      for (var cradle in babyCradleData) {
        bodyItems.add(Padding(padding: const EdgeInsets.only(top: 15.0), child: _buildDynamicImageCard(cradle)));
      }

      // [3] 가족 모드 전용 하단 몰 카드(또는 맥아카드) 추가
      bodyItems.add(_buildMaltCard());
    }

    // 2. 🎯 테스트 버전의 오버플로우 방지형 Sticky Footer 구조 이식
    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     return CustomScrollView(
    //       physics: const AlwaysScrollableScrollPhysics(),
    //       slivers: [
    //         // 📦 [A] 본문 영역: 실용적인 전체 20.0(또는 기존 16.0) 좌우 패딩 일괄 부여
    //         SliverToBoxAdapter(
    //           child: Padding(
    //             padding: const EdgeInsets.symmetric(horizontal: 16.0), // 💡 기존 상용 버전의 16 패딩 기준 적용
    //             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: bodyItems),
    //           ),
    //         ),

    //         // 🛠️ [B] 푸터 영역: 기기별 하단바 여백을 자동 계산하며 좌우 배경이 꽉 차는 스티키 푸터
    //         SliverToBoxAdapter(
    //           child: SafeArea(
    //             top: false, // 상단 패딩 계산 제외
    //             bottom: true, // 💡 핵심: 최신 아이폰/갤럭시 하단 인디케이터 바 여백 자동 확보
    //             child: Container(
    //               constraints: const BoxConstraints(
    //                 minHeight: 100, // 최소 푸터 높이 보장
    //               ),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.end,
    //                 children: [
    //                   _userController.isFamilyUser.value
    //                       ? const SizedBox(height: 80)
    //                       : const SizedBox(height: 30), // 본문 최하단 카드와 푸터 시작선 사이의 안전 간격
    //                   _buildFooter(), // 실제 회사명 및 사업자 정보 렌더링 위젯
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
    // 🎯 하단 바 완전 밀착 + 오버플로우 방지 하이브리드 구조
    return LayoutBuilder(
      builder: (context, constraints) {
        // 제스처 폰에서 아래 붕 뜨는 현상을 막기 위해 시스템의 하단 패딩 값을 정밀 측정합니다.
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        // 하단 네비게이션이 완전히 없는 경우(0인 경우) 최소 안전 마진 12~16만 주고, 있는 경우 시스템 값을 그대로 씁니다.
        final effectiveBottomPadding = bottomPadding == 0 ? 16.0 : bottomPadding;

        return Stack(
          children: [
            // 📦 [A] 본문 스크롤 영역 (푸터 뒤로 스크롤이 들어갑니다)
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  // 💡 중요: 푸터가 열렸을 때와 닫혔을 때 본문 마지막 카드가 푸터 배경에 완전히 가려지지 않도록 패딩을 가변 조절합니다.
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, _isFooterExpanded ? 420.0 : 160.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: bodyItems),
                ),
              ),
            ),

            // 🛠️ [B] 기기 최하단에 완전 고정되는 푸터 (절대 뜨지 않음)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFEAEAEA), // 푸터 전용 회색 배경이 기기 맨 밑바닥까지 꽉 채웁니다.
                padding: EdgeInsets.only(bottom: effectiveBottomPadding), // 💡 붕 뜨는 현상 해결 핵심
                child: _buildFooter(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserProfile() {
    // if (_userController.userInfo.value == null) {
    //   return const SizedBox.shrink();
    // }
    String userName = _userController.userInfo.value?.userName ?? "사용자";
    String familyName = _userController.userInfo.value?.userName ?? "사용자";
    String? fileId = _userController.userInfo.value?.fileId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: fileId != null && fileId.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: "${GlobalConstants.BASE_URL}/file/download?fileId=$fileId",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFEEEEEE),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF785186)),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        Image.asset("lib/assets/test_Image.png", width: 60, height: 60, fit: BoxFit.cover),
                  )
                : Image.asset("lib/assets/test_Image.png", width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userController.isFamilyUser.value ? "$familyName님" : "$userName님",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 111, 65, 128),
                ),
              ),
              const Text("오늘도 좋은 하루 보내세요!", style: TextStyle(color: Colors.black)),
            ],
          ),
          const Spacer(),
          if (_userController.isFamilyUser.value)
            Text(
              "$userName님 가족 모드",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF785186)),
            )
          else
            OutlinedButton(
              onPressed: _userController.isAuthenticated.value ? () => Get.toNamed("/myInfoPage") : null,
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

  Widget _buildFixedPurpleCard(ContractController contractController) {
    if (currentStatus == ContractStatus.staying) {
      // 2. 현재 활성화되어 바인딩된 계약 데이터가 존재하지 않을 때 예외 UI
      if (contractController.activeContract.value == null) {
        return _buildNoContractStayingCard();
      }
      return _buildContractStayingCard(contractController);
    } else {
      return _buildContractInfoCard();
    }
  }

  Widget _buildNoContractStayingCard() {
    int totalDays = 14;
    int currentDays = 4;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF785186), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCenterInfoText(
                topLabel: "산후조리원 퇴실 까지",
                centerName: "궁 산후조리원", // 가상 게터 "산후조리원" 혹은 서버 데이터
                roomSpec: "",
              ),
              Row(
                children: [
                  ContractCircularChart(totalDays: totalDays, currentDays: currentDays, displayDDay: 10),
                  const SizedBox(width: 8),
                  const Text(
                    "일",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildContractCardFooter(
            "2025.05.18 ~ 2025.06.01",
            "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
          ),
        ],
      ),
    );
  }

  /// 🤰 [수정] 메인 화면용 실데이터 연동 계약 정보 카드
  Widget _buildContractStayingCard(ContractController controller) {
    final contract = controller.activeContract.value!;

    // 1. 입실 기간 포맷팅 (sdate ~ edate)
    String dateRange = (contract.sdate.isNotEmpty && contract.edate.isNotEmpty)
        ? "${contract.sdate} ~ ${contract.edate}"
        : (contract.period.isNotEmpty ? contract.period : "-");

    // 2. 퇴실까지 남은 디데이 일수 계산 (총 기간 - 진행 기간)
    int dDay = controller.totalStayingDays - controller.currentStayingDays;
    // 만약 이미 퇴실 날짜가 지났다면 0으로 고정
    if (dDay < 0) dDay = 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF785186), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💡 API 데이터 (방 등급, 호실 정보) 전달
              _buildCenterInfoText(
                topLabel: "산후조리원 퇴실 까지",
                centerName: contract.centerName, // 가상 게터 "산후조리원" 혹은 서버 데이터
                roomSpec: "${contract.roomLevelName} ${contract.roomNo}",
              ),
              Row(
                children: [
                  // 💡 차트 진척도는 (지나온 날짜 / 총 날짜), 텍스트는 남은 dDay 노출
                  ContractCircularChart(
                    totalDays: controller.totalStayingDays,
                    currentDays: controller.currentStayingDays,
                    displayDDay: dDay, // 남은 일수 표시용 변수 추가
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "일",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 💡 계약서 파일 링크 유무에 따라 다운로드 주입
          _buildContractCardFooter(dateRange, contract.contractDoc),
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
      decoration: BoxDecoration(color: const Color(0xFF785186), borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCenterInfoText(
                topLabel: statusText,
                centerName: "궁 산후조리원", // 가상 게터 "산후조리원" 혹은 서버 데이터
                roomSpec: "",
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  currentStatus == ContractStatus.pre ? "입실전" : "퇴실함",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("계약이 안전하게 체결되었습니다.", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              _buildContractCardFooter(
                "2025.07.10 ~ 2025.07.24",
                "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildCenterInfoText(String topLabel) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(topLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
  //       const Text(
  //         "궁 산후조리원 삼성점",
  //         style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       const Text("스탠다드 1302호", style: TextStyle(color: Colors.white, fontSize: 16)),
  //     ],
  //   );
  // }
  /// 🏢 [수정] 센터 정보 및 방 스펙 동적 빌더
  Widget _buildCenterInfoText({required String topLabel, required String centerName, required String roomSpec}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
        Text(
          centerName, // "산후조리원" 또는 "궁 산후조리원" 등 매핑
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          roomSpec, // "스탠다드 1302호" 또는 "VIP실 501호" 등 매핑
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  // Widget _buildContractCardFooter(String dateRange) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       Text(dateRange, style: const TextStyle(color: Colors.white, fontSize: 15)),
  //       ElevatedButton(
  //         onPressed: () => Get.toNamed(
  //           "/contractPdfPage",
  //           arguments: {
  //             "pdfUrl": 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
  //             "pdfName": '궁 산후조리원.pdf',
  //           },
  //         ),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.white,
  //           foregroundColor: Colors.black,
  //           shape: const StadiumBorder(),
  //           padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
  //           elevation: 0,
  //         ),
  //         child: const Text("계약서 보기", style: TextStyle(fontSize: 14)),
  //       ),
  //     ],
  //   );
  // }
  /// 📄 [수정] 하단 계약서 다운로드 연동 푸터
  Widget _buildContractCardFooter(String dateRange, String? contractDocUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(dateRange, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ElevatedButton(
          onPressed: () => Get.toNamed(
            "/contractPdfPage",
            arguments: {
              "pdfUrl": (contractDocUrl != null && contractDocUrl.isNotEmpty)
                  ? contractDocUrl
                  : 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
              "pdfName": '산후조리원_계약서.pdf',
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
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title']!,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF785186)),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Pretendard'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _navigateToSmartCradle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF785186).withOpacity(0.8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(120, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("자세히 보기"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInviteCard(Map<String, dynamic> data) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(image: AssetImage("lib/assets/family_card_image.png"), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
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
                        side: BorderSide(color: const Color(0xFF785186).withOpacity(0.3), width: 1),
                      ),
                    ),
                    child: const Text("가족모드 관리", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("가족 초대하기", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaltCard() {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(image: AssetImage("lib/assets/KakaoTalkTest.png"), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MYMAM MALL",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF785186), letterSpacing: 1.2),
          ),
          const SizedBox(height: 2),
          const Text(
            "산모와 아기를 위한 맞춤형 선물",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => print("선물하기 클릭"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFECECEC).withOpacity(0.9),
                      foregroundColor: const Color(0xFF444444),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFD5D5D5), width: 1),
                      ),
                    ),
                    child: const Text("선물하기", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      backgroundColor: const Color(0xFFDCDCDC).withOpacity(0.9),
                      foregroundColor: const Color(0xFF333333),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("주문내역", style: TextStyle(fontWeight: FontWeight.bold)),
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
  // 🏢 [추가] 최하단 회사 정보 및 이용약관 (푸터 뷰)
  // ===========================================================================
  // Widget _buildFooter() {
  //   return Container(
  //     width: double.infinity,
  //     color: const Color(0xFFEAEAEA), // 연한 회색 배경 색상
  //     padding: EdgeInsets.fromLTRB(20, 30, 20, _isFooterExpanded ? 30 : 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // 이용약관 링크 라인 (중앙 정렬)
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center, // 👈 이용약관 라인 가운데 정렬
  //           children: [
  //             _buildFooterLinkText("이용약관과 정책", () => print("이용약관")),
  //             _buildVerticalDivider(),
  //             _buildFooterLinkText("개인정보처리방침", () => print("개인정보")),
  //             _buildVerticalDivider(),
  //             _buildFooterLinkText("위치기반서비스 이용약관", () => print("위치기반")),
  //           ],
  //         ),
  //         const SizedBox(height: 15),

  //         // 회사명 토글 헤더 버튼 형태
  //         InkWell(
  //           onTap: () {
  //             setState(() {
  //               _isFooterExpanded = !_isFooterExpanded; // 👈 터치 시 열림/닫힘 토글
  //             });
  //           },
  //           splashColor: Colors.transparent,
  //           highlightColor: Colors.transparent,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center, // 👈 회사명 라인 가운데 정렬
  //             mainAxisSize: MainAxisSize.max,
  //             children: [
  //               const Text(
  //                 "(주)판옵티콘 에이아이",
  //                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
  //               ),
  //               const SizedBox(width: 4),
  //               // 👈 상태 변화에 따라 부드럽게 180도 회전하는 아이콘 효과
  //               AnimatedRotation(
  //                 turns: _isFooterExpanded ? 0.5 : 0.0, // 열리면 아래로(0.5바퀴 회전), 닫히면 위로(기본값)
  //                 duration: const Duration(milliseconds: 300),
  //                 child: const Icon(
  //                   Icons.keyboard_arrow_up, // 닫혔을 때는 기본적으로 위(^)를 향함
  //                   size: 18,
  //                   color: Color(0xFF555555),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // 👈 아래에서 위로 스르륵 확장되는 상세 정보 애니메이션 영역
  //         AnimatedCrossFade(
  //           firstChild: const SizedBox.shrink(), // 닫혔을 때는 빈 공간
  //           secondChild: Padding(
  //             padding: const EdgeInsets.only(top: 15.0),
  //             child: Column(
  //               // 💡 기존 CrossAxisAlignment.start를 center로 수정하여 중앙으로 정렬합니다.
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // 상세 기업 정보 Grid 레이아웃 데이터화 표기
  //                 _buildFooterInfoRow("대표이사", "장승호"),
  //                 _buildFooterInfoRow("사업자 등록번호", "331-86-01644"),
  //                 _buildFooterInfoRow("호스팅 사업자", "주식회사 판옵티콘에이아이"),
  //                 _buildFooterInfoRow("통신판매업신고번호", "2026-서울서초-1489호"),
  //                 _buildFooterInfoRow("이메일", "contact@panopticonai.kr"),
  //                 _buildFooterInfoRow("고객센터", "대표전화 070-4022-7202"),
  //                 _buildFooterInfoRow("주소", "서울특별시 서초구 법원로3길 19, 2층\n2010호(서초동, 양지원)"),

  //                 const SizedBox(height: 30),

  //                 // 카피라이트 텍스트
  //                 const Center(
  //                   child: Text(
  //                     "ⓒ (주)판옵티콘 에이아이 ALL RIGHTS RESERVED",
  //                     style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'Pretendard'),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           crossFadeState: _isFooterExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
  //           duration: const Duration(milliseconds: 250),
  //         ),
  //         const SizedBox(height: 10), // 안드로이드/iOS 시스템 내비게이션 여백 확보
  //       ],
  //     ),
  //   );
  // }
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      // 💡 아래로 자연스럽게 늘어나야 하므로 bottom 패딩은 제거하거나 최소화합니다.
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 💡 자기 콘텐츠 크기만큼만 유연하게 차지하게 함 (에러 방지)
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 이용약관 링크 라인 (중앙 정렬)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLinkText("이용약관과 정책", () => print("이용약관")),
              _buildVerticalDivider(),
              _buildFooterLinkText("개인정보처리방침", () => print("개인정보")),
              _buildVerticalDivider(),
              _buildFooterLinkText("위치기반서비스 이용약관", () => print("위치기반")),
            ],
          ),
          const SizedBox(height: 5),

          // 2. 회사명 토글 헤더 버튼 형태
          InkWell(
            onTap: () {
              setState(() {
                _isFooterExpanded = !_isFooterExpanded;
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "(주)판옵티콘 에이아이",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isFooterExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_up, size: 18, color: Color(0xFF555555)),
                ),
              ],
            ),
          ),

          // 3. 🎯 아래 방향으로 펼쳐지는 상세 정보 영역
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter, // 💡 위쪽을 고정하고 아래쪽으로 자라나게 만듭니다.
            child: _isFooterExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFooterInfoRow("대표이사", "장승호"),
                        _buildFooterInfoRow("사업자 등록번호", "331-86-01644"),
                        _buildFooterInfoRow("호스팅 사업자", "주식회사 판옵티콘에이아이"),
                        _buildFooterInfoRow("통신판매업신고번호", "2026-서울서초-1489호"),
                        _buildFooterInfoRow("이메일", "contact@panopticonai.kr"),
                        _buildFooterInfoRow("고객센터", "대표전화 070-4022-7202"),
                        _buildFooterInfoRow("주소", "서울특별시 서초구 법원로3길 19, 2층\n2010호(서초동, 양지원)"),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            "ⓒ (주)판옵티콘 에이아이 ALL RIGHTS RESERVED",
                            style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'Pretendard'),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 10), // 접혔을 때의 최소 하단 여백 공간
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinkText(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 10,
      width: 1,
      color: const Color(0xFFCCCCCC),
    );
  }

  Widget _buildFooterInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💡 1. 왼쪽에 일정한 여백을 주어 전체 블록을 중앙 근처로 이동시킵니다.
          // 현재 푸터 내부 패딩이 좌우 20이므로, 시안처럼 배치하기 위해 추가 시작 여백을 줍니다.
          const SizedBox(width: 40),

          // 💡 2. 타이틀 영역에 고정 가로폭을 제공하여 시작 위치를 일치시킵니다.
          SizedBox(
            width: 115, // 타이틀(예: '통신판매업신고번호')이 잘리지 않는 최적의 너비
            child: Text(
              title,
              textAlign: TextAlign.left, // 💡 시안처럼 타이틀도 왼쪽 정렬
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontFamily: 'Pretendard'),
            ),
          ),

          // 타이틀과 값 사이의 간격
          const SizedBox(width: 15),

          // 💡 3. 실제 데이터(값) 영역
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left, // 💡 값 영역도 왼쪽 정렬
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
                height: 1.3, // 주소처럼 줄바꿈 시 가독성을 위한 행간
                fontFamily: 'Pretendard',
              ),
            ),
          ),

          // 우측의 균형을 맞추기 위한 여백 (필요에 따라 조절 가능)
          const SizedBox(width: 20),
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
      decoration: BoxDecoration(color: const Color(0xFF785186), borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          isFamily
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("lib/assets/logo_imageWight.png", width: 140, height: 30),
                    const SizedBox(width: 10),
                    const Text(
                      "가족모드",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Image.asset("lib/assets/logo_imageWight.png", width: 140, height: 30),
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
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), UpperCaseTextFormatter()],
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// 🛠️ 텍스트 입력 대문자 변환 포매터
// ===========================================================================
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

// ===========================================================================
// 📊 조리원 잔여 일수 원형 차트 위젯
// ===========================================================================
class ContractCircularChart extends StatelessWidget {
  final int totalDays;
  final int currentDays;
  final int displayDDay; // 🌟 추가된 남은 날짜 변수
  const ContractCircularChart({
    super.key,
    required this.totalDays,
    required this.currentDays,
    required this.displayDDay,
  });

  @override
  Widget build(BuildContext context) {
    const double chartSize = 65.0;
    // 0 나누기 방어용 프로그레스 값 계산
    double progressValue = (totalDays > 0) ? (currentDays / totalDays) : 0.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: chartSize,
          height: chartSize,
          child: CircularProgressIndicator(
            // value: currentDays / totalDays,
            value: progressValue,
            backgroundColor: const Color(0xFF523463),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC19CCB)),
            strokeWidth: 5,
          ),
        ),
        Text(
          "$totalDays",
          // "$displayDDay", // 🌟 고정된 총 기간 대신 실시간 남은 일수 표출
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ],
    );
  }
}
