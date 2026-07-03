import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';
import 'package:dio/dio.dart';
import 'package:my_mam_app/api/user.dart';
import 'dart:io';
import 'package:my_mam_app/api/clientInfo.dart';

class SignUpInfoPage extends StatefulWidget {
  const SignUpInfoPage({super.key});

  @override
  State<SignUpInfoPage> createState() => _SignUpInfoPageState();
}

class _SignUpInfoPageState extends State<SignUpInfoPage> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedYear = "1990";
  String? _selectedMonth = "04";
  String? _selectedDay = "11";

  bool _isIdDuplicate = false;
  bool _isIdChecked = false;
  bool _isNetworkLoading = false;

  Map<String, bool> _fieldErrors = {
    'id': false,
    'pw': false,
    'pwConfirm': false,
    'name': false,
    'phone': false,
    'birth': false,
    'address': false,
  };

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _isValidId(String id) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final idRegExp = RegExp(r'^[a-zA-Z0-9]{4,12}$');
    return emailRegExp.hasMatch(id) || idRegExp.hasMatch(id);
  }

  bool _isValidPw(String pw) {
    final pwRegExp = RegExp(r'^\d{8,}$');
    return pwRegExp.hasMatch(pw);
  }

  Future<void> _checkIdDuplication() async {
    final id = _idController.text.trim();
    if (id.isEmpty || !_isValidId(id)) {
      setState(() => _fieldErrors['id'] = true);
      ToastUtils.showCustomSnackBar(context, "올바른 아이디 형식을 입력해주세요.");
      return;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isIdChecked = true;
      _isIdDuplicate = (id == "admin");
      _fieldErrors['id'] = _isIdDuplicate;
      _isIdDuplicate
          ? ToastUtils.showCustomSnackBar(context, "중복된 아이디가 존재합니다.")
          : ToastUtils.showCustomSnackBar(
              context,
              "사용 가능한 아이디입니다.",
              isError: false,
            );
    });
  }

  /// 🎯 백엔드 패킷 전송 비동기 핸들러
  void _handleNextStep() async {
    if (_isNetworkLoading) return;

    setState(() {
      _fieldErrors['id'] =
          !_isValidId(_idController.text) || (_isIdChecked && _isIdDuplicate);
      _fieldErrors['pw'] = !_isValidPw(_pwController.text);
      _fieldErrors['pwConfirm'] =
          _pwController.text != _pwConfirmController.text;
      _fieldErrors['name'] = _nameController.text.isEmpty;
      _fieldErrors['phone'] = _phoneController.text.isEmpty;
      _fieldErrors['address'] = _addressController.text.isEmpty;
      _fieldErrors['birth'] =
          _selectedYear == null ||
          _selectedMonth == null ||
          _selectedDay == null;
    });

    if (_fieldErrors['pwConfirm'] == true && _pwController.text.isNotEmpty) {
      ToastUtils.showCustomSnackBar(context, "비밀번호가 서로 일치하지 않습니다.");
      return;
    }

    if (_fieldErrors.values.contains(true)) {
      ToastUtils.showCustomSnackBar(context, "입력되지 않았거나 잘못된 정보가 있습니다.");
      return;
    }

    if (!_isIdChecked) {
      ToastUtils.showCustomSnackBar(context, "아이디 중복 확인을 해주세요.");
      return;
    }

    try {
      setState(() => _isNetworkLoading = true);

      String formattedBirthday = "$_selectedYear-$_selectedMonth-$_selectedDay";

      int serviceTermsSigned = Get.arguments?["serviceTermsSigned"] ?? 2;
      int deviceTermsSigned = Get.arguments?["deviceTermsSigned"] ?? 2;
      int privacyPolicySigned = Get.arguments?["privacyPolicySigned"] ?? 2;
      int userType = Get.arguments?["userType"] ?? 0;
      int gender = Get.arguments?["gender"] ?? 0;
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      // =======================================================================
      // 🚀 [IP 수집 로직 교체 및 이원화 적용 완료]
      // =======================================================================

      // [방법 1] 외부 파일에 선언된 공인 IP 에코 API 호출 방식 (현재 활성화)
      // 전 세계 어디서든 유저가 접속한 실제 외부 '공인 IP'를 완벽하게 따옵니다.
      String extractedIp = await getClientIpAddress();

      // [방법 2] 내부 인터페이스 기반 로컬/가상 IP 추출 방식 (현재 비활성화)
      // 만약 외부 API 호출 없이 기기 자체 IP 정보만 백엔드로 던지려면 방법 1을 지우고 아래 주석을 푸세요.
      // String extractedIp = await getInternalIpAddress();

      // =======================================================================

      // 🎯 [clientInfo.dart에서 분리한 함수 호출]: 동적 디바이스 정보 수집
      String dynamicDeviceInfo = await getMobileDeviceInfo();

      Map<String, dynamic> requestBody = {
        "userId": _idController.text.trim(),
        "userName": _nameController.text.trim(),
        "password": _pwController.text.trim(),
        "telephone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        "birthday": formattedBirthday,

        "signIp": extractedIp, // 할당된 IP 주입
        "serviceTermsSigned": serviceTermsSigned,
        "deviceTermsSigned": deviceTermsSigned,
        "privacyPolicySigned": privacyPolicySigned,

        "estimatedDueDate": formattedDate,
        "fileId": "1f750a6c44a14676be5335c8e99a53c45",
        "babyName": "찰떡이",
        "deviceInfo": dynamicDeviceInfo,

        "userType": userType,
        "gender": gender,
      };

      print("🛰️ [회원가입 요청 데이터 구조 패킹]: $requestBody");

      bool isSuccess = await registerUserAPI(requestBody);

      if (isSuccess) {
        Get.toNamed(
          "/signUpComplete",
          arguments: {
            "userId": _idController.text.trim(),
            "password": _pwController.text.trim(),
          },
        );
      }
    } catch (e) {
      String errMsg = "회원가입 처리 중 실패했습니다.";
      if (e is DioException) errMsg = e.message ?? errMsg;
      ToastUtils.showCustomSnackBar(context, errMsg);
    } finally {
      setState(() => _isNetworkLoading = false);
    }
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isObscure = false,
    bool isError = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
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
    ValueChanged<String?> onChanged, {
    bool isError = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red : const Color(0xFFEEEEEE),
        ),
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
          "내 정보 입력",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // (생략된 기존 UI 레이아웃 코드는 이전과 완전히 동일합니다)
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("아이디"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _idController,
                        "사용하실 아이디를 입력해주세요",
                        isError: _fieldErrors['id'] ?? false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSideButton("중복확인", _checkIdDuplication),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel("비밀번호"),
                _buildTextField(
                  _pwController,
                  "비밀번호를 입력해주세요",
                  isObscure: true,
                  isError: _fieldErrors['pw'] ?? false,
                ),
                const SizedBox(height: 20),
                _buildLabel("비밀번호 확인"),
                _buildTextField(
                  _pwConfirmController,
                  "비밀번호를 한번 더 입력해주세요",
                  isObscure: true,
                  isError: _fieldErrors['pwConfirm'] ?? false,
                ),
                const SizedBox(height: 20),
                _buildLabel("이름"),
                _buildTextField(
                  _nameController,
                  "이름을 입력해주세요",
                  isError: _fieldErrors['name'] ?? false,
                ),
                const SizedBox(height: 20),
                _buildLabel("휴대폰 번호"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _phoneController,
                        "휴대폰 번호를 입력해주세요",
                        isError: _fieldErrors['phone'] ?? false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildSideButton("인증번호 전송", () {}),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel("생년월일"),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        List.generate(80, (i) => (2026 - i).toString()),
                        _selectedYear,
                        (v) => setState(() => _selectedYear = v),
                        isError: _fieldErrors['birth'] ?? false,
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
                        isError: _fieldErrors['birth'] ?? false,
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
                        isError: _fieldErrors['birth'] ?? false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                  onPressed: _handleNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF785186),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isNetworkLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "다음",
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
}
