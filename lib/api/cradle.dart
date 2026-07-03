import 'package:my_mam_app/constants/index.dart';
import 'package:my_mam_app/utils/DioRequest.dart'; // 프로젝트의 전역 dioRequest 임포트

class CradleApi {
  /// [GET] 스마트 크래들의 비디오 스트리밍 HLS 주소 가져오기
  Future<Map<String, dynamic>?> fetchCradleStreamUrl(String babyId) async {
    try {
      // dioRequest 공통 엔진을 사용하여 호출하므로 인터셉터가 자동으로 세션 쿠키를 주입합니다.
      // 자바 서버 API 주소 예시: http://api.mymam.com/cradle/stream-url/1
      final response = await dioRequest.get(
        '${HttpConstants.CRADLE}/cradle/stream-url/$babyId',
      );

      // DioRequest의 _handleResponse 처리 규칙에 따라
      // 성공 시 데이터 Map(status, hlsUrl 등이 담긴 바디)이 그대로 리턴됩니다.
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      print("❌ [CradleApi] 영상 스트리밍 주소 수신 실패: $e");
      return null;
    }
  }

  /// [GET] 스마트 크래들 실시간 텍스트 데이터 일시적 단발성 조회 (필요 시 사용)
  Future<Map<String, dynamic>?> fetchCradleData(String babyId) async {
    try {
      final response = await dioRequest.get(
        '${HttpConstants.CRADLE}/cradle/data/$babyId',
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      print("❌ [CradleApi] 크래들 센서 데이터 API 에러: $e");
      return null;
    }
  }
}

// API 레이어를 싱글톤처럼 간편하게 쓰기 위해 전역 인스턴스 선언
final cradleApi = CradleApi();
