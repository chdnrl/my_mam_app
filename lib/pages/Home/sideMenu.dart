import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/stores/ContractController.dart';
// 💡UserController 및 필요한 페이지들의 실제 위치에 맞게 import 경로를 확인해 주세요.
import 'package:my_mam_app/stores/UserController.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';

// 1️⃣ 사용자의 상태를 구분하는 Enum 정의
enum UserMenuStatus {
  unauthenticated, // 인증 전 (AuthScreen 상태)
  maternalAuth, // 산모 인증 완료 (입실 상태)
  familyAuth, // 가족 인증 완료
}

// 2️⃣ 메뉴 항목 데이터 모델 클래스 (GetX 라우트명 스트링 또는 Widget 클래스 모두 수용)
class MenuItemData {
  final String title;
  final String imagePath;
  final dynamic target; // String(라우트명) 또는 Widget(인스턴스) 또는 ""(미개발) 수용

  MenuItemData({required this.title, required this.imagePath, required this.target});
}

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  // 🌐 UserController 전역 인스턴스 연결
  final UserController _userController = UserController.to;

  // 3️⃣ 사용자의 현재 상태를 판단하여 Enum으로 변환하는 메서드
  UserMenuStatus _getCurrentMenuStatus() {
    if (!_userController.isAuthenticated.value) {
      return UserMenuStatus.unauthenticated;
    }
    if (_userController.isFamilyUser.value) {
      return UserMenuStatus.familyAuth;
    }
    return UserMenuStatus.maternalAuth;
  }

  // 4️⃣ 상태별 '상단 메인 메뉴 목록' Map 데이터 정의 (전달받은 실제 타겟 페이지 결합)
  Map<UserMenuStatus, List<MenuItemData>> get _statusMenuMap => {
    // 🔴 1. 인증 전 상태 메뉴 (로그인 전)
    UserMenuStatus.unauthenticated: [
      MenuItemData(
        title: "산후조리원 검색 · 예약하기",
        imagePath: "lib/assets/school_Icon.png",
        target: "/searchPage", // GetX 라우트 이름 지원
      ),
      MenuItemData(title: "산후조리원 입실하기", imagePath: "lib/assets/school_Icon.png", target: "/centerDetailPage"),
      MenuItemData(
        title: "가족코드 입력하기",
        imagePath: "lib/assets/users_2.png",
        target: "", // 💡 미개발 메뉴 차단 대상
      ),
      MenuItemData(
        title: "산후조리 할인몰",
        imagePath: "lib/assets/store.png",
        target: "", // 💡 미개발 메뉴 차단 대상
      ),
    ],

    // 🤰 2. 산모 인증 완료 상태 메뉴 (입실 회원)
    UserMenuStatus.maternalAuth: [
      MenuItemData(
        title: "계약서 보기",
        imagePath: "lib/assets/terms_Icon.png",
        target: "/contractPdfPage", // 미리 선언해 둔 계약서 보기 페이지 연동
      ),
      MenuItemData(title: "스마트 크래들 보기", imagePath: "lib/assets/contact_Icon.png", target: "/smartCradlePage"),
      if (!_userController.isFamilyUser.value)
        MenuItemData(title: "가족모드 관리", imagePath: "lib/assets/users_2.png", target: "/familyManagementPage"),
      if (!_userController.isFamilyUser.value)
        MenuItemData(title: "내 청구서 목록", imagePath: "lib/assets/invoice_Icon1.png", target: "/invoiceListPage"),
      if (!_userController.isFamilyUser.value)
        MenuItemData(title: "산후조리원 정보", imagePath: "lib/assets/school_Icon.png", target: "/careCenterDetailPage"),
    ],

    // 👨‍👩‍👧‍👦 3. 가족 인증 완료 상태 메뉴
    UserMenuStatus.familyAuth: [
      MenuItemData(title: "스마트 크래들 보기", imagePath: "lib/assets/contact_Icon.png", target: "/smartCradlePage"),
    ],
  };

  // 🎯 사이드 메뉴 전용 로그아웃 확인 창
  void _showSideMenuLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("정말 로그아웃 하시겠습니까?\n로그아웃 시 모든 데이터가 초기화됩니다."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // 다이얼로그 닫기
              await _executeSideMenuLogoutWorkflow(); // 워크플로우 가동
            },
            child: const Text(
              "확인",
              style: TextStyle(color: Color(0xFF785186), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSideMenuLogoutWorkflow() async {
    bool logoutResult = await _userController.handleServerLogout();

    if (logoutResult) {
      print("🎉 원격 서버 및 로컬 인프라 초기화 완료 (사이드 메뉴)");
      _userController.clearUserInfo();
      Get.offAllNamed('/login'); // 전체 화면 스택 제거 후 로그인 이동
    } else {
      if (mounted) {
        ToastUtils.showCustomSnackBar(context, "서버와 통신이 불안정하여 로그아웃에 실패했습니다. 다시 시도해 주세요.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final UserMenuStatus currentStatus = _getCurrentMenuStatus();
      final List<MenuItemData> dynamicMenuItems = _statusMenuMap[currentStatus] ?? [];
      final bool isFamilyUser = _userController.isFamilyUser.value;
      final bool isAuthenticated = _userController.isAuthenticated.value;

      return Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // --- 헤더 영역 (로고 및 닫기 버튼) ---
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
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF785186)),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, size: 28), onPressed: () => Get.back()),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 메인 메뉴 리스트 영역 (루프 매핑 구조) ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    // 고정 노출되는 '메인' 홈 탭 (인증 상태에 따라 타겟 분기 적용)
                    _buildMenuTile(
                      title: "메인",
                      imagePath: "lib/assets/home_Icon.png",
                      target: isAuthenticated ? "/home" : "/authScreen",
                    ),

                    // 현재 유저 상태에 맞는 동적 메뉴 타일들을 자동으로 매핑 및 출력합니다.
                    ...dynamicMenuItems.map(
                      (menu) => _buildMenuTile(title: menu.title, imagePath: menu.imagePath, target: menu.target),
                    ),
                  ],
                ),
              ),

              const Divider(indent: 20, endIndent: 20, thickness: 1, color: Color(0xFFF0F0F0)),

              // --- 하단 고정 메뉴 영역 ---
              _buildMenuTile(
                title: "내 정보",
                imagePath: "lib/assets/contact_Icon.png",
                target: "/myInfoPage", // arguments는 뒤쪽 라우팅 로직 내부에서 자동 주입되도록 수정
              ),

              // 💡 원본 요구사항 유지: 인증 완료 상태이면서 가족유저가 아닐 때만 하단에 '전체 계약서 목록' 추가 노출
              if (!isFamilyUser && isAuthenticated)
                _buildMenuTile(
                  title: "전체 계약서 목록",
                  imagePath: "lib/assets/invoice_Icon.png",
                  target: '/contractListPage',
                ),

              const Divider(indent: 20, endIndent: 20, thickness: 1, color: Color(0xFFF0F0F0)),

              // --- 최하단 고객센터 영역 ---
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "고객센터",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => print("통화 실행"),
                          child: const Text(
                            "Tel. 070-4022-7202",
                            style: TextStyle(
                              color: Color(0xFF475467),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "상담 가능시간: 9시 ~ 5시30분",
                          style: TextStyle(color: Color(0xFF667085), fontSize: 13, fontFamily: 'Pretendard'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 로그아웃 버튼 영역 ---
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 5, 25, 30),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _showSideMenuLogoutDialog(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "로그아웃",
                          style: TextStyle(color: Color(0xFF667085), fontSize: 16, fontFamily: 'Pretendard'),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.logout, color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ===========================================================================
  // 🎯 [완벽 통합된] 마이맘 고유 커스텀 스타일 타일 빌더 함수
  // ===========================================================================
  Widget _buildMenuTile({required String title, required String imagePath, required dynamic target}) {
    return ListTile(
      leading: Image.asset(
        imagePath,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.circle, size: 10),
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
      onTap: () {
        // 1. Drawer를 먼저 닫아 쾌적한 화면 전환감 제공
        Get.back();

        // 2. 미개발 메뉴 유효성 점검 및 원천 차단
        if (target == null || target == "") {
          print("[$title] 기능은 현재 개발 중입니다.");
          if (mounted) {
            ToastUtils.showCustomSnackBar(context, "준비 중인 기능입니다.");
          }
          return;
        }

        // 3. String 형식의 GetX 라우트 네임이 들어왔을 경우 처리
        if (target is String) {
          if (target == "/myInfoPage") {
            Get.toNamed(target, arguments: {"isFamilyUser": _userController.isFamilyUser.value});
          }
          // 🤰 [핵심 가동] 계약서 보기 클릭 시 라우팅 가공 및 인스턴스 안전 장치
          else if (target == "/contractPdfPage") {
            // ① 메모리에 ContractController가 등록되어 있는지 체크 후 없으면 주입(put)
            if (!Get.isRegistered<ContractController>()) {
              Get.put(ContractController());
            }

            // ② 주입되거나 찾아온 컨트롤러를 획득합니다.
            final contractCtrl = Get.find<ContractController>();

            // ③ 활성화된 계약 정보 객체 추출
            final activeInfo = contractCtrl.activeContract.value;

            // 만약 현재 로드된 정보가 없다면 방어코드용 기본 빈 값 배치
            String currentFid = activeInfo?.contractDoc ?? "";

            Get.toNamed(
              target,
              arguments: {
                "fid": currentFid, // 👈 우리가 수정한 API 스펙의 핵심인 fid 전달!
                "pdfUrl": currentFid, // 백업용 방어 코드
                "pdfName": activeInfo != null ? "${activeInfo.customerName}님 계약서" : "내 계약서",
              },
            );
          } else {
            Get.toNamed(target);
          }
        }
        // 4. Widget 인스턴스가 직접 매개변수로 들어왔을 경우 하이브리드 지원
        else if (target is Widget) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => target));
        }
      },
    );
  }
}
