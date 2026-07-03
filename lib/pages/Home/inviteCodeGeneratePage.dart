import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';
import 'package:my_mam_app/stores/UserController.dart';

class InviteCodeGeneratePage extends StatefulWidget {
  const InviteCodeGeneratePage({super.key});

  @override
  State<InviteCodeGeneratePage> createState() => _InviteCodeGeneratePageState();
}

class _InviteCodeGeneratePageState extends State<InviteCodeGeneratePage> {
  final TextEditingController _phoneController = TextEditingController();
  final UserController _userController = UserController.to;

  @override
  void initState() {
    super.initState();
    // 🌐 [1] 화면 진입 시: Java단을 호출(현재는 가상함수)하여 초대 코드 선 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userController.fetchInitialInviteCode();
    });
  }

  // 🎯 [2] 버튼 클릭 시: 입력창의 번호를 가지고 실제 명세서 POST API를 쏘는 함수
  void _sendInviteToKakao() async {
    String inviteePhone = _phoneController.text.trim();

    // 유효성 검사
    if (inviteePhone.isEmpty) {
      ToastUtils.showCustomSnackBar(context, "초대할 휴대전화 번호를 입력해주세요.");
      return;
    }

    if (_userController.isLoading.value) return; // 중복 클릭 방지

    // UserController를 통해 Java 백엔드로 CreateFamilyInvitation 커맨드 발사
    bool isApiSuccess = await _userController.submitFamilyInvitation(
      inviteePhone,
    );

    if (isApiSuccess) {
      // 1. 메인 화면으로 이동하여 이전 적층 스택 일괄 파괴
      Navigator.of(context).popUntil((route) => route.isFirst);

      // 2. 이동 직후, 메인 화면 하단에 보라색 성공 알람 노출
      ToastUtils.showCustomSnackBar(
        context,
        "초대코드가 성공적으로 발송되었습니다.",
        isError: false,
      );
    } else {
      ToastUtils.showCustomSnackBar(context, "초대코드 전송에 실패했습니다. 다시 시도해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "초대 코드 발급하기",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                "lib/assets/family_Image.png",
                width: MediaQuery.of(context).size.width * 0.75,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.family_restroom,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SvgPicture.asset(
              'lib/assets/logo_mymam.svg',
              width: 180,
              errorBuilder: (context, error, stackTrace) => const Text(
                "MYMAM",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF785186),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "일회용 마이맘 가족모드 인증코드",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "초대한 핸드폰에서 회원가입한 후 발급된 초대코드를 가족\n모드 코드 입력란에 입력하세요.\n추가로 초대하려면 '추가로 초대하기' 버튼을 누르세요.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 15),

            // 🚀 Obx 바인더: 화면 진입 시 비동기로 받아온 코드가 이곳에 노출됩니다.
            Obx(() {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF785186),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFFAFAFA),
                ),
                child:
                    _userController.isLoading.value &&
                        _userController.generatedInviteCode.value == "불러오는 중..."
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF785186),
                          ),
                        ),
                      )
                    : Text(
                        _userController.generatedInviteCode.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                          letterSpacing: 2.0,
                        ),
                      ),
              );
            }),

            const SizedBox(height: 15),
            const Divider(thickness: 1, color: Color(0xFFEFEFEF)),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: "산모님이 초대할 ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "휴대전화 번호",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF785186),
                    ),
                  ),
                  TextSpan(text: "를 입력하세요.\n입력된 번호로 초대코드가 발송됩니다."),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📱 핸드폰 번호 입력창 (이 값이 명세서의 inviteePhone으로 전달됨)
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // 숫자만 기입 유도
              ],
              decoration: InputDecoration(
                hintText: "초대할 전화번호 입력",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF785186)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF785186),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 추가로 초대하기 버튼
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF785186),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "추가로 초대하기",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // 🎯 카카오톡으로 초대 코드 발송하기 버튼 (명세서 API 연동 본체)
            ElevatedButton(
              onPressed: _sendInviteToKakao,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF785186),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "카카오톡으로 초대 코드 발송하기",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
