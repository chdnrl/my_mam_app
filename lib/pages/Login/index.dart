import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/api/user.dart';
import 'package:my_mam_app/pages/TermsAgree/index.dart';
import 'package:my_mam_app/stores/TokenManager.dart';
import 'package:my_mam_app/stores/UserController.dart';
import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/utils/LoadingDialog.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _passWordController = TextEditingController();
  final UserController _userController = Get.find();

  // _login() async {
  //   // callLogin
  //   try {
  //     LoadingDialog.show(context, message: "로딩중...");
  //     final res = await loginAPI({
  //       "account": _idController.text,
  //       "password": _passWordController.text,
  //     });
  //     print(res); // 사용자 정보
  //     _userController.updateProfile(res);
  //     tokenManager.setToken(res.token); // 토큰유지
  //     LoadingDialog.hide(context);
  //     ToastUtils.showToast(context, "로그인 성공");
  //   } catch (e) {
  //     LoadingDialog.hide(context);
  //     ToastUtils.showToast(context, (e as DioException).message);
  //   }
  // }

  _login() async {
    // 아이디 및 패스워드 미입력 상태 예외 처리 최소 방어선
    if (_idController.text.trim().isEmpty || _passWordController.text.trim().isEmpty) {
      ToastUtils.showToast(context, "아이디와 비밀번호를 모두 입력해 주세요.");
      return;
    }

    try {
      // 1. 로그인 네트워크 인터페이스 구동
      final res = await loginAPI({"userId": _idController.text.trim(), "password": _passWordController.text.trim()});
      print("➔ [로그인 성공 응답 객체 수신]: $res");

      // 2. [가장 중요] 후속 API 실행 시 인터셉터가 토큰을 잃지 않도록 동기식(await) 하드웨어 영구 기록
      await tokenManager.setToken(res.token);

      // 3. 디오 객체의 기본 헤더 가방(Cookie)에 세션 토큰 강제 동기화
      dioRequest.setAuthCookie(res.token);
      print("🎯 [전역 인증 쿠키 주입 완료]: ${res.token}");

      // 4. 상태관리 컨트롤러 인스턴스에 로그인 기본 정보 1차 수락
      _userController.userInfo.value = res;

      // 5. 모든 세션 인프라가 갖춰진 상태에서 상세 스펙 유저 정보 동기화 가동
      print("🛰️ [유저 상세 정보 갱신 트리거 실행]");
      await _userController.fetchUserInfo();

      ToastUtils.showToast(context, "로그인에 성공하였습니다.");

      // 6. 로그인 폼 스택을 완전히 부수고 메인 홈화면으로 라우팅 이동
      Get.offAllNamed("/home");
    } catch (e) {
      // 에러 발생 시 최적의 안내 메시지 가공 처리
      String errorMsg = "로그인 처리 중 오류가 발생했습니다.";
      if (e is DioException) {
        errorMsg = e.message ?? errorMsg;
      } else {
        errorMsg = e.toString();
      }

      ToastUtils.showToast(context, errorMsg);
      print("❌ 로그인 프로세스 최종 실패: $errorMsg");
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Image.asset("lib/assets/mymam_logo_V.png"),
        const SizedBox(height: 20),
        Text(
          '산모들만을 위한 전용공간 마이맘',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF432B69),
            fontSize: 15,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildIdTextField() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "아이디를 입력하세요";
        }
        // @가 포함되어 있으면 이메일로 간주하고 체크
        if (value.contains('@')) {
          final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegExp.hasMatch(value)) return '이메일 형식이 잘못되었습니다.';
        }
        // @가 없으면 일반 아이디로 간주하고 체크
        else {
          final idRegExp = RegExp(r'^[a-zA-Z0-9_]{4,12}$');
          if (!idRegExp.hasMatch(value)) return '아이디는 4~12자 영문/숫자여야 합니다.';
        }
        return null;
      },
      controller: _idController,
      // [핵심] 유저가 입력을 시작하면 바로 검사 결과 표시
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hintText: "아이디를 입력해주세요",
        hintStyle: const TextStyle(
          color: Color(0xFFABACAD),
          fontSize: 16,
          fontFamily: 'Pretendard',
          letterSpacing: -0.32,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12), // 아이콘 주변 여백
          child: Image.asset("lib/assets/mail_Icon.png", width: 24, height: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),

        // 4. 테두리 스타일 (ShapeDecoration 부분)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC19CCB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC19CCB)), // 포커스 시 색상
        ),
        // 🚀 [추가] 에러 메시지가 떴을 때의 기본 테두리 모양 유지
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Colors.red), // 또는 기존 보라색을 원하시면 Color(0xFFC19CCB)
        ),
        // 🚀 [추가] 에러가 뜬 상태에서 입력창을 클릭(포커스)했을 때의 테두리 모양 유지
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildPassWordTextField() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "비밀번호를 입력해주세요";
        }

        if (!RegExp(r"^[a-zA-Z0-9_]{6,16}$").hasMatch(value)) {
          return "6-16자리 영문자모/숫자를 입력하세요";
        }
        return null;
      },
      controller: _passWordController,
      obscureText: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hintText: "비밀번호를 입력해주세요",
        hintStyle: const TextStyle(
          color: Color(0xFFABACAD),
          fontSize: 16,
          fontFamily: 'Pretendard',
          letterSpacing: -0.32,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12), // 아이콘 주변 여백
          child: Image.asset("lib/assets/lock_Icon.png", width: 24, height: 24),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),

        // 4. 테두리 스타일 (ShapeDecoration 부분)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC19CCB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Color(0xFFC19CCB)), // 포커스 시 색상
        ),
        // 🚀 [추가] 에러 메시지가 떴을 때의 기본 테두리 모양 유지
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
        // 🚀 [추가] 에러가 뜬 상태에서 입력창을 클릭(포커스)했을 때의 테두리 모양 유지
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity, // 부모(Padding)가 허용하는 최대 가로 너비
      height: 60,
      child: ElevatedButton(
        // onPressed: () {
        //   // 4. 버튼 클릭 시 유효성 검사 실행
        //   if (_formKey.currentState!.validate()) {
        //     // 유효성 검사 통과 시 로그인 로직 실행
        //     print('유효성 검사 통과: ${_idController.text}');
        //   } else {
        //     // 통과 실패 시 자동으로 에러 메시지가 화면에 표시됨
        //     print('검사 실패');
        //   }
        //   print('로그인 버튼 클릭!');
        // },
        onPressed: () async {
          // 1. 폼 유효성 검사 (아이디/비밀번호 정규식 통과 여부 확인)
          if (_formKey.currentState!.validate()) {
            print('유효성 검사 통과: ${_idController.text}');

            // 🚀 2. 실제 서버와 통신하는 로그인 메소드를 여기서 실행합니다!
            await _login();
          } else {
            print('검사 실패: 입력 양식을 다시 확인해 주세요.');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF785186), // 배경색
          foregroundColor: Colors.white, // 글자색 및 클릭 효과 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // 모서리 둥글기
          ),
          elevation: 0, // 입체감 제거 (디자인 시안이 평면적일 경우)
        ),
        child: const Text(
          '로그인',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600, // 버튼 글씨는 보통 두껍게 처리합니다
            letterSpacing: -0.36,
            // height: 0.07은 버튼 내부에서 텍스트를 잘리게 하므로
            // 텍스트 중앙 정렬을 위해 삭제하거나 적절히 조절하는 것이 좋습니다.
          ),
        ),
      ),
    );
  }

  bool _isRememberMe = false;
  Widget _buildCheckboxAndFindPw() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), // 좌우 끝 정렬을 위해 0으로 조정
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측: 커스텀 체크박스 + 텍스트
          GestureDetector(
            onTap: () {
              setState(() {
                _isRememberMe = !_isRememberMe; // 상태 반전
              });
              print(_isRememberMe);
            },
            // 클릭 영역 확장을 위해 투명 배경 설정
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                // --- 동적 체크박스 디자인 ---
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 체크 시 보라색 배경, 미체크 시 흰색 배경
                    color: _isRememberMe ? const Color(0xFF785186) : Colors.white,
                    border: Border.all(
                      color: _isRememberMe ? const Color(0xFF785186) : const Color(0xFF7C7C7C),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    // 체크 시 흰색 아이콘, 미체크 시 투명(또는 회색)
                    color: _isRememberMe ? Colors.white : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '로그인 상태 유지',
                  style: TextStyle(color: Color(0xFF4B4C4C), fontSize: 14, fontFamily: 'Pretendard'),
                ),
              ],
            ),
          ),

          // 우측: ID/PW 찾기
          InkWell(
            onTap: () => print("찾기 페이지 이동"),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Text(
                'ID/PW 찾기',
                style: TextStyle(color: Color(0xFF4B4C4C), fontSize: 14, fontFamily: 'Pretendard'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SignUpButtonDesign(
          context: context,
          subTitle: '산후조리 입실하시는 산모님이신가요?',
          title: '계정 만들기',
          // 🎯 userType 1 (산모) 주입하여 이동
          onTap: () => Get.toNamed("/termsAgree", arguments: {"userType": 1, "gender": 0}),
        ),
        const SizedBox(height: 16),
        _SignUpButtonDesign(
          context: context,
          subTitle: '산모님의 초대를 받고 오셨나요?',
          title: '초대 코드 입력하기',
          // 🎯 userType 2 (가족/보호자) 주입하여 이동
          onTap: () => Get.toNamed("/termsAgree", arguments: {"userType": 2, "gender": 1}),
        ),
      ],
    );
  }

  Widget _SignUpButtonDesign({
    required BuildContext context,
    required String subTitle,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      // [중요 1] 배경색은 반드시 여기에만 있어야 합니다.
      color: const Color(0xFFFDFDFD),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias, // 테두리에 맞춰 물결을 깎음
      child: InkWell(
        onTap: onTap, // 클릭 이벤트
        // [중요 2] 최신 문법 적용 및 색상 명시
        splashColor: const Color(0xFF785186).withValues(alpha: 0.1),
        highlightColor: const Color(0xFF785186).withValues(alpha: 0.05),
        child: Container(
          width: double.infinity,
          height: 60,
          // [중요 3] 여기에는 'color' 속성이 절대 있으면 안 됩니다!
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1.0, color: const Color(0xFF785186)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subTitle,
                style: const TextStyle(
                  color: Color(0xFF785186),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Pretendard',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF785186),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SafeArea(
          // child: IndexedStack(
          // children: [
          child:
              // 화면 높이를 계산하기 위해 LayoutBuilder를 사용합니다.
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      // 화면에 내용이 적어도 최소한 전체 화면 높이만큼 차지하게 합니다.
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      // Column 안에서 Spacer를 쓰기 위해 높이를 동적으로 계산합니다.
                      child: IntrinsicHeight(
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 40),
                              _buildIdTextField(),
                              const SizedBox(height: 10),
                              _buildPassWordTextField(),
                              const SizedBox(height: 10),
                              _buildLoginButton(),
                              const SizedBox(height: 10),
                              _buildCheckboxAndFindPw(),
                              // --- 이 Spacer가 위쪽 위젯들을 다 밀어내고 ---
                              // --- 아래 버튼을 화면 최하단으로 보냅니다. ---
                              const Spacer(),
                              const SizedBox(height: 40), // 버튼 위쪽 최소 여백
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).padding.bottom,
                                  left: 0,
                                  right: 0,
                                ),
                                // 이전에 만든 가로 꽉 차는 버튼 함수 호출
                                child: _buildSignUpButton(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          // ],
        ),
      ),
      // ),
    );
  }
}
