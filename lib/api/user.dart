import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:my_mam_app/constants/index.dart'; // GlobalConstants, HttpConstants 로드용
import 'package:my_mam_app/stores/TokenManager.dart'; // tokenManager 로드용
import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/viewmodels/user.dart';

// --- 헬퍼 함수: GET 방식에서 사용하던 JWT 쿠키 추출 및 헤더 생성 로직 공통화 ---
Future<Options> _getAuthOptions() async {
  final token = await tokenManager.getToken();
  String pureJwt = token.toString().replaceAll("mymam-auth=", "").replaceAll(";", "").trim();

  return Options(
    responseType: ResponseType.json,
    headers: {"Cookie": "mymam-auth=$pureJwt", "cookie": "mymam-auth=$pureJwt", "mymam-auth": pureJwt},
  );
}

//서버통신만

Future<UserInfo> loginAPI(Map<String, dynamic> data) async {
  String jsonBody = jsonEncode(data);
  print("🚀 [최종 전송 JSON 데이터]: $jsonBody");

  try {
    final responseData = await dioRequest.post(HttpConstants.LOGIN, data: data);
    print("🎉 [서버 응답 성공 데이터]: $responseData");

    return UserInfo.fromJSON(responseData);
  } catch (e) {
    print("❌ [loginAPI 자체에서 잡힌 치명적 에러]: $e");
    rethrow;
  }
}

// 🎯 [수정 완료] dioRequest 싱글톤 규격에 맞춘 깔끔한 로그아웃 함수
Future<bool> logoutAPI(String userId) async {
  try {
    // 1. 명세서 규격에 맞게 Body 패킹
    Map<String, dynamic> requestBody = {"userId": userId};

    print("🛰️ [로그아웃 요청 발사]: ${HttpConstants.LOGOUT} | Body: $requestBody");

    // 2. 통신 가동 (dioRequest가 baseUrl과 Cookie 주입을 알아서 처리합니다)
    final responseData = await dioRequest.post(
      HttpConstants.LOGOUT, // 💡 전체 URL 대신 상대 경로만 적어주면 됩니다.
      data: requestBody,
    );

    // 3. dioRequest 내부 검증(status: 200)을 통과하고 나온 데이터 처리
    if (responseData is Map<String, dynamic>) {
      // 서버가 준 JSON 구조 { "payload": "logout successfully", "status": 200 ... } 검증
      if (responseData['status'] == 200 || responseData['payload'].toString().contains("successfully")) {
        print("🎉 [서버 로그아웃 응답 성공]: $responseData");
        return true;
      }
    }

    return false;
  } catch (e) {
    // dioRequest 내부에서 비즈니스 에러(status가 200이 아님) 등이 터지면 이쪽 catch로 넘어옵니다.
    print("❌ [서버 로그아웃 통신 에러]: $e");
    return false;
  }
}

// 🎯 [현상태 유지] 회원가입 API 수행기 (Cookie 값 불필요)
Future<bool> registerUserAPI(Map<String, dynamic> registerData) async {
  try {
    final String baseUrl = "https://sanhujori.plusrnd.com/api/v1";
    print("================ [REST Client Test Form] ================");
    print("POST $baseUrl${HttpConstants.REGISTER}");
    print("Content-Type: application/json");
    print(""); // 헤더와 바디 사이 공백 필수
    print(jsonEncode(registerData)); // dart:convert 임포트 필요
    print("=========================================================");

    final response = await dioRequest.post(
      HttpConstants.REGISTER,
      data: registerData,
      // 회원가입 단계에서는 아직 인증 쿠키가 없으므로 인터셉터 처리를 안전하게 바이패스 하거나 기본 유지
      options: Options(extra: {'skipInterceptor': true}),
    );
    print("🛰️ [API] 회원가입 서버 전송 성공 응답 수신: $response");
    return true;
  } catch (e) {
    print("❌ [API] 회원가입 백엔드 통신 오류: $e");
    rethrow;
  }
}

