import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/api/contract.dart';
import 'package:my_mam_app/viewmodels/contract.dart';

class ContractController extends GetxController {
  // 💡 UI 레이어가 관찰할 데이터 레이어 상태 변수
  final RxList<ContractModel> contracts = <ContractModel>[].obs;
  final Rxn<ContractModel> activeContract = Rxn<ContractModel>(); // 🌟 추가: 현재 활성화된 메인 계약서

  final RxBool isLoading = true.obs;
  final RxBool isContractLoading = true.obs; // 🌟 추가: 홈 화면 전용 로딩 바 상태

  // PDF 상세 파일 정보를 담을 반응형 상태 변수들
  final Rxn<ContractFileModel> pdfFileData = Rxn<ContractFileModel>();
  final RxBool isPdfLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 컨트롤러 생성 시 역사 목록과 활성화된 계약 정보를 동시에 로드합니다.
    // loadHistoryContracts();
    loadActiveContract();
  }

  /// 🔄 1. 역사 계약서 목록 데이터 로드 워크플로우
  Future<void> loadHistoryContracts() async {
    try {
      isLoading.value = true;
      final result = await ContractApi.fetchHistoryContracts();
      contracts.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔄 2. 🌟 추가: 이미 활성화된 현재의 계약 정보 로드 워크플로우
  Future<void> loadActiveContract() async {
    try {
      isContractLoading.value = true;
      activeContract.value = null; // 🌟 [안전장치] 이전 데이터 청소
      final result = await ContractApi.fetchActiveContract();
      activeContract.value = result;
    } catch (e) {
      print("❌ [컨트롤러 - 활성화 계약 조회 오류]: $e");
      activeContract.value = null; // 🌟 에러 시 null 방어
    } finally {
      isContractLoading.value = false;
    }
  }

  /// 🔄 3. 계약서 활성화 트랜잭션 핸들러
  Future<void> executeContractActivation(ContractModel targetContract) async {
    // 중복 클릭 방지 배리어 토글 온
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFF785186))), barrierDismissible: false);

    // API 호출
    bool isSuccess = await ContractApi.activateContract(targetContract.contractId);
    Get.back(); // 배리어 해제

    if (isSuccess) {
      Get.snackbar(
        "계약 활성화 성공",
        "${targetContract.customerName ?? '고객'}님의 계약서로 연동되었습니다.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF785186),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );

      // 🌟 중요: 활성화가 성공하면 역사 목록 리프레시와 동시에 메인 계약서 정보도 다시 받아옵니다.
      loadHistoryContracts();
      loadActiveContract();
    } else {
      Get.snackbar(
        "오류 안내",
        "서버 컨디션 문제로 활성화에 실패했습니다. 다시 시도해 주세요.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
    }
  }

  // 🧮 [🌟 추가 변수] 총 입실 기간 계산 (sdate ~ edate)
  int get totalStayingDays {
    final contract = activeContract.value;
    if (contract == null || contract.sdate.isEmpty || contract.edate.isEmpty) return 14;
    try {
      final start = DateTime.parse(contract.sdate.replaceAll('.', '-'));
      final end = DateTime.parse(contract.edate.replaceAll('.', '-'));
      return end.difference(start).inDays;
    } catch (_) {
      return 14;
    }
  }

  // 현재 지나간 입실 일수 계산 (sdate ~ 오늘)
  int get currentStayingDays {
    final contract = activeContract.value;
    if (contract == null || contract.sdate.isEmpty) return 0;
    try {
      final start = DateTime.parse(contract.sdate.replaceAll('.', '-'));
      final today = DateTime.now();

      if (today.isBefore(start)) return 0; // 입실 전이면 0일차

      final diff = today.difference(start).inDays;
      return diff > totalStayingDays ? totalStayingDays : diff; // 최대치 방어
    } catch (_) {
      return 0;
    }
  }

  /// 계약서 PDF 원격 fullUri 및 파일명 로드 워크플로우
  Future<void> loadContractPdfFile(String fid) async {
    try {
      isPdfLoading.value = true;
      pdfFileData.value = null; // [안전장치] 이전 파일 흔적 지우기

      final result = await ContractApi.fetchContractFile(fid);
      if (result != null) {
        pdfFileData.value = result;
      }
    } catch (e) {
      print("❌ [컨트롤러 - PDF 파일 로드 실패]: $e");
      pdfFileData.value = null;
    } finally {
      isPdfLoading.value = false;
    }
  }
}
