import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:math';

import 'package:my_mam_app/pages/Home/inviteCodeGeneratePage.dart'; // 수학적 계산을 위해 추가

class InviteGuidePage extends StatefulWidget {
  const InviteGuidePage({super.key});

  @override
  State<InviteGuidePage> createState() => _InviteGuidePageState();
}

class _InviteGuidePageState extends State<InviteGuidePage> {
  // 테스트를 위해 현재 초대된 사람 수를 3명으로 설정
  int invitedCount = 3; // 인원수를 변경하며 테스트해보세요.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "초대 코드 발급하기",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Image.asset(
                "lib/assets/family_Image.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.75, // 화면 너비의 75% 정도로 축소
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            // 로고 이미지
            SvgPicture.asset(
              'lib/assets/logo_mymam.svg',
              width: 180,
              errorBuilder: (context, error, stackTrace) => const Text(
                "MYMAM",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF785186),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 중앙 안내 텍스트 박스
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    "마이맘 가족모드",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "마이맘 가족모드는 산모의 초대애 따라\n신생아의 실시간 카메라, 생체정보를 확인할 수 있는\n스마트 크래들과 산모님의 산후조리에 필요한\n선물을 간편하게 전달할 수 있는 모드입니다.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // 구분선 (이미지 참고)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Divider(color: Colors.grey.shade300, thickness: 1),
            ),

            // --- 이 아래 부분에서 높이 조절 ---
            const SizedBox(height: 0), // 기존 10에서 0으로 줄여서 간격을 좁힘

            Transform.translate(
              offset: const Offset(0, -1), // 위젯을 위로 20픽셀만큼 강제로 이동
              child: _buildCircularInviteStatus(),
            ),

            const SizedBox(height: 20), // 아래쪽 여백 확보
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: ElevatedButton(
          onPressed: () {
            // 화면 2로 이동
            Get.toNamed("/inviteCodeGeneratePage");
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const InviteCodeGeneratePage(),
            //   ),
            // );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF785186),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            "발급하기",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // 초대 인원에 따라 이미지 주변에 아이콘을 배치하는 위젯
  Widget _buildCircularInviteStatus() {
    double mainSize = 200; // 큰 이미지 사이즈
    double iconSize = 50; // 작은 보라색 원 사이즈

    // 12명까지의 배치 우선순위 각도 정의 (라디안 기준)
    final List<double> priorityAngles = [
      pi / 2, // 1: 6시 방향
      pi / 2 + pi / 6, // 2: 7시 방향
      pi / 2 - pi / 6, // 3: 5시 방향
      pi / 2 + 2 * pi / 6, // 4: 8시 방향
      pi / 2 - 2 * pi / 6, // 5: 4시 방향
      pi / 2 + 3 * pi / 6, // 6: 9시 방향
      pi / 2 - 3 * pi / 6, // 7: 3시 방향
      pi / 2 + 4 * pi / 6, // 8: 10시 방향
      pi / 2 - 4 * pi / 6, // 9: 2시 방향
      pi / 2 + 5 * pi / 6, // 10: 11시 방향
      pi / 2 - 5 * pi / 6, // 11: 1시 방향
      pi / 2 + 6 * pi / 6, // 12: 12시 방향
    ];

    return SizedBox(
      width: mainSize + 80, // 아이콘 배치를 위해 너비 확장
      height: mainSize + 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 메인 이미지 (스마트 크래들)
          Container(
            width: mainSize,
            height: mainSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF785186), // 예시 배경색
            ),
            child: ClipOval(
              child: Image.asset("lib/assets/image01.png", fit: BoxFit.cover),
            ),
          ),
          // 초대 인원 수(invitedCount)만큼 변두리에 아이콘 배치
          ...List.generate(invitedCount, (index) {
            double angle;

            // 1. 인원이 12명 이하일 때는 정의된 시계 방향 우선순위 사용
            if (invitedCount <= 12) {
              angle = priorityAngles[index];
            }
            // 2. 인원이 13명 이상으로 늘어나면 원을 균등하게 분할
            else {
              // 6시 방향(pi/2)부터 시작해서 원 한바퀴(2*pi)를 인원수로 나눔
              angle = (pi / 2) + (index * (2 * pi / invitedCount));
            }

            return Positioned(
              left:
                  (mainSize / 2 + 40) +
                  (mainSize / 1.7) * cos(angle) -
                  (iconSize / 2),
              top:
                  (mainSize / 2 + 40) +
                  (mainSize / 1.7) * sin(angle) -
                  (iconSize / 2),
              child: Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF9F89FC),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset("lib/assets/phone_Icon.png"),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
