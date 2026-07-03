import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/pages/Home/index.dart';
import 'package:my_mam_app/pages/Home/myInfoPage.dart';
import 'package:my_mam_app/pages/searchAndReservation/searchPage.dart';
import 'package:my_mam_app/stores/UserController.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';
import 'package:my_mam_app/viewmodels/user.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 인증 상태 및 유저 모드 변수
  bool isAuthenticated = false;
  bool isFamilyUser = false;
  bool showGiftIcon = false;
  bool isButtonEnabled = true;

  // 푸터 펼침 상태 관리 변수
  bool _isFooterExpanded = false;

  // ✍️ 텍스트 입력 컨트롤러
  final TextEditingController _momController = TextEditingController();
  final TextEditingController _familyController = TextEditingController();
  final UserController _userController = UserController.to;

  // 인증 로직 함수 (Java 서버 통신 가정)
  void _handleAuth(String code, bool isFamilyRequest, BuildContext dialogContext) {
    if (code != "ABC123") {
      ToastUtils.showCustomSnackBar(context, "맞지 않는 코드입니다. 확인 후 재입력해주세요.");
    } else {
      setState(() {
        _userController.isAuthenticated.value = true;
        _userController.isFamilyUser.value = isFamilyRequest;
        showGiftIcon = isFamilyUser;
        // isButtonEnabled = true;
      });

      ToastUtils.showCustomSnackBar(context, "${isFamilyUser ? '가족' : '산모'} 인증에 성공하였습니다.", isError: false);

      // Get.toNamed('/home');
      Get.offAllNamed('/home');
    }
  }

  void _handleAuthSubmit(String code, bool isFamilyRequest) async {
    final trimmedCode = code.trim();

    if (trimmedCode.isEmpty) {
      ToastUtils.showCustomSnackBar(context, "인증 코드를 입력해주세요.");
      return;
    }

    if (_userController.isLoading.value) return; // 중복 터치 방어

    bool isApiSuccess = false;

    if (isFamilyRequest) {
      // 👨‍👩‍👧‍👦 가족 모드 커맨드 발사
      isApiSuccess = await _userController.handleFamilyAuth(trimmedCode);
    } else {
      // 🤰 산모 모드 커맨드 발사
      isApiSuccess = await _userController.handleMaternalAuth(trimmedCode);
    }

    if (isApiSuccess) {
      setState(() {
        _userController.isAuthenticated.value = true;
        _userController.isFamilyUser.value = isFamilyRequest;
        showGiftIcon = isFamilyUser;
        // isButtonEnabled = true;
      });
      ToastUtils.showCustomSnackBar(context, "${isFamilyRequest ? '가족' : '산모'} 인증에 성공하였습니다.", isError: false);
      Get.offAllNamed('/home');
    } else {
      ToastUtils.showCustomSnackBar(context, "인증에 실패했습니다. 코드를 다시 확인해주세요.");
    }
  }

  @override
  void dispose() {
    _momController.dispose();
    _familyController.dispose();
    super.dispose();
  }

  // 🖼️ 가족모드 인증 팝업(Dialog) 함수
  void _showFamilyAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF785186), borderRadius: BorderRadius.circular(25)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Row(
                      children: [
                        Image.asset(
                          "lib/assets/logo_imageWight.png",
                          width: 100,
                          height: 24,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "가족코드 입력",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFF5A3966), borderRadius: BorderRadius.circular(15)),
                  child: const Text(
                    "마이맘 가족모드는 산모님의 초대에 따라\n신생아의 실시간 카메라, 생체정보를 확인할 수 있는\n스마트 크래들과 산모님의 산후조리에 필요한\n선물을 간편하게 전달할 수 있는 모드입니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "마이맘 카카오톡으로 발송되는\n신원인증 코드를 입력해주세요.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _familyController,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    UpperCaseTextFormatter(),
                  ],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "산모님이 발급한 인증코드 입력",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // 💡 [핵심 수정] 입력된 텍스트 값을 미리 변수에 확보합니다.
                      final String authCode = _familyController.text;

                      // 1️⃣ 키보드를 먼저 내려서 렌더링 오버플로우를 미연에 방지합니다.
                      FocusScope.of(context).unfocus();

                      // 2️⃣ 팝업창(Dialog)을 먼저 화면에서 닫아 안전하게 제거합니다.
                      Navigator.of(dialogContext).pop();

                      // 3️⃣ 확보한 인증 코드로 화면 이동 및 인증 로직을 수행합니다.
                      _handleAuth(authCode, true, context); // 👈 (주의) 닫혀버린 dialogContext 대신 오리지널 context 전달
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF785186),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text(
                      "가족모드 인증하기",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 기기 하단 바 영역 높이 확보
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    // 하단 네비게이션이 없는 경우(0) 최소 안전 마진 16을 주고, 있으면 시스템 값을 그대로 사용
    final double effectiveBottomPadding = bottomPadding == 0 ? 16.0 : bottomPadding;

    // 🎯 [수정] PopScope를 추가하여 인증 전 화면에서도 뒤로가기 시 백그라운드로 가도록 제어
    return PopScope(
      canPop: false, // 👈 기본 뒤로가기(앱 종료)를 막습니다.
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 📱 안드로이드 기기인 경우 앱을 종료하지 않고 백그라운드(최소화)로 보냅니다.
        if (Theme.of(context).platform == TargetPlatform.android) {
          SystemNavigator.pop(); // 👈 앱이 종료되지 않고 숨어있게 만듬
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // 💡 bottom을 false로 해야 푸터의 회색 배경이 기기 맨 밑바닥까지 깔끔하게 채워집니다.
        body: SafeArea(
          bottom: false,
          child: Stack(
            // 🎯 [수정] 홈 화면처럼 본문과 하단 고정 푸터를 Stack으로 결합합니다.
            children: [
              // 📦 [A] 본문 스크롤 영역 (푸터 뒤로 스크롤이 들어갑니다)
              Positioned.fill(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        // 💡 중요: 푸터가 열렸을 때와 닫혔을 때 본문 마지막 카드가 푸터 배경에 완전히 가려지지 않도록
                        // 하단 패딩(bottom)을 가변적으로 조절합니다. (홈 화면의 패딩 값 규격 반영)
                        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, _isFooterExpanded ? 420.0 : 160.0),
                        child: Column(
                          children: [
                            _buildUserProfile(),
                            const SizedBox(height: 15),
                            _buildMainBanner(),
                            const SizedBox(height: 20),
                            _buildMomAdmissionCard(
                              onPressed: () => _handleAuth(_momController.text, false, context),
                              controller: _momController,
                            ),
                            const SizedBox(height: 20),
                            _buildMallCard(),
                            const SizedBox(height: 20),
                            _buildFamilyCard(onPressed: _showFamilyAuthDialog),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🛠️ [B] 기기 최하단에 완전 고정되는 푸터 (절대 뜨지 않고, 펼치면 위로 쓱 올라옴)
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
          ),
        ),
      ),
    );
    // child: Scaffold(
    //   backgroundColor: Colors.white,
    //   body: SafeArea(
    //     bottom: true, // 푸터가 하단 영역을 꽉 채우도록 설정
    //     child: LayoutBuilder(
    //       builder: (context, constraints) {
    //         return CustomScrollView(
    //           physics: const AlwaysScrollableScrollPhysics(), // 항상 스크롤 가능하도록 보장
    //           slivers: [
    //             // 1. 푸터를 제외한 본문 영역
    //             SliverToBoxAdapter(
    //               child: Padding(
    //                 padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
    //                 child: Column(
    //                   children: [
    //                     _buildUserProfile(),
    //                     const SizedBox(height: 15),
    //                     _buildMainBanner(),
    //                     const SizedBox(height: 20),
    //                     _buildMomAdmissionCard(
    //                       onPressed: () => _handleAuth(_momController.text, false, context),
    //                       controller: _momController,
    //                     ),
    //                     const SizedBox(height: 20),
    //                     _buildMallCard(),
    //                     const SizedBox(height: 20),
    //                     _buildFamilyCard(onPressed: _showFamilyAuthDialog),
    //                     const SizedBox(height: 30), // 본문과 푸터 사이의 간격 최소 보장
    //                   ],
    //                 ),
    //               ),
    //             ),

    //             // 2. 남은 공백을 채우고 푸터를 바닥으로 밀어내는 영역
    //             SliverToBoxAdapter(
    //               child: LayoutBuilder(
    //                 builder: (context, footerConstraints) {
    //                   return Container(
    //                     // padding: EdgeInsets.only(
    //                     // bottom: bottomPadding > 0 ? bottomPadding + 10 : 20,
    //                     // ), // 본문 최하단 요소와의 최소 간격 보장
    //                     child: _buildFooter(),
    //                   );
    //                 },
    //               ),
    //             ),
    //           ],
    //         );
    //       },
    //     ),
    //   ),
    // ),
    // );
  }

  // 상단 유저 프로필 영역 위젯
  Widget _buildUserProfile() {
    // if (_userController.userInfo.value == null) {
    //   return const SizedBox.shrink();
    // }
    String userName = _userController.userInfo.value?.userName ?? "사용자";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Image.asset(
              "lib/assets/test_Image.png",
              errorBuilder: (c, e, s) => const Icon(Icons.account_circle, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$userName님",
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
          if (isFamilyUser)
            Text(
              "$userName님 가족 모드",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF785186)),
            )
          else
            OutlinedButton(
              onPressed: isButtonEnabled ? () => Get.toNamed('/myInfoPage') : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey, width: 0.5),
                shape: const StadiumBorder(),
              ),
              child: const Text("내 정보"),
            ),
        ],
      ),
    );
  }

  // 1. 최상단 메인 배너 영역 위젯
  Widget _buildMainBanner() {
    return Container(
      width: double.infinity,
      height: 260, // 💡 피그마 시안 높이 반영
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // 💡 시안의 반경 20 반영
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 1)],
      ),
      // 💡 테두리 곡선 밖으로 배경이 빠져나가지 않도록 잘라냅니다.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. 베이스 배경 이미지
            Positioned.fill(child: Image.asset("lib/assets/authSearchCard.png", fit: BoxFit.cover)),

            // 2. 피그마에서 제공해주신 그라데이션 레이어 적용 (이미지 위에 덮어씌움)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(1.0, 0.0), // 상단 영역 투명도를 위해 조절
                    end: Alignment(-1.0, 0.0),
                    colors: [
                      Color(0x20785186), // 상단은 은은하게 이미지가 보이도록 투명도 조절
                      Color(0xFF785186), // 하단은 텍스트 가독성을 위해 불투명한 보라색
                    ],
                  ),
                ),
              ),
            ),

            // 3. 실제 내부 콘텐츠 배치 (Padding 영역)
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "출산을 축하드립니다!",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "전국 산후조리원 정보를 확인하고\n마이맘에서 간편하게 검색 · 입실하세요",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "산후조리원 검색 · 예약하기",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  const Spacer(),

                  // 하단 버튼 영역
                  Row(
                    children: [
                      // [버튼 1] 산후조리원 검색하기
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => Get.to(() => const SearchPage()),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                            child: const Row(
                              children: [
                                Icon(Icons.search, color: Color(0xFF785186), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "산후조리원 검색하기",
                                  style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // [버튼 2] 지도검색
                      GestureDetector(
                        onTap: () => print("지도 검색 클릭"),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF523463).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white30, width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.map_outlined, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "지도검색",
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomAdmissionCard({required TextEditingController controller, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF785186), // 💡 시안의 딥한 보라색 배경 반영
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          // 1. 상단 타이틀 영역 (로고 아이콘 + MYMAM 입실하기)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  "M",
                  style: TextStyle(color: Color(0xFF523463), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "MYMAM 입실하기",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 2. 내부 안내 박스 영역 (설명글)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF583166), // 💡 내부 안내용 더 어두운 보라색 배경
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              "마이맘 제휴 산후조리원에 입실하실건가요?\n산모님의 소중한 데이터 보안을 위해\n제휴 산후조리원에서 발급하는\n신원인증 절차를 확인해야합니다.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),

          // 3. 안내 서브 카피
          const Text(
            "마이맘 카카오톡으로 발송되는\n신원인증 코드를 입력해주세요.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
          ),
          const SizedBox(height: 20),

          // 4. 인증코드 입력 텍스트 필드
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), UpperCaseTextFormatter()],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            decoration: InputDecoration(
              hintText: "산후조리원에서 발급한 인증코드 입력",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),

          // 5. 하단 인증하기 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF523463),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                "산모 인증하기",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2 & 3. 메인 화면 카드 렌더링 프레임 공통 위젯
  Widget _buildAuthCard({
    required bool isFamily,
    required String title,
    required String description,
    required String hint,
    required TextEditingController? controller,
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
                    Image.asset(
                      "lib/assets/family_card_image.png",
                      width: 140,
                      height: 30,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "가족모드",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Image.asset(
                  "lib/assets/logo_imageWight.png",
                  width: 140,
                  height: 30,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
          const Divider(color: Colors.white30, height: 40),
          if (controller != null) ...[
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), UpperCaseTextFormatter()],
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
          ],
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

  Widget _buildFamilyCard({required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 190, // 💡 시안의 비례에 맞춰 높이 최적화
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        // 몰 카드와 통일감을 주기 위한 미세한 외곽 보더 및 그림자 (필요 시 조절)
        border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // 1. 우측 하단 가족 일러스트 배경 배치
            Positioned(
              right: 15,
              bottom: 0,
              width: 260, // 시안 크기에 맞게 조절
              child: Image.asset(
                "lib/assets/family_Image.png", // 사용할 가족 일러스트 경로
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const SizedBox(),
              ),
            ),

            // 2. 텍스트 및 버튼 콘텐츠 영역
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀 영역 (아이콘 + 텍스트)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF785186),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "M",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "MYMAM 가족모드",
                        style: TextStyle(color: Color(0xFF785186), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "온가족이 안심하는\n마이맘 가족모드",
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
                  ),

                  const Spacer(),

                  // 3. 우측 하단 버튼 배치 (Row를 통해 오른쪽 끝으로 밀기)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF785186).withOpacity(0.8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("가족 코드입력", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. MYMAM MALL 할인몰 배너 영역 위젯
  Widget _buildMallCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(image: AssetImage("lib/assets/KakaoTalkTest.png"), fit: BoxFit.cover),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "MYMAM MALL",
            style: TextStyle(color: Color(0xFF785186), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "스마트한 산후조리 할인몰",
            style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => print("산모에게 선물하기 클릭"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: const Text("산모에게 선물하기", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => print("MALL 메인 클릭"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF785186).withOpacity(0.8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: const Text(
                      "MALL 메인",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
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
  // 🏢 [추가] 최하단 회사 정보 및 이용약관 (푸터 뷰)
  // ===========================================================================
  // 🏢 [시안 및 토글 기능 반영] 최하단 회사 정보 및 이용약관 (푸터 뷰)
  //   Widget _buildFooter() {
  //     return Container(
  //       width: double.infinity,
  //       color: const Color(0xFFEAEAEA), // 연한 회색 배경 색상
  //       padding: EdgeInsets.fromLTRB(20, 30, 20, _isFooterExpanded ? 30 : 16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // 이용약관 링크 라인 (중앙 정렬)
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center, // 👈 이용약관 라인 가운데 정렬
  //             children: [
  //               _buildFooterLinkText("이용약관과 정책", () => print("이용약관")),
  //               _buildVerticalDivider(),
  //               _buildFooterLinkText("개인정보처리방침", () => print("개인정보")),
  //               _buildVerticalDivider(),
  //               _buildFooterLinkText("위치기반서비스 이용약관", () => print("위치기반")),
  //             ],
  //           ),
  //           const SizedBox(height: 15),

  //           // 회사명 토글 헤더 버튼 형태
  //           InkWell(
  //             onTap: () {
  //               setState(() {
  //                 _isFooterExpanded = !_isFooterExpanded; // 👈 터치 시 열림/닫힘 토글
  //               });
  //             },
  //             splashColor: Colors.transparent,
  //             highlightColor: Colors.transparent,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center, // 👈 회사명 라인 가운데 정렬
  //               mainAxisSize: MainAxisSize.max,
  //               children: [
  //                 const Text(
  //                   "(주)판옵티콘 에이아이",
  //                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
  //                 ),
  //                 const SizedBox(width: 4),
  //                 // 👈 상태 변화에 따라 부드럽게 180도 회전하는 아이콘 효과
  //                 AnimatedRotation(
  //                   turns: _isFooterExpanded ? 0.5 : 0.0, // 열리면 아래로(0.5바퀴 회전), 닫히면 위로(기본값)
  //                   duration: const Duration(milliseconds: 300),
  //                   child: const Icon(
  //                     Icons.keyboard_arrow_up, // 닫혔을 때는 기본적으로 위(^)를 향함
  //                     size: 18,
  //                     color: Color(0xFF555555),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           // 👈 아래에서 위로 스르륵 확장되는 상세 정보 애니메이션 영역
  //           AnimatedCrossFade(
  //             firstChild: const SizedBox.shrink(), // 닫혔을 때는 빈 공간
  //             secondChild: Padding(
  //               padding: const EdgeInsets.only(top: 15.0),
  //               child: Column(
  //                 // 💡 기존 CrossAxisAlignment.start를 center로 수정하여 중앙으로 정렬합니다.
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // 상세 기업 정보 Grid 레이아웃 데이터화 표기
  //                   _buildFooterInfoRow("대표이사", "장승호"),
  //                   _buildFooterInfoRow("사업자 등록번호", "331-86-01644"),
  //                   _buildFooterInfoRow("호스팅 사업자", "주식회사 판옵티콘에이아이"),
  //                   _buildFooterInfoRow("통신판매업신고번호", "2026-서울서초-1489호"),
  //                   _buildFooterInfoRow("이메일", "contact@panopticonai.kr"),
  //                   _buildFooterInfoRow("고객센터", "대표전화 070-4022-7202"),
  //                   _buildFooterInfoRow("주소", "서울특별시 서초구 법원로3길 19, 2층\n2010호(서초동, 양지원)"),

  //                   const SizedBox(height: 30),

  //                   // 카피라이트 텍스트
  //                   const Center(
  //                     child: Text(
  //                       "ⓒ (주)판옵티콘 에이아이 ALL RIGHTS RESERVED",
  //                       style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontFamily: 'Pretendard'),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             crossFadeState: _isFooterExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
  //             duration: const Duration(milliseconds: 250),
  //           ),
  //           const SizedBox(height: 10), // 안드로이드/iOS 시스템 내비게이션 여백 확보
  //         ],
  //       ),
  //     );
  //   }

  //   Widget _buildFooterLinkText(String label, VoidCallback onTap) {
  //     return GestureDetector(
  //       onTap: onTap,
  //       child: Text(
  //         label,
  //         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
  //       ),
  //     );
  //   }

  //   Widget _buildVerticalDivider() {
  //     return Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 8),
  //       height: 10,
  //       width: 1,
  //       color: const Color(0xFFCCCCCC),
  //     );
  //   }

  //   Widget _buildFooterInfoRow(String title, String value) {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 2.0),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // 💡 1. 왼쪽에 일정한 여백을 주어 전체 블록을 중앙 근처로 이동시킵니다.
  //           // 현재 푸터 내부 패딩이 좌우 20이므로, 시안처럼 배치하기 위해 추가 시작 여백을 줍니다.
  //           const SizedBox(width: 40),

  //           // 💡 2. 타이틀 영역에 고정 가로폭을 제공하여 시작 위치를 일치시킵니다.
  //           SizedBox(
  //             width: 115, // 타이틀(예: '통신판매업신고번호')이 잘리지 않는 최적의 너비
  //             child: Text(
  //               title,
  //               textAlign: TextAlign.left, // 💡 시안처럼 타이틀도 왼쪽 정렬
  //               style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontFamily: 'Pretendard'),
  //             ),
  //           ),

  //           // 타이틀과 값 사이의 간격
  //           const SizedBox(width: 15),

  //           // 💡 3. 실제 데이터(값) 영역
  //           Expanded(
  //             child: Text(
  //               value,
  //               textAlign: TextAlign.left, // 💡 값 영역도 왼쪽 정렬
  //               style: const TextStyle(
  //                 fontSize: 11,
  //                 color: Color(0xFF666666),
  //                 height: 1.3, // 주소처럼 줄바꿈 시 가독성을 위한 행간
  //                 fontFamily: 'Pretendard',
  //               ),
  //             ),
  //           ),

  //           // 우측의 균형을 맞추기 위한 여백 (필요에 따라 조절 가능)
  //           const SizedBox(width: 20),
  //         ],
  //       ),
  //     );
  //   }
  // 💡 인자로 effectiveBottomPadding을 받도록 수정되었습니다.
  // 💡 인자로 bottomPadding을 받도록 수정되었습니다.
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      // 💡 아래로 늘어나는 게 아니라 최하단 고정 상태이므로, 홈 화면 규격에 맞춰 상단 여백을 세팅합니다.
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

          // 3. 🎯 위쪽을 축으로 두고 사이즈 변화에 따라 위로 밀고 올라오는 상세 정보 영역
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter, // 💡 기준점을 유지하여 깔끔한 높이 변형 애니메이션 보장
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
                : const SizedBox(width: double.infinity, height: 10), // 접혔을 때의 홈 화면 기준 최소 하단 여백 공간
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
          const SizedBox(width: 40),
          SizedBox(
            width: 115,
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontFamily: 'Pretendard'),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666), height: 1.3, fontFamily: 'Pretendard'),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// 🛠️ 대문자 자동 변환용 정규 표현식 포매터 클래스
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
