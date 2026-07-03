import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_mam_app/constants/index.dart';

class TokenManager {
  // 메모리 캐싱용 변수 (디스크 조회를 최소화하여 성능 최적화)
  String _token = '';
  SharedPreferences? _prefs;

  /// [내부 인스턴스 획득] SharedPreferences 초기화 지연 로딩 처리
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// [초기화] 앱 구동 시 메인(main.dart)에서 최초 1회 비동기로 디스크 값을 메모리에 안착시킴
  Future<void> init() async {
    final prefs = await _getPrefs();
    _token = prefs.getString(GlobalConstants.TOKEN_KEY) ?? "";
  }

  /// [토큰 저장] 로컬 스토리지 기기 및 런타임 캐시 동시 저장
  Future<void> setToken(String val) async {
    final prefs = await _getPrefs();
    // 'mymam-auth=' 문자열이 중복 결합되는 대참사 원천 차단
    String pureToken = val.replaceAll("mymam-auth=", "").trim();

    await prefs.setString(GlobalConstants.TOKEN_KEY, pureToken);
    _token = pureToken; // 메모리 값 즉시 갱신
  }

  /// [토큰 획득] 인터셉터가 동기/비동기 상관없이 안전하게 꺼내 쓰도록 보장
  Future<String> getToken() async {
    if (_token.isEmpty) {
      final prefs = await _getPrefs();
      _token = prefs.getString(GlobalConstants.TOKEN_KEY) ?? "";
    }
    return _token;
  }

  /// [토큰 제거] 로그아웃 시 디스크 및 메모리 완전 소거
  Future<void> removeToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(GlobalConstants.TOKEN_KEY);
    _token = "";
  }
}

// 전역 공유 토큰 매니저 객체 선언
final tokenManager = TokenManager();
