class AppMessages {
  /// 💡 1. [상태 코드별 명확한 한글 문구]
  static const Map<String, String> _statusMessages = {
    '200': '요청이 정상적으로 처리되었습니다.',
    'SERVER_ERROR': '서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
  };

  /* 🔤 기존 영문 에러 메시지 매핑 테이블 (향후 사용을 위해 주석 처리 보존)
  static const Map<String, String> _englishTranslation = {
    'invalid password': '현재 비밀번호가 올바르지 않습니다.',
    'password mismatch': '새 비밀번호가 일치하지 않습니다.',
    'weak password': '비밀번호는 영문, 숫자 포함 8자 이상이어야 합니다.',
    'user not found': '존재하지 않는 회원 정보입니다.',
    'duplicate email': '이미 가입된 이메일 주소입니다.',
    'duplicate user': '이미 등록된 회원 정보입니다.',
    'invalid certification code': '인증 코드가 올바르지 않거나 만료되었습니다.',
    'invalid invite code': '초대 코드가 유효하지 않습니다.',
    'unauthorized': '인증 세션이 만료되었습니다. 다시 로그인해 주세요.',
    'forbidden': '접근 권한이 없습니다.',
    'invalid input': '입력 형식이 올바르지 않습니다. 다시 확인해 주세요.',
  };
  */

  /// 🎯 [핵심 함수] 번역 과정을 거치지 않고 자바 서버 메시지를 그대로 출력합니다.
  /// 🎯 [핵심 함수] 자바 서버가 준 message를 최우선으로 출력합니다.
  static String getMessage(String status, {String? serverCustomMessage}) {
    // 1️⃣ [1순위] 서버가 준 message가 존재한다면 (성공이든 400 에러든) 무조건 그대로 화면에 출력!
    if (serverCustomMessage != null && serverCustomMessage.trim().isNotEmpty) {
      return serverCustomMessage;
    }

    // 2️⃣ [2순위] 만약 서버가 준 message가 없을 때만 상태코드(200, 400 등) 기반 백업 메시지 출력
    return _statusMessages[status] ?? '오류가 발생했습니다. (상태코드: $status)';
  }

  /// 🎨 상태 코드에 따라 에러(빨간색) / 성공(보라색) 디자인 판단
  static bool checkIsError(String status) {
    return status != '200'; // 200이 아니면 무조건 에러(true) -> 빨간색 스낵바
  }
}
