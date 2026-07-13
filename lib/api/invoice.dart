import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:my_mam_app/stores/TokenManager.dart';
import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/viewmodels/invoice.dart';
// 기존 설정 임포트 경로에 맞게 매핑 필요
// import 'package:my_mam_app/constants/http_constants.dart';

class InvoiceApi {
  static const String endpoint = "/account/queryExec";

  /// 🔒 참조로 넘겨주신 쿠키 옵션 조립 프라이빗 헬퍼 함수
  static Future<Options> _getAuthOptions() async {
    final token = await tokenManager.getToken();
    String pureJwt = token.toString().replaceAll("mymam-auth=", "").replaceAll(";", "").trim();

    return Options(
      responseType: ResponseType.json,
      headers: {"Cookie": "mymam-auth=$pureJwt", "cookie": "mymam-auth=$pureJwt", "mymam-auth": pureJwt},
    );
  }

  /// 🛰️ 1. 전체 청구서 목록 조회 (billingList)
  static Future<List<BillingModel>> fetchBillingList() async {
    const String rawQuery =
        '{billingList{billingId,contractId,sysCid,sysName,totAmt,createDt,status{code,name,ename}}}';
    final options = await _getAuthOptions();

    print("🛰️ [API] 청구 목록 요청 주소: GET $endpoint | qparam: $rawQuery");

    try {
      final response = await dioRequest.get(endpoint, queryParameters: {"qparam": rawQuery}, options: options);

      final dynamic responseData = (response is Response) ? response.data : response;

      if (responseData is Map<String, dynamic> && responseData["payload"] != null) {
        final payload = responseData["payload"];
        if (payload is Map<String, dynamic> && payload["billingList"] is List) {
          final List list = payload["billingList"];
          return list.map((json) => BillingModel.fromJSON(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print("❌ [API] fetchBillingList 통신 치명적 에러: $e");
      return [];
    }
  }

  /// 🛰️ 2. 단건 청구서 영수증 영수세부내역 조회 (billingDetail)
  static Future<BillingDetailModel?> fetchBillingDetail(String billingId) async {
    final String rawQuery =
        '{billingDetail(billingId:"$billingId"){billingId,custCode,custName,goodsName,payKind{code,name,ename},payAccno,subPayKind,payStatus{code,name,ename},autNo,payDate,baseAmt,taxExemptAmt,vatAmt,totAmt}}';
    final options = await _getAuthOptions();

    print("🛰️ [API] 청구상세 요청 주소: GET $endpoint | billingId: $billingId");

    try {
      final response = await dioRequest.get(endpoint, queryParameters: {"qparam": rawQuery}, options: options);

      final dynamic responseData = (response is Response) ? response.data : response;

      if (responseData is Map<String, dynamic> && responseData["payload"] != null) {
        final payload = responseData["payload"];
        if (payload is Map<String, dynamic> && payload["billingDetail"] is List) {
          final List list = payload["billingDetail"];
          if (list.isNotEmpty) {
            return BillingDetailModel.fromJSON(list[0]);
          }
        }
      }
      return null;
    } catch (e) {
      print("❌ [API] fetchBillingDetail 통신 치명적 에러: $e");
      return null;
    }
  }

  /// 🛰️ 3. PG 연동 처리를 위한 결제 메타 마스터 조회 (billingPayment)
  static Future<BillingPaymentModel?> fetchBillingPayment(String billingId) async {
    final String rawQuery =
        '{billingPayment(billingId:"$billingId"){billingId,custCode,custName,custMobile,custEmail,contractId,items{itemName,payAmt},totAmt}}';
    final options = await _getAuthOptions();

    print("🛰️ [API] 결제정보 요청 주소: GET $endpoint | billingId: $billingId");

    try {
      final response = await dioRequest.get(endpoint, queryParameters: {"qparam": rawQuery}, options: options);

      final dynamic responseData = (response is Response) ? response.data : response;

      if (responseData is Map<String, dynamic> && responseData["payload"] != null) {
        final payload = responseData["payload"];
        if (payload is Map<String, dynamic> && payload["billingPayment"] is List) {
          final List list = payload["billingPayment"];
          if (list.isNotEmpty) {
            return BillingPaymentModel.fromJSON(list[0]);
          }
        }
      }
      return null;
    } catch (e) {
      print("❌ [API] fetchBillingPayment 통신 치명적 에러: $e");
      return null;
    }
  }
}
