import 'package:flutter/material.dart';

/// API에서 공통 코드 객체 형태 {code, name, ename}로 내려오는 데이터를 담는 클래스
class SubCode {
  final String code;
  final String name;
  final String ename;

  SubCode({this.code = "", this.name = "", this.ename = ""});

  /// 💡 [수정] int, double, String 등 어떤 타입의 code가 들어와도 안전하게 처리합니다.
  factory SubCode.fromJSON(dynamic json) {
    if (json is Map) {
      return SubCode(
        // 🎯 .toString()을 붙여서 int(1, 2)를 String("1", "2")로 안전하게 바꿉니다.
        code: json["code"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        ename: json["ename"]?.toString() ?? "",
      );
    }

    // 객체가 아니라 단일 숫자(1)나 문자열이 올 경우의 방어 처리
    final stringVal = json?.toString() ?? "";
    return SubCode(code: stringVal, name: stringVal, ename: stringVal);
  }

  Map<String, dynamic> toJson() => {"code": code, "name": name, "ename": ename};

  SubCode copyWith({String? code, String? name, String? ename}) {
    return SubCode(
      code: code ?? this.code,
      name: name ?? this.name,
      ename: ename ?? this.ename,
    );
  }
}

class UserInfo {
  String userId;
  String userName;
  String password;
  String telephone;
  String birthday;
  String estimatedDueDate;
  String fileId;
  String? address;
  String? babyName;

  // 🛠️ 변경 및 추가: 객체 지향적 관리를 위한 SubCode 타입 적용
  SubCode gender;
  SubCode userType;

  String fromInvitationCode;
  String avatar;
  String birthYear;
  String birthMonth;
  String birthDay;
  String id;
  String mobile;
  String nickname;
  String token;
  String myChild;

  String sysCid;
  String invitationCode;
  String custCode;

  UserInfo({
    required this.userId,
    required this.userName,
    required this.password,
    required this.telephone,
    required this.birthday,
    required this.estimatedDueDate,
    required this.fileId,
    this.address,
    this.babyName,
    required this.userType, // 필수 파라미터 지정
    required this.fromInvitationCode,
    required this.avatar,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
    required this.gender, // 필수 파라미터 지정
    required this.id,
    required this.mobile,
    required this.nickname,
    required this.token,
    required this.myChild,
    this.sysCid = "",
    this.invitationCode = "",
    this.custCode = "",
  });

  static final UserInfo mock = UserInfo(
    userId: "super",
    userName: "张飞",
    password: "123456789",
    telephone: "010-9796-3537",
    birthday: "2000-01-01",
    estimatedDueDate: "2025-06-01",
    fileId: "1f750a6c44a14676be5335c8e99a53c45",
    address: "中国西安",
    babyName: "妞妞",
    userType: SubCode(code: "family", name: "가족회원", ename: "familyUser"),
    fromInvitationCode: "",
    avatar: "",
    gender: SubCode(code: "F", name: "여성", ename: "female"),
    id: "sanmo.ae",
    mobile: "010-4489-5995",
    nickname: "김산모",
    token: "test_token",
    myChild: "찰떡이(여), 튼튼이(남)",
    birthYear: '1994',
    birthMonth: '12',
    birthDay: '20',
  );

