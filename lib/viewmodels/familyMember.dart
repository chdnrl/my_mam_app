import 'package:get/get.dart';

class FamilyMember {
  final String id; // 주键ID (inviteId)
  final String maternalUserId; // 산모 ID
  final String? inviteeUserId; // 피초대자 ID
  final String name; // 피초대자 이름 (inviteUserName)
  final String birthDate; // 피초대자 생년월일 (birthDay)
  final String inviteCode; // 초대코드
  final String inviteePhone; // 피초대자 연락처
  final int inviteStatusCode; // 초대 상태 코드 (0:대기, 1:수락, 2:취소, 3:만료)
  final String inviteStatusName; // 초대 상태 한글/영어/외국어 명칭
  final int shareFlagCode; // 공유 여부 코드 (0:닫힘, 1:열림)

  // 화면 UI 제어 전용 상태 필드
  // 🌟 [수정] GetX 반응형 변수(.obs)로 변경하여 데이터 변경 시 해당 아이템만 실시간 리렌더링되도록 합니다.
  var isConnected = false.obs; // 접속 중 여부
  var isShared = false.obs; // 스마트 크래들 공유 여부 (shareFlagCode와 연동)
  var isCodePending =
      false.obs; // 코드 입력 대기 중 여부 (inviteStatusCode == 0 일 때 Dim 처리)

  FamilyMember({
    required this.id,
    required this.maternalUserId,
    this.inviteeUserId,
    required this.name,
    required this.birthDate,
    required this.inviteCode,
    required this.inviteePhone,
    required this.inviteStatusCode,
    required this.inviteStatusName,
    required this.shareFlagCode,
    bool isConnected = false,
    bool isShared = false,
    bool isCodePending = false,
  }) {
    // 🌟 [추가] 생성자 호출 시 전달받은 boolean 값을 GetX Rx 변수에 바인딩
    this.isConnected.value = isConnected;
    this.isShared.value = isShared;
    this.isCodePending.value = isCodePending;
  }

  // 🛠️ familyInvitationRecord API 응답 규격 맞춤 팩토리
  factory FamilyMember.fromJSON(Map<String, dynamic> json) {
    // 중첩 JSON 구조 방어 처리 ({code, name, ename})
    final statusMap = json["inviteStatus"] is Map ? json["inviteStatus"] : {};
    final shareMap = json["shareFlag"] is Map ? json["shareFlag"] : {};

    int statusCode = int.tryParse(statusMap["code"]?.toString() ?? "0") ?? 0;
    int shareCode = int.tryParse(shareMap["code"]?.toString() ?? "0") ?? 0;

    return FamilyMember(
      id: json["id"]?.toString() ?? "",
      maternalUserId: json["maternalUserId"] ?? "",
      inviteeUserId: json["inviteeUserId"],
      name: json["inviteUserName"] ?? "가족 회원",
      birthDate: json["birthDay"] ?? "",
      inviteCode: json["inviteCode"] ?? "",
      inviteePhone: json["inviteePhone"] ?? "",
      inviteStatusCode: statusCode,
      inviteStatusName: statusMap["name"] ?? statusMap["ename"] ?? "대기",
      shareFlagCode: shareCode,
      isConnected: false, // 기본값
      isShared: shareCode == 1, // 서버 데이터 연동
      isCodePending: statusCode == 0, // 0번(待接受/대기중)일 때 화면 Dim 처리
    );
  }
}
