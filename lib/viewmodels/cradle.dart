// viewmodels/user.dart (예시)
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class CradleData {
  final RxString temp = "0.0".obs; // 체온
  final RxString weight = "0.0".obs; // 체중
  final RxString amount = "0".obs; // 수유량
  final RxString time = "00:00".obs; // 수유시간

  // 서버 데이터를 받아와서 Rx 변수를 업데이트하는 함수
  void updateFromApi(Map<String, dynamic> json) {
    temp.value = json['temp'] ?? "0.0";
    weight.value = json['weight'] ?? "0.0";
    amount.value = json['amount'] ?? "0";
    time.value = json['time'] ?? "00:00";
  }
}
