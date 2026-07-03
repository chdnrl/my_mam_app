import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/api/user.dart';
import 'package:my_mam_app/pages/Home/index.dart';
import 'package:my_mam_app/stores/TokenManager.dart';
import 'package:my_mam_app/stores/UserController.dart';
import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';

// 가입 완료 화면
class SignUpCompletePage extends StatefulWidget {
  const SignUpCompletePage({super.key});

  @override
  State<SignUpCompletePage> createState() => _SignUpCompletePageState();
}

class _SignUpCompletePageState extends State<SignUpCompletePage> {
  bool _isAutoLoginChecked = true;
  bool _isProcessLoading = false; // 자동 로그인 통신 인디케이터용

  /// 🎯 가입 완료 직후 원터치 자동 통신 로그인 게이트웨이
  Future<void> _executeDirectLogin() async {
    // 1. 이전 화면(SignUpInfoPage)에서 라우팅아규먼트로 넘겨준 계정 정보 획득
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    if (args == null || args['userId'] == null || args['password'] == null) {
      // 혹시 데이터 유실 시 정석적으로 안전하게 홈(혹은 로그인 화면)으로 대피
      Get.offAllNamed("/home");
      return;
    }

    try {
      setState(() => _isProcessLoading = true);

      if (_isAutoLoginChecked) {
        print("🛰️ [자동로그인 가동] 계정: ${args['userId']}");

        // 2. 로그인 API 연동구현
        final res = await loginAPI({
          "userId": args['userId'],
          "password": args['password'],
        });

        // 3. 세션 주머니 저장소 물리 하드웨어 영구 동기화
        await tokenManager.setToken(res.token);
        dioRequest.setAuthCookie(res.token);

        // 4. 전역 공유 싱글톤 상태 수집기에 주입
        UserController.to.userInfo.value = res;

        // 🎯 [완벽 수정]: 백엔드 명세 변경에 따라 인자(args['userId'])를 보내지 않고 호출합니다.
        await UserController.to.fetchUserInfo();

        if (mounted) {
          ToastUtils.showCustomSnackBar(
            context,
            "자동 로그인에 성공했습니다.",
            isError: false,
          );
        }
      }
    } catch (e) {
      print("⚠️ [자동로그인 우회 인지] 세션 주입 오류로 인해 수동 로그인을 유도합니다: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessLoading = false);
      }
      // 5. 무조건 메인 스택을 전부 파괴하고 홈 화면 배치 이동
      Get.offAllNamed("/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "가입 완료",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFF785186),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 65),
          ),
          const SizedBox(height: 40),
          const Text(
            "회원가입이 완료되었습니다.",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "로그인 버튼을 눌러 이용해주세요.",
            style: TextStyle(color: Color(0xFF999999), fontSize: 16),
          ),
          const Spacer(flex: 3),

          GestureDetector(
            onTap: () {
              if (_isProcessLoading) return;
              setState(() => _isAutoLoginChecked = !_isAutoLoginChecked);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isAutoLoginChecked
                          ? const Color(0xFF785186)
                          : const Color(0xFFCCCCCC),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 18,
                    color: _isAutoLoginChecked
                        ? const Color(0xFF785186)
                        : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "다음부터 접속 시 자동 로그인하겠습니다.",
                  style: TextStyle(
                    color: Color(0xFF785186),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessLoading
                    ? null
                    : _executeDirectLogin, // 🎯 원터치 로그인 게이트 바인딩
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF785186),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "로그인하기",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