Future<UserInfo> getUserInfoAPI() async {
  final String pureEndpoint = "${GlobalConstants.BASE_URL}${HttpConstants.USER_PROFILE}";

  final String rawQuery =
      '{currentUserInfo{id,userId,userName,telephone,gender{code,name,ename},userType{code,name,ename},birthday,estimatedDueDate,fileId,address,createDt,updateDt}}';

  final token = await tokenManager.getToken();
  String pureJwt = token.toString().replaceAll("mymam-auth=", "").replaceAll(";", "").trim();

  final Uri finalizedUri = Uri.parse(pureEndpoint).replace(queryParameters: {"qparam": rawQuery});

  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  print("📝 [VS Code REST Client용 요청 스펙 - 복사해서 사용하세요]");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  print("### 1. 로그인 유저 정보 조회 테스트 (현재 사용자 정보)");
  print("GET $finalizedUri HTTP/1.1");
  print("Cookie: mymam-auth=$pureJwt");
  print("mymam-auth: $pureJwt");
  print("responseType: application/json");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

  try {
    final response = await dioRequest.get(
      pureEndpoint,
      queryParameters: {"qparam": rawQuery},
      options: Options(
        responseType: ResponseType.json,
        extra: {"skipInterceptor": true},
        headers: {"Cookie": "mymam-auth=$pureJwt", "cookie": "mymam-auth=$pureJwt", "mymam-auth": pureJwt},
      ),
    );

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📡 [본인 정보 서버 응답 수신 성공 (Response)]");
    if (response is Response) {
      print("➔ HTTP 상태 코드: ${response.statusCode}");
      print("➔ 응답 데이터 내용: ${response.data}");
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final dynamic responseData = (response is Response) ? response.data : response;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey("payload") && responseData["payload"] != null) {
        final payloadData = responseData["payload"];

        if (payloadData is Map<String, dynamic>) {
          if (payloadData.containsKey("currentUserInfo")) {
            final currentUserData = payloadData["currentUserInfo"];
            if (currentUserData is List && currentUserData.isNotEmpty) {
              return UserInfo.fromJSON(currentUserData[0] as Map<String, dynamic>);
            } else if (currentUserData is Map<String, dynamic>) {
              return UserInfo.fromJSON(currentUserData);
            }
          }
          return UserInfo.fromJSON(payloadData);
        }
      }
      return UserInfo.fromJSON(responseData);
    }

    throw Exception("유저 정보 응답 포맷이 올바르지 않습니다: $responseData");
  } catch (e) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("❌ [본인 정보 서버 통신 오류 또는 에러 반환]");
    String crashLog = (e is DioException) ? (e.response?.data?.toString() ?? e.message ?? e.toString()) : e.toString();
    print("➔ 최종 에러 원인 본문: $crashLog");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    throw Exception("서버 데이터 로드 실패: $crashLog");
  }
}

Future<UserInfo> getSpecificUserInfoAPI(String targetUserId) async {
  final String pureEndpoint = "${GlobalConstants.BASE_URL}${HttpConstants.USER_PROFILE}";

  final String rawQuery =
      '{userInfo(userId:"$targetUserId"){id,userId,userName,telephone,gender{code,name,ename},userType{code,name,ename},birthday,estimatedDueDate,fileId,address,createDt,updateDt}}';

  final token = await tokenManager.getToken();
  String pureJwt = token.toString().replaceAll("mymam-auth=", "").replaceAll(";", "").trim();

  final Uri finalizedUri = Uri.parse(pureEndpoint).replace(queryParameters: {"qparam": rawQuery});

  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  print("📝 [VS Code REST Client용 요청 스펙 - 복사해서 사용하세요]");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  print("### 2. 지정 유저 정보 조회 테스트 (ID 검색)");
  print("GET $finalizedUri HTTP/1.1");
  print("Cookie: mymam-auth=$pureJwt");
  print("mymam-auth: $pureJwt");
  print("responseType: application/json");
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

  try {
    final response = await dioRequest.get(
      pureEndpoint,
      queryParameters: {"qparam": rawQuery},
      options: Options(
        responseType: ResponseType.json,
        extra: {"skipInterceptor": true},
        headers: {"Cookie": "mymam-auth=$pureJwt", "cookie": "mymam-auth=$pureJwt", "mymam-auth": pureJwt},
      ),
    );

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📡 [지정 유저 응답 수신 성공 (Response)]");
    if (response is Response) {
      print("➔ HTTP 상태 코드: ${response.statusCode}");
      print("➔ 응답 데이터 내용: ${response.data}");
    }
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final dynamic responseData = (response is Response) ? response.data : response;

    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey("payload") && responseData["payload"] != null) {
        final payloadData = responseData["payload"];

        if (payloadData is Map<String, dynamic>) {
          if (payloadData.containsKey("userInfo")) {
            final targetUserData = payloadData["userInfo"];
            if (targetUserData is List && targetUserData.isNotEmpty) {
              return UserInfo.fromJSON(targetUserData[0] as Map<String, dynamic>);
            } else if (targetUserData is Map<String, dynamic>) {
              return UserInfo.fromJSON(targetUserData);
            }
          }
          return UserInfo.fromJSON(payloadData);
        }
      }
      return UserInfo.fromJSON(responseData);
    }

    throw Exception("지정 유저 응답 포맷이 올바르지 않습니다: $responseData");
  } catch (e) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("❌ [지정 유저 서버 통신 오류 또는 에러 반환]");
    String crashLog = (e is DioException) ? (e.response?.data?.toString() ?? e.message ?? e.toString()) : e.toString();
    print("➔ 최종 에러 원인 본문: $crashLog");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    throw Exception("서버 데이터 로드 실패: $crashLog");
  }
}

