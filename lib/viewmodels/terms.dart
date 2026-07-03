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
