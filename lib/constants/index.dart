// 全局的常量
class GlobalConstants {
  // static const String BASE_URL ="https://127.0.0.1:9000/api/v1"; //@ApiServer=127.0.0.1:9000
  static const int TIME_OUT = 15; // 타임아웃(초)
  static const String TOKEN_KEY = "mymam-auth"; // token유지 key
  // -----------------------------------------------------------------
  // ⚠️ [중요] 주소 설정 (현재 테스트 환경에 맞는 주소 한 개만 주석을 해제하세요)
  // -----------------------------------------------------------------

  // ❌ 운영 서버 주소 (https)
  static const String BASE_URL = "https://sanhujori.plusrnd.com/api/v1";

  // ⭕ 안드로이드 에뮬레이터로 내 컴퓨터(로컬 자바 서버) 테스트하는 경우
  // 자바 서버가 일반 HTTP로 켜져있으므로 http:// 로 수정합니다.
  // static const String BASE_URL = "http://10.0.2.2:9000/api/v1";

  // ⭕ 실제 스마트폰(USB 연결)으로 내 컴퓨터 자바 서버 테스트하는 경우
  // static const String BASE_URL = "http://192.168.0.15:9000/api/v1";
}
// 요청 주소 인터페이스 상수

class HttpConstants {
  static const String LOGIN = "/login"; // 로그인url
  static const String LOGOUT = "/logOut";
  static const String REGISTER = "/account/applyRegister/cmd"; //회원가입
  static const String USER_PROFILE = '/account/queryExec'; // 사용자정보url
  static const String TERMS_LIST = '/termsList';
  static const String USER_UPDATE = '/account/command';
  static const String ACTIVATED_CONTRACTS =
      '/account/queryExec'; //Active 한 계약정보 보여주기
  static const String VALID_INVITATION =
      '/account/invitationCode/cmd'; //초대코드 유효성 검사(가족)
  static const String CRADLE = '/';
}
