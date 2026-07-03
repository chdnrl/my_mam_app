import 'package:my_mam_app/utils/DioRequest.dart';
import 'package:my_mam_app/viewmodels/terms.dart';
import 'package:my_mam_app/constants/index.dart';

Future<List<Term>> getTermsAPI() async {
  return ((await dioRequest.get(HttpConstants.TERMS_LIST)) as List).map((item) {
    return Term.fromJSON(item as Map<String, dynamic>);
  }).toList();
}
