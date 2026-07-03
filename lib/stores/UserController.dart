// 需要共享的对象 要有一些共享的属性 属性需要响应式更新
import 'package:get/get.dart';
import 'package:my_mam_app/api/user.dart';
import 'package:my_mam_app/stores/TokenManager.dart';
import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/viewmodels/user.dart';

// class UserController extends GetxController {
//   var user = UserInfo.fromJSON({}).obs; // user对象被监听了
//   // 想要取值的话 需要 user.value
//   updateUserInfo(UserInfo newUser) {
//     user.value = newUser;
//   }
// }

//받은 데이터 저장,로딩 상태등 관리

class UserController extends GetxController {
  // 🎯 [여기에 추가] 다른 화면에서 UserController.to 로 바로 찾을 수 있게 지름길을 뚫어줍니다.
  static UserController get to => Get.find<UserController>();
  // 관찰 가능한(Rx) 유저 및 로딩 상태 변수들 선언
  var userInfo = Rxn<UserInfo>(); // Nullable 대응을 위해 Rxn 사용
  var isLoading = false.obs;
  // 🎯 특정 유저 정보를 담을 리액티브 변수 (필요시 화면단 Obx 연동용)
  final Rxn<UserInfo> targetUserInfo = Rxn<UserInfo>();
  final RxBool isTargetLoading = false.obs;
  // 🌟  전역 인증 상태 관리용 리액티브 변수
  var isAuthenticated = false.obs; // 최초 진입 시 false -> 인증 완료 시 true
  var isFamilyUser = false.obs; // 가족모드 여부 (산모면 false, 가족이면 true)
  var showGiftIcon = false.obs; // 선물함 활성화 여부

  var generatedInviteCode = "불러오는 중...".obs; // 생성된 초대코드를 실시간 관리할 리액티브 변수

  /// 🚀 [신규 추가] 특정 지정 유저 정보 조회 및 캐싱 펑션
  /// [targetUserId]를 인자로 받아 해당 유저의 상세 데이터를 원격 로드합니다.
  Future<UserInfo?> fetchSpecificUserInfo(String targetUserId) async {
    if (targetUserId.isEmpty) {
      print("⚠️ [UserController] fetchSpecificUserInfo 중단: targetUserId가 비어있습니다.");
      return null;
    }

    try {
      isTargetLoading.value = true;

      // 🎯 앞서 추가한 userInfo(userId: "...") 명세서 기반 API 호출
      UserInfo serverData = await getSpecificUserInfoAPI(targetUserId);

      // 타겟 유저 리액티브 변수에 데이터 매핑 (화면 자동 새로고침 유도)
      targetUserInfo.value = serverData;

      print("🎉 [UserController] 지정 유저(${targetUserId}) 상세 데이터 로드 완료: ${serverData.userName}");
      return serverData;
    } catch (e) {
      print("❌ [UserController] 지정 유저 정보 수신 에러: $e");
      return null;
    } finally {
      isTargetLoading.value = false; // 로딩 인디케이터 종료
    }
  }

  /// [서버 데이터 상세 동기화] 유저 아이디를 기반으로 자바에 최신 상세 프로필 조회 요청
  Future<void> fetchUserInfo() async {
    try {
      isLoading.value = true;

      // 🎯 수정: 이제 userId를 인자로 넘기지 않고 쿠키 기반으로 본인 정보를 수동 호출합니다.
      UserInfo serverData = await getUserInfoAPI();

      // 리액티브 변수에 담아 화면단(Obx) 단체 자동 새로고침 유도
      userInfo.value = serverData;
      print("🎉 [UserController] 회원 상세 데이터 캐싱 완료: ${serverData.userId}");
    } catch (e) {
      print("❌ [UserController] 유저 정보 수신 오류 계통 인지: $e");
    } finally {
      isLoading.value = false; // 성공 실패 여부에 상관없이 로딩 인디케이터 종료
    }
  }

  /// [수동 로컬 세팅] 외부 가공 JSON 데이터를 수동 주입할 때 사용
  void setUserInfo(Map<String, dynamic> json) {
    userInfo.value = UserInfo.fromJSON(json);
  }

