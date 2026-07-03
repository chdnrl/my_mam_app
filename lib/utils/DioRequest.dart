import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:my_mam_app/constants/index.dart';
import 'package:my_mam_app/stores/TokenManager.dart';

import 'dart:convert';

class DioRequest {
  // 실제 네트워크 통신을 담당하는 Dio 순수 객체 (내부 캡슐화)
  final _dio = Dio();

  /// [생성자] DioRequest 인스턴스가 최초 생성될 때 타임아웃 및 옵션 초기화
  DioRequest() {
    _dio.options
      ..baseUrl = GlobalConstants
          .BASE_URL // 전역 공통 자바 서버 주소 매핑
      ..connectTimeout =
          Duration(seconds: GlobalConstants.TIME_OUT) // 서버 연결 대기 최대 시간
      ..sendTimeout =
          Duration(seconds: GlobalConstants.TIME_OUT) // 요청 데이터 전송 최대 시간
      ..receiveTimeout = Duration(seconds: GlobalConstants.TIME_OUT); // 서버 응답 대기 최대 시간

    // 네트워크 인터셉터(감시자) 등록
    _addInterceptor();

    // ✨ [여기에 추가] Dio 자체 로그 인터셉터 등록
    // kDebugMode를 사용하여 실서비스 배포(Release) 버전에서는 로그가 노출되지 않도록 방어합니다.
    if (kDebugMode) {
      // 📦 [A] Dio 기본 로그 인터셉터
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );

      // 📝 [B] REST Client (.http) 전용 포맷 출력 인터셉터
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // 💡 팁: path가 전체 URL 형태(http...)로 올 때를 대비한 안전한 맵핑
            final String fullUrl = options.path.startsWith('http') ? options.path : "${options.baseUrl}${options.path}";

            print("\n=================== 📝 REST CLIENT FORMAT ===================");
            print("### ${options.method} 요청 가이드");
            print("${options.method} $fullUrl");
            print("Content-Type: application/json");

            // 앞선 _addInterceptor에서 주입된 최신 헤더 정보 추적 출력
            if (options.headers.containsKey('Cookie') && options.headers['Cookie'] != null) {
              print("Cookie: ${options.headers['Cookie']}");
            }
            if (options.headers.containsKey('mymam-auth') && options.headers['mymam-auth'] != null) {
              print("mymam-auth: ${options.headers['mymam-auth']}");
            }

            // 바디 데이터(POST 등)가 있다면 깔끔한 JSON 문장으로 출력
            if (options.data != null) {
              print(""); // 헤더와 바디 경계선
              try {
                print(jsonEncode(options.data));
              } catch (_) {
                print(options.data.toString());
              }
            }
            print("============================================================\n");

            return handler.next(options);
          },
        ),
      );
    }

    // 로컬 개발 환경용 SSL(HTTPS) 인증서 강제 통과 어댑터 설정
    // 앱이 개발 모드(!kReleaseMode)일 때만 작동하여 보안 경고를 우회합니다.
    if (!kReleaseMode) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          // 신뢰할 수 없는 로컬 HTTPS 인증서라도 무조건 true를 반환하여 통과시킴
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }
  }

  /// [인터셉터 바인딩] 요청(Request), 응답(Response), 에러(Error) 필터링
  void _addInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        /// ① [요청 인터셉터] 서버로 패킷이 날아가기 직전에 가로채서 세션 쿠키 자동 주입
        onRequest: (request, handler) async {
          // 'skipInterceptor' 지령이 활성화되어 있다면 인터셉터 로직을 우회합니다.
          if (request.extra['skipInterceptor'] == true) {
            print("🛰️ [인터셉터] 특수 지령 감지: API 수동 헤더 유지를 위해 통과합니다.");
            return handler.next(request);
          }

          // 로컬 스토리지에서 보관 중인 최신 JWT 토큰을 로드
          final token = await tokenManager.getToken();
          if (token.isNotEmpty) {
            String rawToken = token.toString().replaceAll("mymam-auth=", "").trim();

            // 자바 서버가 요구하는 정석 표준 쿠키 명세 세팅
            request.headers['Cookie'] = "mymam-auth=$rawToken;";
            request.headers['mymam-auth'] = rawToken;

            // 💡 [향후 자산] 백엔드 사양 변경으로 Bearer 토큰이 필요할 때만 주석을 해제하세요.
            // request.headers['Authorization'] = "Bearer $rawToken";
          }
          return handler.next(request);
        },

        /// ② [응답 인터셉터] 서버 응답이 컨트롤러에 도착하기 직전 HTTP 상태 코드 가로채기
        onResponse: (response, handler) {
          final statusCode = response.statusCode ?? 0;

          // HTTP 상태 코드가 200번대 성공 규격인 경우 정상 패스
          if (statusCode >= 200 && statusCode < 300) {
            return handler.next(response);
          }
          // 그 외의 경우(400, 500번대 등) 강제로 오류 객체를 생성하여 onError로 토스
          return handler.reject(DioException(requestOptions: response.requestOptions, response: response));
        },

        /// ③ [에러 인터셉터] 서버 통신 중 예외가 터졌을 때 가독성 높은 커스텀 메시지로 변환
        onError: (error, handler) {
          // 서버가 내려준 커스텀 에러 문구(msg)가 존재한다면 파싱하고, 없으면 기본 에러 문구 할당
          String serverMessage = "서버와의 통신이 원활하지 않습니다.";
          if (error.response?.data is Map<String, dynamic>) {
            serverMessage = error.response?.data["msg"] ?? serverMessage;
          }

          return handler.reject(
            DioException(requestOptions: error.requestOptions, response: error.response, message: serverMessage),
          );
        },
      ),
    );
  }

  /// [전역 헤더 강제 갱신] 로그인 성공 직후, 다음 통신들이 끊기지 않도록 공통 주머니 업데이트
  void setAuthCookie(String token) {
    String rawToken = token.toString().replaceAll("mymam-auth=", "").trim();
    String finalCookie = "mymam-auth=$rawToken;";

    _dio.options.headers['Cookie'] = finalCookie;
    _dio.options.headers['mymam-auth'] = rawToken;

    // 💡 [향후 자산] 자바 시큐리티가 Bearer를 수용하게 될 때 주석 해제
    // _dio.options.headers['Authorization'] = "Bearer $rawToken";

    print("D/DioRequest: 🎯 전역 공유 헤더 강제 업데이트 완료 (Cookie 주입됨)");
  }

  /// [GET 메서드 프록시] 전용 Options 객체와 쿼리 파라미터를 안정적으로 지원
  Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters, Options? options}) {
    return _handleResponse(_dio.get(url, queryParameters: queryParameters, options: options));
  }

  /// [POST 메서드 프록시] 데이터 바디를 실어 보낼 때 사용
  Future<dynamic> post(String url, {Map<String, dynamic>? data, Options? options}) {
    return _handleResponse(_dio.post(url, data: data, options: options));
  }

  /// [공통 응답 가공 처리기] 자바 백엔드의 비즈니스 스펙(status: 200)을 내부 검증
  Future<dynamic> _handleResponse(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task;

      // Case 1: 서버가 JSON 객체가 아니라 원시 문자열(String)로 에러나 결과값을 보낸 경우
      if (res.data is String) {
        String rawString = res.data.toString();
        print("➔ [서버 실제 응답 (문자열)]: $rawString");

        if (rawString.contains("FAIL") || rawString.contains("ERROR")) {
          throw DioException(requestOptions: res.requestOptions, message: rawString);
        }
        return rawString;
      }

      // Case 2: 서버가 정상적인 JSON(Map) 데이터 구조로 응답한 경우
      if (res.data is Map<String, dynamic>) {
        final Map<String, dynamic> dataMap = res.data;
        print("➔ [서버 실제 응답 (JSON)]: $dataMap");

        // 자바 비즈니스 커스텀 규격인 "status"가 200이 아니라면 예외로 가로챔
        if (dataMap.containsKey("status") && dataMap["status"] != 200) {
          throw DioException(
            requestOptions: res.requestOptions,
            message: dataMap["message"] ?? "서버 내부 비즈니스 에러가 발생했습니다.",
          );
        }

        // 명세서 상 "result" 주머니가 타겟 알맹이라면 해당 필드만 분리 배송
        if (dataMap.containsKey("result") && dataMap["result"] != null) {
          return dataMap["result"];
        }

        return dataMap;
      }

      return res.data;
    } catch (e) {
      rethrow; // 하위 catch 블록으로 예외 전파
    }
  }
}

// 앱 전체에서 단 하나의 통신 소켓 풀을 공유하기 위한 전역 싱글톤 인스턴스 생성
final dioRequest = DioRequest();
