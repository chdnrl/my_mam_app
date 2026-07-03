import 'package:dio/dio.dart';
import 'package:my_mam_app/stores/TokenManager.dart'; // 🎯 tokenManager 인스턴스를 가져오기 위해 필요합니다. 경로를 확인해주세요.
import 'package:my_mam_app/utils/DioRequest.dart';

// --- 헬퍼 함수: 기존 파일에서 검증된 JWT 쿠키 추출 및 헤더 생성 로직 동일 적용 ---
Future<Options> _getAuthOptions() async {
  final token = await tokenManager.getToken();
  String pureJwt = token
      .toString()
      .replaceAll("mymam-auth=", "")
      .replaceAll(";", "")
      .trim();

  return Options(
    responseType: ResponseType.json,
    headers: {
      "Cookie": "mymam-auth=$pureJwt",
      "cookie": "mymam-auth=$pureJwt",
      "mymam-auth": pureJwt,
    },
  );
}

/// 👨‍👩‍👧‍👦 [API] 가족 초대 현황 리스트 조회 (GET - queryExec)
Future<List<dynamic>?> getFamilyInvitationListAPI() async {
  try {
    const String queryParam =
        "{"
        "familyInvitationRecord{"
        "id,maternalUserId,inviteeUserId,inviteUserName,birthDay,"
        "gender{code,name,ename},inviteCode,inviteePhone,"
        "shareFlag{code,name,ename},inviteStatus{code,name,ename},"
        "createTime,acceptTime,cancelTime,expireTime,updateTime"
        "}"
        "}";

    print("🚀 [API] 가족 초대 정보 목록 요청 시작");

    // 🎯 쿠키 옵션 로드
    final options = await _getAuthOptions();

    // 공통 dioRequest에 명시적으로 쿠키 헤더 주입 및 전송
    final response = await dioRequest.get(
      "/api/v1/account/queryExec",
      queryParameters: {"qparam": queryParam},
      options: options, // 🎯 헤더 옵션 추가
    );

    if (response != null) {
      print("🎉 [API] 가족 초대 정보 수신 성공");

      // 5. Dio 통신 규격 검증 및 데이터 파이프라인 정제 (Response 객체인지 본문 맵 데이터인지 방어 코드 처리)
      final dynamic responseData = (response is Response)
          ? response.data
          : response;

      if (responseData is Map &&
          responseData.containsKey("familyInvitationRecord")) {
        return responseData["familyInvitationRecord"] as List<dynamic>;
      } else if (responseData is Map && responseData.containsKey("payload")) {
        final payloadData = responseData["payload"];
        if (payloadData is Map &&
            payloadData.containsKey("familyInvitationRecord")) {
          return payloadData["familyInvitationRecord"] as List<dynamic>;
        }
      } else if (responseData is List) {
        return responseData;
      }
    }
    return null;
  } catch (e) {
    print("❌ [API] 가족 초대 목록 가져오기 실패: $e");
    return null;
  }
}

/// 🔄 [API] 가족 스마트 크래들 기기 공유 상태 변경 제어 (POST - command)
Future<bool> changeFamilyDeviceShareAPI({
  required String inviteId,
  required int shareFlag,
}) async {
  try {
    print("🚀 [API] 기기 공유 권한 명령 전송 시작 -> ID: $inviteId, Flag: $shareFlag");

    // 🎯 쿠키 옵션 로드
    final options = await _getAuthOptions();

    final response = await dioRequest.post(
      "/api/v1/account/command",
      data: {
        "name": "FamilyDeviceShare",
        "payload": {
          "inviteId": int.tryParse(inviteId) ?? 0,
          "shareFlag": shareFlag, // 0: 닫힘, 1: 열림
        },
      },
      options: options, // 🎯 헤더 옵션 추가
    );

    if (response != null) {
      print("🎉 [API] 기기 공유 권한 명령 처리 성공");
      return true;
    }
    return false;
  } catch (e) {
    print("❌ [API] 기기 공유 권한 명령 실패: $e");
    return false;
  }
}

/// ❌ [API] 가족 초대 취소 / 연결 삭제 제어 (POST - command)
Future<bool> cancelFamilyInvitationAPI({required String inviteId}) async {
  try {
    print("🚀 [API] 가족 초대 취소 요청 시작 -> inviteId: $inviteId");

    // 🎯 쿠키 옵션 로드
    final options = await _getAuthOptions();

    final response = await dioRequest.post(
      "/api/v1/account/command",
      data: {
        "name": "CancelFamilyInvitation",
        "payload": {"inviteId": int.tryParse(inviteId) ?? 0},
      },
      options: options, // 🎯 헤더 옵션 추가
    );

    if (response != null) {
      print("🎉 [API] 가족 초대 취소 처리 성공");
      return true;
    }
    return false;
  } catch (e) {
    print("❌ [API] 가족 초대 취소 실패: $e");
    return false;
  }
}