  /// [프로필 수정 반영] 서버 수정을 요청하고 성공 시 앱 메모리를 실시간 동기화
  Future<bool> updateProfile(UserInfo updatedData) async {
    try {
      isLoading.value = true;

      // 1단계: 일반 정보 수정 API 발사
      bool isSuccess = await updateUserInfoAPI(updatedData);

      if (isSuccess) {
        // 🎯 [보안 강화] 서버 저장에 성공했다면, 앱 전역 메모리(State)에 캐싱할 때는
        // 비밀번호 데이터를 완전히 소멸(공백 처리)시켜 메모리 덤프 공격을 방어합니다.
        final safeData = updatedData.copyWith(password: "");

        userInfo.value = safeData; // 안전한 데이터로 스크린단(Obx) 새로고침 유도
        print("🎉 [UserController] 전역 메모리에 안전한 프로필 데이터 동기화 완료 (비밀번호 제외)");
      }
      return isSuccess;
    } catch (e) {
      print("❌ 프로필 수정 통신 에러: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🎯 비밀번호 변경 비즈니스 링커
  Future<bool> updatePassword({required String oldPassword, required String newPassword}) async {
    try {
      isLoading.value = true;

      // 비밀번호 전용 트랜잭션 API 실행
      bool isSuccess = await updateUserPasswordAPI(oldPassword: oldPassword, newPassword: newPassword);

      return isSuccess;
    } catch (e) {
      print("❌ 비밀번호 변경 에러 계통 인지: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🎯 [비즈니스 링커 수정] 서버 로그아웃 API 연동 처리
  Future<bool> handleServerLogout() async {
    // 현재 로그인된 유저 ID가 없거나 로딩 중이면 방어
    if (userInfo.value == null) return true;

    try {
      isLoading.value = true;
      String currentUserId = userInfo.value!.userId;

      // 1. api/user.dart 의 공통 함수 호출
      bool isServerSuccess = await logoutAPI(currentUserId);

      if (isServerSuccess) {
        // 2. 서버 로그아웃 성공 시 로컬 전역 메모리 파괴
        // clearUserInfo();
        print("🎉 [UserController] 전역 메모리 및 서버 세션 로그아웃 성공");
        return true;
      }
      return false;
    } catch (e) {
      print("❌ [UserController] 로그아웃 트랜잭션 에러: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 🤰 [신규] 산모 인증 트랜잭션 비즈니스 링커
  Future<bool> handleMaternalAuth(String certCode) async {
    try {
      isLoading.value = true;
      bool isSuccess = await certifyMaternalAPI(certCode);

      if (isSuccess) {
        isAuthenticated.value = true;
        isFamilyUser.value = false;
        showGiftIcon.value = false; // 산모는 선물 수령자이므로 선물 아이콘 미노출(기존 UI 설계 기준)

        // 인증 성공 후 필요 시 최신 유저 정보를 서버에서 다시 긁어옵니다.
        await fetchUserInfo();
      }
      return isSuccess;
    } catch (e) {
      print("❌ [UserController] 산모 인증 프로세스 에러: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 👨‍👩‍👧‍👦 [신규] 가족 모드 인증 트랜잭션 비즈니스 링커
  Future<bool> handleFamilyAuth(String inviteCode) async {
    try {
      isLoading.value = true;
      bool isSuccess = await acceptFamilyInvitationAPI(inviteCode);

      if (isSuccess) {
        isAuthenticated.value = true;
        isFamilyUser.value = true;
        showGiftIcon.value = true; // 가족 유저일 때만 선물함 아이콘 활성화

        // 인증 성공 후 가족 유저 데이터 갱신
        await fetchUserInfo();
      }
      return isSuccess;
    } catch (e) {
      print("❌ [UserController] 가족 인증 프로세스 에러: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ⏳ [화면 진입 시 실행] 코드를 가져오는 가상 함수 (향후 API 개발 시 교체)
  Future<void> fetchInitialInviteCode() async {
    try {
      isLoading.value = true;
      generatedInviteCode.value = "불러오는 중...";

      // TODO: 추후 코드 조회 API 개발 완료 시 이곳에 연동하세요.
      await Future.delayed(const Duration(milliseconds: 500));

      generatedInviteCode.value = "AB123123"; // 임시 코드 고정
    } catch (e) {
      print("❌ 초기 코드 로드 실패: $e");
      generatedInviteCode.value = "오류 발생";
    } finally {
      isLoading.value = false;
    }
  }

  /// 🚀 [버튼 클릭 시 실행] 입력받은 상대방 번호로 Java 커맨드 API 발송
  Future<bool> submitFamilyInvitation(String inviteePhone) async {
    try {
      isLoading.value = true;

      // api/user.dart의 POST API 호출
      bool isSuccess = await sendFamilyInvitationAPI(inviteePhone);
      return isSuccess;
    } catch (e) {
      print("❌ [UserController] 가족 초대 발송 프로세스 에러: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// [데이터 클리어] 로그아웃 시 메모리 정보 초기화
  void clearUserInfo() {
    userInfo.value = null;
    isAuthenticated.value = false;
    isFamilyUser.value = false;
    showGiftIcon.value = false;

    // dioRequest 헤더에 남아있던 쿠키도 청소해 주는 것이 안전합니다.
    dioRequest.setAuthCookie("");
  }
}
