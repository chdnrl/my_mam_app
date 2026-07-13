import 'package:my_mam_app/viewmodels/user.dart';

/// 📜 1. 청구서 메인 목록 모델 (billingList)
class BillingModel {
  final String billingId;
  final String contractId;
  final String sysCid;
  final String sysName;
  final int totAmt;
  final String createDt;
  final SubCode status;

  BillingModel({
    required this.billingId,
    required this.contractId,
    required this.sysCid,
    required this.sysName,
    required this.totAmt,
    required this.createDt,
    required this.status,
  });

  factory BillingModel.fromJSON(Map<String, dynamic> json) {
    return BillingModel(
      billingId: json["billingId"]?.toString() ?? "",
      contractId: json["contractId"]?.toString() ?? "",
      sysCid: json["sysCid"]?.toString() ?? "",
      sysName: json["sysName"]?.toString() ?? "",
      totAmt: int.tryParse(json["totAmt"]?.toString() ?? "0") ?? 0,
      createDt: json["createDt"]?.toString() ?? "",
      status: SubCode.fromJSON(json["status"]),
    );
  }
}

/// 📜 2. 청구서 상세 내역 모델 (billingDetail)
class BillingDetailModel {
  final String billingId;
  final String custCode;
  final String custName;
  final String goodsName;
  final SubCode payKind;
  final String payAccno;
  final String subPayKind;
  final SubCode payStatus;
  final String autNo;
  final String payDate;
  final int baseAmt;
  final int taxExemptAmt;
  final int vatAmt;
  final int totAmt;

  BillingDetailModel({
    required this.billingId,
    required this.custCode,
    required this.custName,
    required this.goodsName,
    required this.payKind,
    required this.payAccno,
    required this.subPayKind,
    required this.payStatus,
    required this.autNo,
    required this.payDate,
    required this.baseAmt,
    required this.taxExemptAmt,
    required this.vatAmt,
    required this.totAmt,
  });

  factory BillingDetailModel.fromJSON(Map<String, dynamic> json) {
    return BillingDetailModel(
      billingId: json["billingId"]?.toString() ?? "",
      custCode: json["custCode"]?.toString() ?? "",
      custName: json["custName"]?.toString() ?? "",
      goodsName: json["goodsName"]?.toString() ?? "",
      payKind: SubCode.fromJSON(json["payKind"]),
      payAccno: json["payAccno"]?.toString() ?? "",
      subPayKind: json["subPayKind"]?.toString() ?? "",
      payStatus: SubCode.fromJSON(json["payStatus"]),
      autNo: json["autNo"]?.toString() ?? "",
      payDate: json["payDate"]?.toString() ?? "",
      baseAmt: int.tryParse(json["baseAmt"]?.toString() ?? "0") ?? 0,
      taxExemptAmt: int.tryParse(json["taxExemptAmt"]?.toString() ?? "0") ?? 0,
      vatAmt: int.tryParse(json["vatAmt"]?.toString() ?? "0") ?? 0,
      totAmt: int.tryParse(json["totAmt"]?.toString() ?? "0") ?? 0,
    );
  }
}

/// 📜 3. 실제 PG 결제 요청을 조립하기 위한 결제 마스터 모델 (billingPayment)
class BillingPaymentModel {
  final String billingId;
  final String custCode;
  final String custName;
  final String custMobile;
  final String custEmail;
  final String contractId;
  final List<BillingItem> items;
  final int totAmt;

  BillingPaymentModel({
    required this.billingId,
    required this.custCode,
    required this.custName,
    required this.custMobile,
    required this.custEmail,
    required this.contractId,
    required this.items,
    required this.totAmt,
  });

  factory BillingPaymentModel.fromJSON(Map<String, dynamic> json) {
    var list = json["items"] as List? ?? [];
    List<BillingItem> parsedItems = list.map((i) => BillingItem.fromJSON(i)).toList();

    return BillingPaymentModel(
      billingId: json["billingId"]?.toString() ?? "",
      custCode: json["custCode"]?.toString() ?? "",
      custName: json["custName"]?.toString() ?? "",
      custMobile: json["custMobile"]?.toString() ?? "",
      custEmail: json["custEmail"]?.toString() ?? "",
      contractId: json["contractId"]?.toString() ?? "",
      items: parsedItems,
      totAmt: int.tryParse(json["totAmt"]?.toString() ?? "0") ?? 0,
    );
  }
}

/// 📜 3-1. 청구 내부 세부 아이템 내역
class BillingItem {
  final String itemName;
  final int payAmt;

  BillingItem({required this.itemName, required this.payAmt});

  factory BillingItem.fromJSON(Map<String, dynamic> json) {
    return BillingItem(
      itemName: json["itemName"]?.toString() ?? "",
      payAmt: int.tryParse(json["payAmt"]?.toString() ?? "0") ?? 0,
    );
  }
}
