import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/viewmodels/familyMember.dart';
import 'package:my_mam_app/stores/FamilyController.dart'; // 명칭에 맞게 컨트롤러 임포트

class FamilyManagementPage extends StatefulWidget {
  const FamilyManagementPage({super.key});

  @override
  State<FamilyManagementPage> createState() => _FamilyManagementPageState();
}

class _FamilyManagementPageState extends State<FamilyManagementPage> {
  // 🚀 GetX 컨트롤러 등록 및 연결
  final FamilyController _controller = Get.put(FamilyController());

  /// 1️⃣ [가족 삭제 / 초대 취소] 완전히 연결을 끊고 목록에서 삭제
  void _handleDeleteMember(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => _buildActionDialog(
        title: "${member.name} 연결 삭제",
        content: member.isCodePending.value
            ? "아직 코드를 입력하지 않은 초대입니다.\n초대를 취소하시겠습니까?"
            : "정말로 이 가족을 삭제하시겠습니까?\n삭제 즉시 스마트 크래들 및 아기 정보 접근 권한이 완전히 회수됩니다.",
        confirmText: member.isCodePending.value ? "초대 취소하기" : "삭제하기",
        confirmColor: Colors.redAccent,
        onConfirm: () async {
          Get.back(); // 다이얼로그 닫기

          // 🌐 [수정] 컨트롤러를 통해 자바 백엔드 API 호출 처리
          bool isServerSuccess = await _controller.cancelFamilyInvitation(
            member.id,
          );

          if (isServerSuccess) {
            // 💡 컨트롤러 내부에서 이미 리스트 제거(removeWhere)를 수행하므로 알림만 띄워줍니다.
            Get.snackbar(
              "알림",
              member.isCodePending.value
                  ? "${member.name}님에게 보낸 초대가 취소되었습니다."
                  : "${member.name}님이 가족 목록에서 삭제되었습니다.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.white,
            );
          } else {
            Get.snackbar(
              "에러",
              "서버 통신에 실패했습니다. 다시 시도해주세요.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.white,
            );
          }
        },
      ),
    );
  }

  /// 2️⃣ [스마트 크래들 실시간 차단 / 공유 토글] 권한 잠금 기능
  void _toggleSharing(FamilyMember member, bool newValue) {
    String title = newValue ? "스마트 크래들 공유" : "스마트 크래들 차단";
    String content = newValue
        ? "${member.name}님에게 스마트 크래들 실시간 영상 시청 권한을 부여하시겠습니까?"
        : "${member.name}님의 스마트 크래들 시청을 즉시 차단하시겠습니까?\n(차단 시 실시간 영상 화면에 진입할 수 없습니다.)";

    showDialog(
      context: context,
      builder: (context) => _buildActionDialog(
        title: title,
        content: content,
        confirmText: newValue ? "허용하기" : "차단하기",
        confirmColor: newValue ? const Color(0xFF785186) : Colors.amber[800]!,
        onConfirm: () async {
          Get.back();
          // 컨트롤러 비즈니스 함수에 위임 및 서버 전송
          await _controller.toggleFamilyPermission(member, newValue);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "가족 모드 관리",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      // 🚀 Obx 바인더 영역: 로딩 상태 스피너 연동 및 실시간 List 드로잉 처리
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF785186)),
            ),
          );
        }

        if (_controller.familyList.isEmpty) {
          return const Center(
            child: Text(
              "등록된 가족 멤버 혹은 초대 내역이 없습니다.",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: _controller.familyList.length,
          itemBuilder: (context, index) {
            return _buildFamilyCard(_controller.familyList[index]);
          },
        );
      }),
    );
  }

  Widget _buildFamilyCard(FamilyMember member) {
    Color mainTextColor = member.isCodePending.value
        ? const Color(0xFFBBBBBB)
        : const Color(0xFF333333);
    Color subTextColor = member.isCodePending.value
        ? const Color(0xFFDDDDDD)
        : const Color(0xFF777777);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.birthDate.isNotEmpty ? member.birthDate : "-",
                      style: TextStyle(fontSize: 15, color: subTextColor),
                    ),
                  ],
                ),
                _buildStatusBadge(member),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: member.isCodePending.value
                      ? null
                      : () => _handleDeleteMember(member),
                  child: Text(
                    "가족 삭제",
                    style: TextStyle(
                      color: member.isCodePending.value
                          ? const Color(0xFFDDDDDD)
                          : Colors.red[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // 🌟 [수정] 텍스트가 member.isShared.value 변화를 실시간 감지하도록 Obx로 감싸기
                    Obx(
                      () => Text(
                        member.isShared.value ? "스마트 크래들 공유중" : "스마트 크래들 차단됨",
                        style: TextStyle(
                          color: member.isShared.value
                              ? subTextColor
                              : Colors.amber[800],
                          fontSize: 14,
                          fontWeight: member.isShared.value
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 45,
                      height: 25,
                      child: Transform.scale(
                        scale: 0.85,
                        // 🌟 [수정] Switch가 토글될 때 해당 카드만 새로고침 되도록 Obx로 감싸기
                        child: Obx(
                          () => Switch(
                            value: member.isShared.value,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF785186),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFE0E0E0),
                            trackOutlineColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF785186);
                              }
                              return const Color(0xFFEEEEEE);
                            }),
                            onChanged: member.isCodePending.value
                                ? null
                                : (value) => _toggleSharing(member, value),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(FamilyMember member) {
    // 🌟 [수정] 내부에 관찰 변수가 있으므로 전체를 Obx로 리턴하도록 감싸기
    return Obx(() {
      String text = member.isCodePending.value
          ? "코드 입력 전"
          : (member.isConnected.value ? "접속중" : "미접속");

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!member.isCodePending.value) ...[
              Icon(
                Icons.circle,
                size: 12,
                color: member.isConnected.value
                    ? const Color(0xFF785186)
                    : const Color(0xFFBBBBBB),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                height: 1.5,
                color: Color(0xFF666666),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEEEEEE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "취소",
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
