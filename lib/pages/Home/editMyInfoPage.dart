import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/stores/UserController.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';
import 'package:my_mam_app/viewmodels/user.dart'; // UserInfo 모델 패키지 경로 확인

class EditMyInfoPage extends StatefulWidget {
  const EditMyInfoPage({super.key});

  @override
  State<EditMyInfoPage> createState() => _EditMyInfoPageState();
}

class _EditMyInfoPageState extends State<EditMyInfoPage> {
  // 컨트롤러를 미리 찾아옵니다.
  final controller = UserController.to.userInfo.value;

  late TextEditingController _idController;
  late TextEditingController _oldPwController;
  late TextEditingController _pwController;
  late TextEditingController _pwConfirmController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedDay;

  @override
  void initState() {
    super.initState();

    final userData = controller;

    // 데이터 초기화 매핑 (안전하게 방어 코드 결합)
    _idController = TextEditingController(text: userData?.userId ?? "");
    _oldPwController = TextEditingController();
    _pwController = TextEditingController();
    _pwConfirmController = TextEditingController();
    _nameController = TextEditingController(
      text: userData?.nickname ?? userData?.userName ?? "",
    );
    _phoneController = TextEditingController(
      text: userData?.mobile ?? userData?.telephone ?? "",
    );

    _addressController = TextEditingController(text: userData?.address);

    // 생년월일 분리 가공
    if (userData != null && userData.birthday.contains("-")) {
      List<String> birthParts = userData.birthday.split("-");
      if (birthParts.length == 3) {
        _selectedYear = birthParts[0];
        _selectedMonth = birthParts[1];
        _selectedDay = birthParts[2];
      }
    } else {
      _selectedYear = userData?.birthYear.isNotEmpty == true
          ? userData?.birthYear
          : "1994";
      _selectedMonth = userData?.birthMonth.isNotEmpty == true
          ? userData?.birthMonth
          : "12";
      _selectedDay = userData?.birthDay.isNotEmpty == true
          ? userData?.birthDay
          : "20";
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _oldPwController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Map<String, bool> _fieldErrors = {
    'oldPw': false,
    'pw': false,
    'pwConfirm': false,
    'name': false,
    'phone': false,
    'birth': false,
    'address': false,
  };

  bool _isValidPw(String pw) {
    if (pw.isEmpty) return true;
    // 영문, 숫자 포함 8자 이상 검증 정규식
    final pwRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return pwRegExp.hasMatch(pw);
  }

  void _handleUpdate() async {
    // async 추가
    final String oldPw = _oldPwController.text;
    final String newPw = _pwController.text;
    final String confirmPw = _pwConfirmController.text;

    setState(() {
      // 1. 비밀번호 필드 유효성 파싱 검사
      if (newPw.isNotEmpty) {
        _fieldErrors['oldPw'] = oldPw.isEmpty; // 새 암호 바꿀 거면 기존 암호 필수
        _fieldErrors['pw'] = !_isValidPw(newPw);
        _fieldErrors['pwConfirm'] = newPw != confirmPw;
      } else {
        _fieldErrors['oldPw'] = false;
        _fieldErrors['pw'] = false;
        _fieldErrors['pwConfirm'] = false;
      }

      _fieldErrors['name'] = _nameController.text.isEmpty;
      _fieldErrors['phone'] = _phoneController.text.isEmpty;
      _fieldErrors['address'] = _addressController.text.isEmpty;
    });

    if (newPw.isNotEmpty && _fieldErrors['oldPw'] == true) {
      ToastUtils.showCustomSnackBar(context, "기존 비밀번호를 입력해야 변경이 가능합니다.");
      return;
    }
    if (newPw.isNotEmpty && _fieldErrors['pwConfirm'] == true) {
      ToastUtils.showCustomSnackBar(context, "새 비밀번호가 서로 일치하지 않습니다.");
      return;
    }
    if (_fieldErrors.values.contains(true)) {
      ToastUtils.showCustomSnackBar(context, "정보를 정확히 입력해주세요.");
      return;
    }

    // 🚀 [비즈니스 분기 체인 가동]
    // Case A: 사용자가 비밀번호를 입력한 경우 -> 비밀번호 변경 API를 먼저 찌름
    if (newPw.isNotEmpty) {
      bool pwSuccess = await UserController.to.updatePassword(
        oldPassword: oldPw,
        newPassword: newPw,
      );

      if (!pwSuccess) {
        ToastUtils.showCustomSnackBar(context, "기존 비밀번호가 틀렸거나 변경에 실패했습니다.");
        return; // 비밀번호 오류 나면 더 이상 전진 안 함
      }
    }

    final updatedInfo = UserController.to.userInfo.value?.copyWith(
      nickname: _nameController.text,
      userName: _nameController.text,
      mobile: _phoneController.text,
      telephone: _phoneController.text,
      birthday: "$_selectedYear-$_selectedMonth-$_selectedDay",
      address: _addressController.text,
    );

    if (updatedInfo != null) {
      _performUpdate(updatedInfo);
    }
  }

  // 실제 비동기 API 통신 및 화면 흐름 제어 단일화
  Future<void> _performUpdate(UserInfo updatedInfo) async {
    bool success = await UserController.to.updateProfile(updatedInfo);

    if (success) {
      // 🎉 [보안 강화] 통신 성공 즉시 메모리 변수들을 물리적으로 비워버림
      _oldPwController.clear();
      _pwController.clear();
      _pwConfirmController.clear();
      ToastUtils.showCustomSnackBar(context, "정보 수정이 완료되었습니다.", isError: false);
      Get.back(); // 통신 엔진 응답이 정상 성공(200)일 때만 마이페이지로 안전하게 라우팅 복귀
    } else {
      ToastUtils.showCustomSnackBar(context, "수정에 실패했습니다. 다시 시도해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "내 정보 수정",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("아이디"),
                _buildTextField(
                  _idController,
                  "",
                  isReadOnly: true, // 아이디는 시스템 고정이므로 수정 불가 유지
                ),
                const SizedBox(height: 25),

                // 비밀번호 변경용 인증 사슬 구축
                _buildLabel("현재 비밀번호 (비밀번호 변경 시 필수)"),
                _buildTextField(
                  _oldPwController,
                  "현재 사용 중인 비밀번호를 입력하세요",
                  isObscure: true,
                  isError: _fieldErrors['oldPw'] ?? false,
                ),
                const SizedBox(height: 25),

                _buildLabel("새 비밀번호 (변경 시에만 입력)"),
                _buildTextField(
                  _pwController,
                  "새 비밀번호를 입력해주세요",
                  isObscure: true,
                  isError: _fieldErrors['pw'] ?? false,
                ),
                const SizedBox(height: 25),

                _buildLabel("새 비밀번호 확인"),
                _buildTextField(
                  _pwConfirmController,
                  "새 비밀번호를 한 번 더 입력해주세요",
                  isObscure: true,
                  isError: _fieldErrors['pwConfirm'] ?? false,
                ),
                const SizedBox(height: 25),

                _buildLabel("이름"),
                _buildTextField(
                  _nameController,
                  "이름을 입력해주세요",
                  isError: _fieldErrors['name'] ?? false,
                ),
                const SizedBox(height: 25),

                _buildLabel("휴대폰 번호"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _phoneController,
                        "휴대폰 번호",
                        isError: _fieldErrors['phone'] ?? false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSideButton("인증번호 전송", () {}),
                  ],
                ),
                const SizedBox(height: 25),

                _buildLabel("생년월일"),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        List.generate(
                          80,
                          (i) => (2026 - i).toString(),
                        ), // 2026년 기준 대응 가속화
                        _selectedYear,
                        (v) => setState(() => _selectedYear = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        List.generate(
                          12,
                          (i) => (i + 1).toString().padLeft(2, '0'),
                        ),
                        _selectedMonth,
                        (v) => setState(() => _selectedMonth = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        List.generate(
                          31,
                          (i) => (i + 1).toString().padLeft(2, '0'),
                        ),
                        _selectedDay,
                        (v) => setState(() => _selectedDay = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                _buildLabel("주소"),
                Row(
                  children: [
                    _buildSideButton("주소 검색", () {}),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        _addressController,
                        "주소 입력",
                        isError: _fieldErrors['address'] ?? false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 하단 고정 플로팅 수정하기 레이아웃 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF785186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "수정하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isObscure = false,
    bool isError = false,
    bool isReadOnly = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
        filled: true,
        fillColor: isReadOnly
            ? const Color(0xFFF0F0F0)
            : const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xFFEEEEEE),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.red : const Color(0xFF785186),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFBBBBBB)),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildSideButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF785186)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF785186),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