  factory UserInfo.fromJSON(Map<String, dynamic> json) {
    // 1. 로그인 직후의 응답 구조인 경우 (payload가 토큰 String인 상태)
    if (json.containsKey("payload") && json["payload"] is String) {
      String rawToken = json["payload"] ?? "";

      return UserInfo(
        userId: "",
        userName: "",
        password: "",
        telephone: "",
        birthday: "",
        estimatedDueDate: "",
        fileId: "",
        fromInvitationCode: "",
        avatar: "",
        birthYear: "",
        birthMonth: "",
        birthDay: "",
        gender: SubCode(),
        userType: SubCode(),
        id: "",
        mobile: "",
        nickname: "",
        myChild: "",
        token: rawToken,
        sysCid: "",
        invitationCode: "",
        custCode: "",
        address: "",
        babyName: "",
      );
    }

    // 2. 내 정보 조회 API (queryExec) 응답 구조 및 중첩 구조 핸들링
    Map<String, dynamic> targetJson = json;

    if (json.containsKey("payload") && json["payload"] is Map) {
      final payloadMap = json["payload"] as Map<String, dynamic>;

      if (payloadMap.containsKey("currentUserInfo")) {
        final curData = payloadMap["currentUserInfo"];
        targetJson = (curData is List && curData.isNotEmpty)
            ? curData[0]
            : (curData is Map ? curData : payloadMap);
      } else if (payloadMap.containsKey("userInfo")) {
        final uData = payloadMap["userInfo"];
        targetJson = (uData is List && uData.isNotEmpty)
            ? uData[0]
            : (uData is Map ? uData : payloadMap);
      } else if (payloadMap.containsKey("user")) {
        final userData = payloadMap["user"];
        targetJson = (userData is List && userData.isNotEmpty)
            ? userData[0]
            : (userData is Map ? userData : payloadMap);
      } else {
        targetJson = payloadMap;
      }
    } else if (json.containsKey("currentUserInfo") &&
        json["currentUserInfo"] is Map) {
      targetJson = json["currentUserInfo"];
    } else if (json.containsKey("userInfo") && json["userInfo"] is Map) {
      targetJson = json["userInfo"];
    }

    if (targetJson is List && (targetJson as List).isNotEmpty) {
      targetJson = (targetJson as List)[0] as Map<String, dynamic>;
    }

    // 생년월일(birthday) 분할 세팅 안전성 강화
    String bDay = targetJson["birthday"] ?? "";
    List<String> parts = bDay.contains("-") ? bDay.split("-") : ["", "", ""];

    String rawPassword = targetJson["password"] ?? targetJson["passWord"] ?? "";

    // 🛠️ [핵심 보강] 중첩 객체 구조 파싱을 SubCode 연동형식으로 이관
    SubCode parsedGender = SubCode.fromJSON(targetJson["gender"]);
    SubCode parsedUserType = SubCode.fromJSON(targetJson["userType"]);

    return UserInfo(
      id: targetJson["id"]?.toString() ?? "",
      userId: targetJson["userId"] ?? "",
      userName: targetJson["userName"] ?? "",
      telephone: targetJson["telephone"] ?? "",
      birthday: bDay,
      birthYear: targetJson["birthYear"] ?? (parts.isNotEmpty ? parts[0] : ""),
      birthMonth:
          targetJson["birthMonth"] ?? (parts.length > 1 ? parts[1] : ""),
      birthDay: targetJson["birthDay"] ?? (parts.length > 2 ? parts[2] : ""),
      estimatedDueDate: targetJson["estimatedDueDate"] ?? "",
      fileId: targetJson["fileId"] ?? "",
      address: targetJson["address"] ?? "",
      babyName: targetJson["babyName"] ?? "",
      invitationCode: targetJson["invitationCode"] ?? "",
      fromInvitationCode: targetJson["fromInvitationCode"] ?? "",
      custCode: targetJson["custCode"] ?? "",
      sysCid: targetJson["sysCid"]?.toString() ?? "",
      avatar: targetJson["avatar"] ?? "",
      gender: parsedGender,
      userType: parsedUserType,
      mobile: targetJson["mobile"] ?? targetJson["telephone"] ?? "",
      nickname: targetJson["nickname"] ?? targetJson["userName"] ?? "",
      token: targetJson["token"] ?? "",
      myChild: targetJson["myChild"] ?? "",
      password: rawPassword,
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "userName": userName,
    "password": password,
    "telephone": telephone,
    "birthday": birthday,
    "estimatedDueDate": estimatedDueDate,
    "fileId": fileId,
    "address": address,
    "babyName": babyName,
    "gender": gender.toJson(), // 객체로 직렬화
    "userType": userType.toJson(), // 객체로 직렬화
    "fromInvitationCode": fromInvitationCode,
    "nickname": nickname,
    "mobile": mobile,
    "birthYear": birthYear,
    "birthMonth": birthMonth,
    "birthDay": birthDay,
  };

  UserInfo copyWith({
    String? nickname,
    String? mobile,
    String? birthday,
    String? birthYear,
    String? birthMonth,
    String? birthDay,
    String? userName,
    String? password,
    String? telephone,
    String? estimatedDueDate,
    String? fileId,
    String? address,
    String? babyName,
    SubCode? gender,
    SubCode? userType,
    String? fromInvitationCode,
    String? token,
  }) {
    return UserInfo(
      userId: this.userId,
      id: this.id,
      nickname: nickname ?? this.nickname,
      mobile: mobile ?? this.mobile,
      birthday: birthday ?? this.birthday,
      birthYear: birthYear ?? this.birthYear,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
      avatar: this.avatar,
      gender: gender ?? this.gender,
      userType: userType ?? this.userType,
      token: token ?? this.token,
      myChild: this.myChild,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      telephone: telephone ?? this.telephone,
      estimatedDueDate: estimatedDueDate ?? this.estimatedDueDate,
      fileId: fileId ?? this.fileId,
      address: address ?? this.address,
      babyName: babyName ?? this.babyName,
      fromInvitationCode: fromInvitationCode ?? this.fromInvitationCode,
      sysCid: this.sysCid,
      invitationCode: this.invitationCode,
      custCode: this.custCode,
    );
  }
}
