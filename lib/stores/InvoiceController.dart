import 'package:get/get.dart';
import 'package:my_mam_app/api/invoice.dart';
import 'package:my_mam_app/viewmodels/invoice.dart';

class InvoiceController extends GetxController {
  // 지름길 제공
  static InvoiceController get to => Get.find<InvoiceController>();

  // 💡 리액티브 옵저버블 변수 선언 영역
  final RxList<BillingModel> billingList = <BillingModel>[].obs;
  final Rxn<BillingDetailModel> selectedDetail = Rxn<BillingDetailModel>();
  final Rxn<BillingPaymentModel> activePaymentMeta = Rxn<BillingPaymentModel>();

  // 화면 단 컨트롤용 로딩 트리거 변수
  final RxBool isListLoading = false.obs;
  final RxBool isDetailLoading = false.obs;

  /// 🔄 워크플로우 1: 전체 청구 마스터 목록 로드
  Future<void> loadInvoice() async {
    try {
      isListLoading.value = true;
      final result = await InvoiceApi.fetchBillingList();
      billingList.assignAll(result);
    } finally {
      isListLoading.value = false;
    }
  }

  /// 🔄 워크플로우 2: 상세 영수증 보기 타겟 조회
  Future<void> loadInvoiceDetail(String billingId) async {
    try {
      isDetailLoading.value = true;
      // 🌟 [안전장치] 진입 즉시 이전 영수증 데이터를 깨끗하게 비웁니다.
      selectedDetail.value = null;
      print("Controller->billingId----------$billingId");
      final result = await InvoiceApi.fetchBillingDetail(billingId);
      selectedDetail.value = result;
    } catch (e) {
      print("❌ 영수증 상세 조회 에러: $e");
      // 🚨 에러가 발생하면 확실하게 null로 굳혀서 이전 데이터 노출을 원천 차단합니다.
      selectedDetail.value = null;
    } finally {
      isDetailLoading.value = false;
    }
  }

  /// 🔄 워크플로우 3: 실제 카드 결제창을 띄우기 직전 백엔드 결제 스펙 획득
  Future<bool> preparePaymentGate(String billingId) async {
    try {
      isDetailLoading.value = true;
      // 🌟 [안전장치] 진입 즉시 이전 결제 정보를 깨끗하게 비웁니다.
      // (이 코드가 누락되어 세 번째 진입 시 두 번째 데이터가 보였던 것입니다!)
      activePaymentMeta.value = null;
      print("Controller->billingId----------$billingId");
      final result = await InvoiceApi.fetchBillingPayment(billingId);
      if (result != null) {
        activePaymentMeta.value = result;
        return true;
      }
      return false;
    } catch (e) {
      print("❌ 청구서 내역 불러오기 에러 차단: $e");
      // 🚨 에러가 발생해도 확실하게 null 처리하여 데이터 오염을 막습니다.
      activePaymentMeta.value = null;
      return false;
    } finally {
      isDetailLoading.value = false;
    }
  }
}
