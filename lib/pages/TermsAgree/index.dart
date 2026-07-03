import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/pages/SignUp/index.dart';

// 1. 약관 데이터 모델 (에러 방지를 위한 Null Safety 강화)
class Term {
  final int id;
  final String title;
  final String content;
  bool isAgreed;

  Term({
    required this.id,
    required this.title,
    required this.content,
    this.isAgreed = false,
  });

  // 서버 JSON 데이터를 안전하게 변환하는 팩토리 생성자
  factory Term.fromJSON(Map<String, dynamic> json) {
    return Term(
      id: json["id"] is int
          ? json["id"]
          : int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
      title: json["title"]?.toString() ?? "",
      content: json["content"]?.toString() ?? "",
      isAgreed: false, // 초기값은 항상 false
    );
  }
}

class TermsAgreementPage extends StatefulWidget {
  const TermsAgreementPage({super.key});

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  late Future<List<Term>> _termsFuture;
  List<Term>? _loadedTerms; // 실제 화면에서 사용할 상태 데이터

  @override
  void initState() {
    super.initState();
    _termsFuture = _fetchTerms();
  }

  Future<List<Term>> _fetchTerms() async {
    // 실제 환경에서는 여기서 http 통신을 하고 Term.fromJSON으로 매핑합니다.
    await Future.delayed(const Duration(milliseconds: 1000));
    const String maternityServiceTerms = '''
모자보건법 제 15조의4제3호 및 제4호에 따라 임산부나 영유아에게 감염 또는 질병이 의심되거나 발생하여 의료기관으로 이송된 경우, 임산부 또는 보호자는 감염 또는 질병의 확산방지를 위하여 그 진단결과를 산후조리원에 알려야 한다는 사실을 안내 받았습니다.

산후조리원은 의료기관이 아닙니다. 산후조리원은 다중이용시설로서 의료행위를 하지 않습니다.

산모와 보호자, 신생아는 입실 시 감염의 우려가 있는 전염성 질환 (감기, 장염, B형 간염, 대상포진, 결핵 등)이나, 선천성(유전학적) 이상 및 특이체질 등에 대해 정확히 알려야 하며 건강 상태에 따라서 일부 입실 제한, 모자동실, 격리실 관찰 등의 조치가 있을 수 있습니다. (입실 당일에는 모자동실이나 격리실 관찰)

귀중품 및 금전 관리는 산모 또는 보호자가 하며, 문제 발생시 책임은 산모 또는 보호자가 Burns.

면회는 남편분만 가능하십니다.

산모와 신생아의 건강과 쾌적한 환경을 위하여 본 원에서 권하는 규칙과 일정을 준수하셔서 생활하여 주십시오.

산모를 포함한 보호자나 방문자가 불합리하다고 판단되는 언행(음주, 흡연, 고성방가, 무단 외출 등)을 할 때에는 행동의 제지와 퇴실 요청을 할 수 있습니다.''';
    return [
      Term(id: 1, title: "마이맘 이용약관 동의", content: maternityServiceTerms),
      Term(id: 2, title: "산후조리원 이용약관 동의", content: maternityServiceTerms),
      Term(id: 3, title: "개인정보 수집 동의", content: maternityServiceTerms),
    ];
  }

  Widget _buildTermItem(Term term) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              _buildCircleCheckIcon(term.isAgreed),
              const SizedBox(width: 12),
              Text(
                term.title,
                style: const TextStyle(
                  color: Color(0xFF785186),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: _buildContentBadge(),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                term.content,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("위의 약관에 동의하십니까?", style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  _buildRadioOption("동의함", true, term),
                  const SizedBox(width: 10),
                  _buildRadioOption("동의안함", false, term),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleCheckIcon(bool checked) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? const Color(0xFF785186) : Colors.white,
        border: Border.all(
          color: checked ? const Color(0xFF785186) : const Color(0xFFCCCCCC),
        ),
      ),
      child: Icon(
        Icons.check,
        size: 14,
        color: checked ? Colors.white : const Color(0xFFCCCCCC),
      ),
    );
  }

  Widget _buildRadioOption(String text, bool value, Term term) {
    bool isSelected = (term.isAgreed == value);
    return GestureDetector(
      onTap: () {
        setState(() {
          term.isAgreed = value;
        });
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: isSelected
                ? const Color(0xFF785186)
                : const Color(0xFFCCCCCC),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF785186)),
      ),
      child: const Text(
        "내용확인",
        style: TextStyle(
          color: Color(0xFF785186),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    final Map<String, dynamic>? args = Get.arguments;
    final int userType = args?['userType'] ?? 0;
    final int gender = args?['gender'] ?? 0;
    bool allAgreed = _loadedTerms?.every((t) => t.isAgreed) ?? false;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: allAgreed
                ? () {
                    // 🎯 [수정] 자바 백엔드용 약관 동의 코드화 핸들링 (동의: 1, 미동의: 2)
                    int serviceTermsSigned =
                        (_loadedTerms?.firstWhere((t) => t.id == 1).isAgreed ??
                            false)
                        ? 1
                        : 2;
                    int deviceTermsSigned =
                        (_loadedTerms?.firstWhere((t) => t.id == 2).isAgreed ??
                            false)
                        ? 1
                        : 2;
                    int privacyPolicySigned =
                        (_loadedTerms?.firstWhere((t) => t.id == 3).isAgreed ??
                            false)
                        ? 1
                        : 2;

                    // 🎯 [수정] 주입에 필요한 약관 변수들을 다음 회원가입 정보 입력 폼 화면으로 상속 연동
                    Get.toNamed(
                      "/signUp",
                      arguments: {
                        "serviceTermsSigned": serviceTermsSigned,
                        "deviceTermsSigned": deviceTermsSigned,
                        "privacyPolicySigned": privacyPolicySigned,
                        "userType": userType,
                        "gender": gender,
                      },
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF785186),
              disabledBackgroundColor: const Color(
                0xFF785186,
              ).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "동의",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          "서비스 이용 약관",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Term>>(
        future: _termsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _loadedTerms == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF785186)),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("데이터 로딩 에러 발생"));
          }

          // 데이터를 처음 불러왔을 때만 상태 변수에 저장
          if (snapshot.hasData && _loadedTerms == null) {
            _loadedTerms = snapshot.data;
          }

          if (_loadedTerms == null || _loadedTerms!.isEmpty) {
            return const Center(child: Text("표시할 약관이 없습니다."));
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                itemCount: _loadedTerms!.length,
                itemBuilder: (context, index) =>
                    _buildTermItem(_loadedTerms![index]),
              ),
              _buildBottomButton(),
            ],
          );
        },
      ),
    );
  }
}
