import 'package:dio/dio.dart';
import 'package:my_mam_app/constants/index.dart'; // HttpConstants, GlobalConstants 로드
import 'package:my_mam_app/stores/TokenManager.dart'; // tokenManager 로드용
import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/viewmodels/contract.dart';

// --- 헬퍼 함수: GET/POST 방식에서 JWT 쿠키 추출 및 헤더 생성 로직 공통화 ---
Future<Options> _getAuthOptions() async {
  final token = await tokenManager.getToken();
  String pureJwt = token.toString().replaceAll("mymam-auth=", "").replaceAll(";", "").trim();

  return Options(
    responseType: ResponseType.json,
    headers: {"Cookie": "mymam-auth=$pureJwt", "cookie": "mymam-auth=$pureJwt", "mymam-auth": pureJwt},
  );
}

class ContractApi {
  /// 🎯 1. 전체 역사 계약서 목록 조회 (GET)
  static Future<List<ContractModel>> fetchHistoryContracts() async {
    const String qparamValue =
        "historyMaternalContract{id,maternalUserId,contractId,resId,gid,pid,sdate,edate,period,contractDoc,cfDate,ctDate,sysCid,idate,totalMoney,status,curVer,customerCode,customerName,birth,contractDate,roomId,roomNo,roomLevel,roomLevelName,onlineDocId,signType,payStatus,signStatus,payAccount,mobilePhone,email,pmSrv,ctype,signReqUid,discAmt,signName,sreqId,memo,rPaidAmt,aesthPaidAmt,retAmt}";

    final String pureEndpoint = "${GlobalConstants.BASE_URL}${HttpConstants.ACTIVATED_CONTRACTS}";

    // 💡 핵심: Uri.parse().replace()를 통해 표준 규격으로 쿼리 파라미터가 포함된 고유 Uri 객체 생성
    final Uri finalizedUri = Uri.parse(pureEndpoint).replace(queryParameters: {"qparam": qparamValue});

    final token = await tokenManager.getToken();
    String pureJwt = token.toString().replaceAll("mymam-auth=", "").replaceAll(";", "").trim();

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📝 [VS Code REST Client용 요청 스펙 - 복사해서 사용하세요]");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("### 3. 전체 역사 계약서 목록 조회 테스트");
    print("GET $finalizedUri HTTP/1.1");
    print("Cookie: mymam-auth=$pureJwt");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final options = await _getAuthOptions();

      // 💡 해결책: HttpConstants 문자열 대신, 위에서 완성한 finalizedUri 객체를 통째로 주입합니다.
      // 이렇게 하면 Dio 내부에서 쿼리스트링을 재생성하면서 중괄호 인코딩이 깨지는 버그를 원천 차단합니다.
      final response = await dioRequest.get(finalizedUri.toString(), options: options);

      final dynamic responseData = (response is Response) ? response.data : response;
      print("🎉 [역사 계약서 조회 성공 데이터]: $responseData");

      if (responseData is Map<String, dynamic> && responseData['status'] == 200) {
        final payloadData = responseData['payload'];

        if (payloadData is Map<String, dynamic> && payloadData.containsKey("historyMaternalContract")) {
          final List<dynamic>? historyList = payloadData["historyMaternalContract"] as List<dynamic>?;
          if (historyList != null) {
            return historyList.map((json) => ContractModel.fromJSON(json as Map<String, dynamic>)).toList();
          }
        } else if (payloadData is List<dynamic>) {
          return payloadData.map((json) => ContractModel.fromJSON(json as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      print("❌ [역사 계약서 조회 자체 치명적 에러]: $e");
      return [];
    }
  }

  /// 🎯 2. 특정 계약 ID 기반 계약 활성화 (POST)
  static Future<bool> activateContract(dynamic contractId) async {
    final Map<String, dynamic> requestBody = {
      "name": "ActiveContract",
      "payload": {"contractId": contractId},
    };

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📝 [VS Code REST Client용 요청 스펙 - 복사해서 사용하세요]");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("### 4. 계약 활성화 테스트 (ActiveContract)");
    print("POST ${GlobalConstants.BASE_URL}${HttpConstants.USER_UPDATE} HTTP/1.1");
    print("Content-Type: application/json");
    print("");
    print(requestBody);
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final options = await _getAuthOptions();

      final response = await dioRequest.post(HttpConstants.USER_UPDATE, data: requestBody, options: options);

      final dynamic responseData = (response is Response) ? response.data : response;

      if (responseData is Map<String, dynamic> && responseData['status'] == 200) {
        print("🎉 [계약 활성화 서버 응답 성공]: $responseData");
        return true;
      }
      return false;
    } catch (e) {
      print("❌ [계약 활성화 통신 치명적 에러]: $e");
      return false;
    }
  }

  /// 🎯 3. 이미 활성화된 현재의 계약 정보 조회 (GET)
  static Future<ContractModel?> fetchActiveContract() async {
    const String qparamValue =
        "bindMaternalContract{id,maternalUserId,contractId,resId,gid,pid,sdate,edate,period,contractDoc,cfDate,ctDate,sysCid,idate,totalMoney,status,curVer,customerCode,customerName,birth,contractDate,roomId,roomNo,roomLevel,roomLevelName,onlineDocId,signType,payStatus,signStatus,payAccount,mobilePhone,email,pmSrv,ctype,signReqUid,discAmt,signName,sreqId,memo,rPaidAmt,aesthPaidAmt,retAmt,activateDt}";

    final String pureEndpoint = "${GlobalConstants.BASE_URL}${HttpConstants.ACTIVATED_CONTRACTS}";

    // 💡 핵심: Uri.parse().replace()를 통해 표준 규격으로 쿼리 파라미터가 포함된 고유 Uri 객체 생성
    final Uri finalizedUri = Uri.parse(pureEndpoint).replace(queryParameters: {"qparam": qparamValue});

    final token = await tokenManager.getToken();
    String pureJwt = token.toString().replaceAll("mymam-auth=", "").replaceAll(";", "").trim();

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📝 [VS Code REST Client용 요청 스펙 - 복사해서 사용하세요]");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("### 5. 이미 활성화된 현재의 계약 정보 조회 테스트");
    print("GET $finalizedUri HTTP/1.1");
    print("Cookie: mymam-auth=$pureJwt");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final options = await _getAuthOptions();

      // 💡 해결책: 마찬가지로 finalizedUri 객체를 통째로 주입하여 Dio의 자동 쿼리 파싱 규칙을 우회합니다.
      final response = await dioRequest.get(finalizedUri.toString(), options: options);

      final dynamic responseData = (response is Response) ? response.data : response;
      print("🎉 [활성화된 계약 조회 성공 데이터]: $responseData");

      if (responseData is Map<String, dynamic> && responseData['status'] == 200) {
        final payloadData = responseData['payload'];

        if (payloadData is Map<String, dynamic> && payloadData.containsKey("bindMaternalContract")) {
          final List<dynamic>? bindList = payloadData["bindMaternalContract"] as List<dynamic>?;
          if (bindList != null && bindList.isNotEmpty) {
            return ContractModel.fromJSON(bindList.first as Map<String, dynamic>);
          }
        } else if (payloadData is List<dynamic> && payloadData.isNotEmpty) {
          return ContractModel.fromJSON(payloadData.first as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print("❌ [활성화된 계약 조회 자체 치명적 에러]: $e");
      return null;
    }
  }
}