/// [일반 프로필 정보 수정 API]
Future<bool> updateUserInfoAPI(UserInfo userInfo) async {
  try {
    final Map<String, dynamic> commandData = {
      "name": "saveUser",
      "payload": {
        "userName": userInfo.userName,
        "telephone": userInfo.telephone,
        "birthday": userInfo.birthday,
        "estimatedDueDate": userInfo.estimatedDueDate,
        "address": userInfo.address,
        "babyName": userInfo.babyName,
        "fileId": userInfo.fileId,
      },
    };

    print("🛰️ [API] 일반 정보 수정 요청 전송: $commandData");

    final options = await _getAuthOptions();

    final response = await dioRequest.post(HttpConstants.USER_UPDATE, data: commandData, options: options);

    return response != null;
  } catch (e) {
    print("❌ 일반 정보 업데이트 API 에러: $e");
    return false;
  }
}

/// [비밀번호 변경 전용 API]
Future<bool> updateUserPasswordAPI({required String oldPassword, required String newPassword}) async {
  try {
    final Map<String, dynamic> commandData = {
      "name": "resetUserPw",
      "payload": {"oldPassword": oldPassword, "newPassword": newPassword},
    };

    print("🛰️ [API] 비밀번호 변경 요청 전송: [보안상 페이로드 로그 생략]");

    final options = await _getAuthOptions();

    final response = await dioRequest.post(HttpConstants.USER_UPDATE, data: commandData, options: options);

    return response != null;
  } catch (e) {
    print("❌ 비밀번호 업데이트 API 에러: $e");
    return false;
  }
}

/// 🤰 산모 신원 인증 API
Future<bool> certifyMaternalAPI(String certCode) async {
  try {
    final Map<String, dynamic> commandData = {
      "name": "UserCertifyMaternal",
      "payload": {"certCode": certCode},
    };

    print("🚀 [API] 산모 인증 요청 전송: $commandData");

    final options = await _getAuthOptions();

    final response = await dioRequest.post(HttpConstants.USER_UPDATE, data: commandData, options: options);

    return response != null;
  } catch (e) {
    print("❌ [API] 산모 인증 백엔드 통신 오류: $e");
    return false;
  }
}

/// 👨‍👩‍👧‍👦 가족 초대 수락 인증 API
Future<bool> acceptFamilyInvitationAPI(String inviteCode) async {
  try {
    final Map<String, dynamic> commandData = {
      "name": "AcceptFamilyInvitation",
      "payload": {"inviteCode": inviteCode},
    };

    print("🚀 [API] 가족 초대 수락 요청 전송: $commandData");

    final options = await _getAuthOptions();

    final response = await dioRequest.post(HttpConstants.USER_UPDATE, data: commandData, options: options);

    return response != null;
  } catch (e) {
    print("❌ [API] 가족 초대 수락 백엔드 통신 오류: $e");
    return false;
  }
}

/// 👨‍👩‍👧‍👦 카카오톡 초대 코드 발송 API
Future<bool> sendFamilyInvitationAPI(String inviteePhone) async {
  try {
    final Map<String, dynamic> commandData = {
      "name": "CreateFamilyInvitation",
      "payload": {"inviteePhone": inviteePhone},
    };

    print("🚀 [API] 가족 초대 발송 커맨드 전송: $commandData");

    final options = await _getAuthOptions();

    final response = await dioRequest.post(HttpConstants.USER_UPDATE, data: commandData, options: options);

    print("🎉 [API] 가족 초대 발송 서버 응답 성공: $response");
    return response != null;
  } catch (e) {
    print("❌ [API] 가족 초대 발송 백엔드 통신 오류: $e");
    return false;
  }
}
