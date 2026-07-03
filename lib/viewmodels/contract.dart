class ContractModel {
  final String id;
  final String maternalUserId;
  final String contractId; //API 전환 기능의 핵심 키
  final String resId;
  final String gid;
  final String pid;
  final String sdate; // 시작일
  final String edate; // 종료일
  final String period; // 조리원 이용 기간 (예: 2주)
  final String contractDoc;
  final String cfDate;
  final String ctDate;
  final String sysCid;
  final String idate;
  final int totalMoney; // 총금액
  final String status; // 계약 상태
  final String curVer;
  final String customerCode;
  final String customerName; // 산모 이름
  final String birth; // 아기 생일 혹은 산모 생일
  final String contractDate; // 계약일
  final String roomId;
  final String roomNo; // 방 번호 (호실)
  final String roomLevel;
  final String roomLevelName; // 방 등급 명칭 (예: VIP실, 일반실)
  final String onlineDocId;
  final String signType;
  final String payStatus; // 결제 상태
  final String signStatus; // 서명 상태
  final String payAccount;
  final String mobilePhone; // 연락처
  final String email;
  final String pmSrv;
  final String ctype;
  final String signReqUid;
  final String discAmt;
  final String signName;
  final String sreqId;
  final String memo;
  final String? activateDt;
  final String? rPaidAmt;
  final String? aesthPaidAmt;
  final String? retAmt;

  // 앱 UI 렌더링 전용 확장 상태변수들
  final bool isCurrentIn; // 현재 조리원 입실 완료 상태 여부
  final bool isSelected; // 여러 계약 중 사용자가 현재 메인으로 선택한 계약 여부

  ContractModel({
    required this.id,
    required this.maternalUserId,
    required this.contractId,
    required this.resId,
    required this.gid,
    required this.pid,
    required this.sdate,
    required this.edate,
    required this.period,
    required this.contractDoc,
    required this.cfDate,
    required this.ctDate,
    required this.sysCid,
    required this.idate,
    required this.totalMoney,
    required this.status,
    required this.curVer,
    required this.customerCode,
    required this.customerName,
    required this.birth,
    required this.contractDate,
    required this.roomId,
    required this.roomNo,
    required this.roomLevel,
    required this.roomLevelName,
    required this.onlineDocId,
    required this.signType,
    required this.payStatus,
    required this.signStatus,
    required this.payAccount,
    required this.mobilePhone,
    required this.email,
    required this.pmSrv,
    required this.ctype,
    required this.signReqUid,
    required this.discAmt,
    required this.signName,
    required this.sreqId,
    required this.memo,
    this.activateDt,
    this.rPaidAmt,
    this.aesthPaidAmt,
    this.retAmt,
    this.isCurrentIn = false,
    this.isSelected = false,
  });

  // UI 표현에 용이하도록 가공 데이터를 가상 게터(Getter)로 제공
  String get centerName => "산후조리원";
  String get roomInfo => "$roomLevelName ($roomNo호)";

  // 🛠️ Java 서버 응답에서 혹시 모를 String-int 불일치 에러를 완벽 차단하는 팩토리
  factory ContractModel.fromJSON(Map<String, dynamic> json) {
    int parseMoney(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) {
        return int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      return 0;
    }

    // queryExec wrapper 구조 대응 ({ historyMaternalContract: {...} } 또는 { bindMaternalContract: {...} })
    Map<String, dynamic> targetJson = json;
    if (json.containsKey("historyMaternalContract")) {
      targetJson = json["historyMaternalContract"];
    } else if (json.containsKey("bindMaternalContract")) {
      targetJson = json["bindMaternalContract"];
    }

    return ContractModel(
      id: targetJson["id"]?.toString() ?? "",
      maternalUserId: targetJson["maternalUserId"]?.toString() ?? "", // 추가
      contractId: targetJson["contractId"]?.toString() ?? "", // 추가
      resId: targetJson["resId"]?.toString() ?? "",
      gid: targetJson["gid"]?.toString() ?? "", // 추가
      pid: targetJson["pid"]?.toString() ?? "",
      sdate: targetJson["sdate"] ?? "",
      edate: targetJson["edate"] ?? "",
      period: targetJson["period"]?.toString() ?? "",
      contractDoc: targetJson["contractDoc"] ?? "",
      cfDate: targetJson["cfDate"] ?? "",
      ctDate: targetJson["ctDate"] ?? "",
      sysCid: targetJson["sysCid"]?.toString() ?? "", // 추가
      idate: targetJson["idate"] ?? "",
      totalMoney: parseMoney(targetJson["totalMoney"]),
      status: targetJson["status"] ?? "",
      curVer: targetJson["curVer"]?.toString() ?? "", // 추가
      customerCode: targetJson["customerCode"] ?? "",
      customerName: targetJson["customerName"] ?? "",
      birth: targetJson["birth"] ?? "",
      contractDate: targetJson["contractDate"] ?? "",
      roomId: targetJson["roomId"]?.toString() ?? "",
      roomNo: targetJson["roomNo"] ?? "",
      roomLevel: targetJson["roomLevel"]?.toString() ?? "",
      roomLevelName: targetJson["roomLevelName"] ?? "일반실",
      onlineDocId: targetJson["onlineDocId"] ?? "",
      signType: targetJson["signType"] ?? "",
      payStatus: targetJson["payStatus"] ?? "",
      signStatus: targetJson["signStatus"] ?? "",
      payAccount: targetJson["payAccount"] ?? "",
      mobilePhone: targetJson["mobilePhone"] ?? "",
      email: targetJson["email"] ?? "",
      pmSrv: targetJson["pmSrv"] ?? "",
      ctype: targetJson["ctype"] ?? "",
      signReqUid: targetJson["signReqUid"] ?? "",
      discAmt: targetJson["discAmt"]?.toString() ?? "0",
      signName: targetJson["signName"] ?? "",
      sreqId: targetJson["sreqId"] ?? "",
      memo: targetJson["memo"] ?? "",
      activateDt: targetJson["activateDt"],
      rPaidAmt: targetJson["rPaidAmt"]?.toString(),
      aesthPaidAmt: targetJson["aesthPaidAmt"]?.toString(),
      retAmt: targetJson["retAmt"]?.toString(),
      isCurrentIn: targetJson["status"] == "ACTIVATED" || targetJson["activateDt"] != null,
      isSelected: false,
    );
  }
}
