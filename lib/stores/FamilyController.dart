import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/api/familyMember.dart';
// 🌟 기존 내부 임시 클래스를 삭제하고, 관리되고 있는 고유 모델을 불러옵니다.
import 'package:my_mam_app/viewmodels/familyMember.dart';

class FamilyController extends GetxController {
  // 🚀 반응형 가족 목록 변수 (viewmodels의 FamilyMember 사용)
  var familyList = <FamilyMember>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFamilyMembers(); // 화면 진입 시 실시간 데이터 자동 조회
  }

  /// 📥 명세서 API를 호출하여 가져온 데이터를 JSON 팩토리를 통해 모델 변환 후 UI 리스트에 바인딩
  Future<void> fetchFamilyMembers() async {
    try {
      isLoading.value = true;

      // 🌐 새로 만든 queryExec API 호출
      final List<dynamic>? rawData = await getFamilyInvitationListAPI();

      if (rawData != null) {
        // factory FamilyMember.fromJSON 데이터 변환 규격 일괄 적용
        familyList.value = rawData
            .map((json) => FamilyMember.fromJSON(json as Map<String, dynamic>))
            .toList();

        print("📊 [FamilyController] 파싱 성공 완료. 멤버 수: ${familyList.length}명");
      }
    } catch (e) {
      print("❌ [FamilyController] 목록 바인딩 에러: $e");
      Get.snackbar("에러", "가족 초대 목록을 불러오지 못했습니다.");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔄 [권한 제어] 특정 가족의 권한 스위치를 토글할 때 자바 서버에 저장하는 함수
  Future<void> toggleFamilyPermission(
    FamilyMember member,
    bool newValue,
  ) async {
    try {
      isLoading.value = true; // 통신 중 로딩바 활성화 (선택 사항)

      // bool 값을 서버 규격 코드(0 또는 1)로 변환
      int targetFlag = newValue ? 1 : 0;

      // 🌐 자바 command API 호출
      bool isSuccess = await changeFamilyDeviceShareAPI(
        inviteId: member.id,
        shareFlag: targetFlag,
      );

      if (isSuccess) {
        // 🌟 [수정] 서버 반영 성공 시에만 모델 내부 rx 변수의 .value를 직접 변경합니다.
        member.isShared.value = newValue;

        Get.snackbar(
          "성공",
          "${member.name}님의 권한이 변경되었습니다.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
        );
      } else {
        Get.snackbar("실패", "서버 권한 변경에 실패했습니다.");
      }
    } catch (e) {
      Get.snackbar("실패", "권한 변경 중 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }

  /// ❌ [초대 취소 / 삭제] 가족 초대 내역을 완전히 취소하거나 기존 연결을 끊는 함수
  Future<bool> cancelFamilyInvitation(String inviteId) async {
    try {
      isLoading.value = true;

      // 🌐 자바 command API 호출
      bool isSuccess = await cancelFamilyInvitationAPI(inviteId: inviteId);

      if (isSuccess) {
        // 성공 시 RxList에서 해당 id를 가진 멤버를 즉시 도려내어 UI 리렌더링 유발
        familyList.removeWhere((member) => member.id == inviteId);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ [FamilyController] 초대 취소 중 에러: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
