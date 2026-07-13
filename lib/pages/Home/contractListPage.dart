import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/api/contract.dart';
import 'package:my_mam_app/stores/ContractController.dart';
import 'package:my_mam_app/viewmodels/contract.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/viewmodels/contract.dart';

class ContractListPage extends StatefulWidget {
  const ContractListPage({super.key});

  @override
  State<ContractListPage> createState() => _ContractListPageState();
}

class _ContractListPageState extends State<ContractListPage> {
  // 💡 컨트롤러 주입
  final ContractController controller = Get.put(ContractController());

  @override
  void initState() {
    super.initState();
    // 🎯 화면이 메모리에 올라와 켜지는 바로 그 순간 딱 한 번 이력 데이터를 가져옵니다.
    controller.loadHistoryContracts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "전체 계약서 목록",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF785186)));
        }

        if (controller.contracts.isEmpty) {
          return const Center(
            child: Text("이력에 등록된 계약서가 없습니다.", style: TextStyle(color: Colors.grey, fontSize: 15)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.contracts.length,
          itemBuilder: (context, index) {
            return _buildContractCard(context, controller.contracts[index], controller);
          },
        );
      }),
    );
  }

  Widget _buildContractCard(BuildContext context, ContractModel data, ContractController controller) {
    String displayDate = data.contractDate.isNotEmpty ? data.contractDate : "-";
    String displayPeriod = data.period.isNotEmpty && data.period != '0' ? data.period : "${data.sdate} ~ ${data.edate}";
    String roomNoInfo = data.roomNo.isNotEmpty ? "${data.roomLevelName} ${data.roomNo}호" : "호실 미지정";
    String titleName = data.customerName.isNotEmpty ? "${data.customerName}님 산후조리 계약서" : "산후조리 계약서";

    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: ShapeDecoration(
        color: const Color(0xFF785186),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadows: const [BoxShadow(color: Color(0x26000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("계약일: $displayDate", style: const TextStyle(color: Colors.white, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.isCurrentIn ? "현재 입실중" : "퇴실함",
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            titleName,
            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(roomNoInfo, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  displayPeriod,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              _buildActionButton(data, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ContractModel data, ContractController controller) {
    bool isSelected = data.isSelected;

    return ElevatedButton(
      // 💡 비즈니스 핸들러 호출 부를 controller 타겟으로 연동
      onPressed: isSelected ? null : () => controller.executeContractActivation(data),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: const Color(0xFF583166),
        disabledForegroundColor: const Color(0xFFD7B2E1),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minimumSize: const Size(120, 38),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        isSelected ? "현재 선택된 계약" : "이 계약으로 전환",
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// class ContractListPage extends StatelessWidget {
//   const ContractListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 가상 데이터 리스트 (이후 서버에서 받아온 데이터로 대체)

//     final List<ContractModel> contracts = [
//       ContractModel(
//         contractDate: "2026.04.21",

//         // centerName: "궁 산후조리원 삼성점",

//         // roomInfo: "스탠다드 1302호",
//         period: "2025.05.18 ~ 2025.06.01",

//         isCurrentIn: true,

//         isSelected: true,

//         id: '',

//         resId: '',

//         pid: '',

//         sdate: '',

//         edate: '',

//         contractDoc: '',

//         cfDate: '',

//         ctDate: '',

//         idate: '',

//         totalMoney: 0,

//         status: '',

//         customerCode: '',

//         customerName: '',

//         birth: '',

//         roomId: '',

//         roomNo: '',

//         roomLevel: '',

//         roomLevelName: '',

//         onlineDocId: '',

//         signType: '',

//         payStatus: '',

//         signStatus: '',

//         payAccount: '',

//         mobilePhone: '',

//         email: '',

//         pmSrv: '',

//         ctype: '',

//         signReqUid: '',

//         discAmt: '',

//         signName: '',

//         sreqId: '',

//         memo: '',
//         maternalUserId: '',
//         contractId: '',
//         gid: '',
//         sysCid: '',
//         curVer: '',
//       ),

//       ContractModel(
//         contractDate: "2026.04.21",

//         // centerName: "궁 산후조리원 삼성점",

//         // roomInfo: "스탠다드 1302호",
//         period: "2025.05.18 ~ 2025.06.01",

//         isCurrentIn: false,

//         isSelected: false,

//         id: '',

//         resId: '',

//         pid: '',

//         sdate: '',

//         edate: '',

//         contractDoc: '',

//         cfDate: '',

//         ctDate: '',

//         idate: '',

//         totalMoney: 0,

//         status: '',

//         customerCode: '',

//         customerName: '',

//         birth: '',

//         roomId: '',

//         roomNo: '',

//         roomLevel: '',

//         roomLevelName: '',

//         onlineDocId: '',

//         signType: '',

//         payStatus: '',

//         signStatus: '',

//         payAccount: '',

//         mobilePhone: '',

//         email: '',

//         pmSrv: '',

//         ctype: '',

//         signReqUid: '',

//         discAmt: '',

//         signName: '',

//         sreqId: '',

//         memo: '',
//         maternalUserId: '',
//         contractId: '',
//         gid: '',
//         sysCid: '',
//         curVer: '',
//       ),

//       // 데이터가 추가될수록 리스트가 길어집니다.
//     ];

//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,

//         elevation: 0,

//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),

//           onPressed: () => Get.back(),
//         ),

//         title: const Text(
//           "전체 계약서 목록",

//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//         ),

//         centerTitle: true,
//       ),

//       body: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 20),

//         itemCount: contracts.length,

//         itemBuilder: (context, index) {
//           return _buildContractCard(context, contracts[index]);
//         },
//       ),
//     );
//   }

//   // 데이터 기반 동적 카드 빌더

//   Widget _buildContractCard(BuildContext context, ContractModel data) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12, top: 4), // 마진 살짝 축소

//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // 상하 패딩을 20 -> 14로 줄임

//       decoration: ShapeDecoration(
//         color: const Color(0xFF785186),

//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

//         shadows: const [BoxShadow(color: Color(0x26000000), blurRadius: 3, offset: Offset(0, 1), spreadRadius: 1)],
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,

//         mainAxisSize: MainAxisSize.min,

//         children: [
//           // 1. 상단: 계약일 및 상태 태그
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,

//             children: [
//               Text("계약일: ${data.contractDate}", style: const TextStyle(color: Colors.white, fontSize: 13)),

//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14, // 가로 패딩 살짝 축소

//                   vertical: 4, // 세로 패딩 축소
//                 ),

//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white, width: 1.2),

//                   borderRadius: BorderRadius.circular(20),
//                 ),

//                 child: Text(
//                   data.isCurrentIn ? "현재 입실중" : "퇴실함",

//                   style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 8), // 상단과 중간 사이 간격 (16 -> 8)
//           // 2. 중간: 조리원 및 호실 정보
//           Text(
//             data.centerName,

//             style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 2), // 조리원명과 호실 정보 사이 간격 (4 -> 2)

//           Text(data.roomInfo, style: const TextStyle(color: Colors.white, fontSize: 16)),

//           const SizedBox(height: 12), // 중간과 하단 버튼 사이 간격 (24 -> 12)
//           // 3. 하단: 기간 및 액션 버튼
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,

//             crossAxisAlignment: CrossAxisAlignment.center, // 아래로 붙지 않고 중앙 정렬로 변경하여 콤팩트하게 함

//             children: [
//               Expanded(
//                 child: Text(
//                   data.period,

//                   style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//               ),

//               const SizedBox(width: 10),

//               _buildActionButton(data.isSelected),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // 선택 여부에 따른 하단 버튼 (현재 선택됨 / 전환하기)

//   Widget _buildActionButton(bool isSelected) {
//     return ElevatedButton(
//       onPressed: isSelected ? null : () {},

//       style: ElevatedButton.styleFrom(
//         disabledBackgroundColor: const Color(0xFF583166),

//         disabledForegroundColor: const Color(0xFFD7B2E1),

//         backgroundColor: Colors.white,

//         foregroundColor: Colors.black,

//         elevation: 0,

//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),

//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // 버튼 내부 세로 여백 제거

//         minimumSize: const Size(120, 38), // 버튼 높이 자체를 줄임 (44 -> 38)

//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),

//       child: Text(
//         isSelected ? "현재 선택된 계약" : "이 계약으로 전환",

//         style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }
