import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:get/get.dart'; // [추가] GetX 임포트
import 'package:my_mam_app/pages/ContractPdf/index.dart';
import 'package:my_mam_app/pages/Home/careCenterDetailPage.dart';
import 'package:my_mam_app/pages/Home/contractListPage.dart';
import 'package:my_mam_app/pages/Home/editMyInfoPage.dart';
import 'package:my_mam_app/pages/Home/familyManagementPage.dart';
import 'package:my_mam_app/pages/Home/inviteCodeGeneratePage.dart';
import 'package:my_mam_app/pages/Home/inviteGuidePage.dart';
import 'package:my_mam_app/pages/Home/invoiceDetailPage.dart';
import 'package:my_mam_app/pages/Home/invoiceListPage.dart';
import 'package:my_mam_app/pages/Home/myInfoPage.dart';
import 'package:my_mam_app/pages/Home/paymentPage.dart';
import 'package:my_mam_app/pages/Home/receiptDetailPage.dart';
import 'package:my_mam_app/pages/Home/smartCradlePage.dart';
import 'package:my_mam_app/pages/Login/index.dart';
import 'package:my_mam_app/pages/Home/index.dart';
import 'package:my_mam_app/pages/SignUp/completePage.dart';
import 'package:my_mam_app/pages/SignUp/index.dart';
import 'package:my_mam_app/pages/TermsAgree/index.dart';
import 'package:my_mam_app/pages/searchAndReservation/centerDetailPage.dart';
import 'package:my_mam_app/pages/searchAndReservation/index.dart';
import 'package:my_mam_app/pages/searchAndReservation/searchPage.dart';

Widget getRootWidget(String initialRoute) {
  // [수정] 1. WithForegroundTask로 감싸 앱이 백단으로 가도 끊기지 않게 생명주기를 추적합니다.
  // [수정] 2. 기존 MaterialApp을 GetMaterialApp으로 변경하여 GetX의 상태 및 다이얼로그(스낵바) 제어가 흐트러지지 않게 합니다.
  return WithForegroundTask(
    child: GetMaterialApp(
      title: 'My Mam App',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: getRootRoutes(),
    ),
  );
}
//완전히 꺼졌다가 켤 때 자동 로그인 처리하기1
// Widget getRootWidget(String initialRoutePath) { // 👈 인자(Path)를 받도록 수정
//   return WithForegroundTask(
//     child: GetMaterialApp(
//       title: 'My Mam App',
//       debugShowCheckedModeBanner: false,
//       initialRoute: initialRoutePath, // 👈 여기에 동적으로 할당됩니다.
//       routes: getRootRoutes(),
//     ),
//   );
// }
// 명확하고 깔끔하게 한 번에 감싸는 리턴문 표준안:
// Widget getRootWidgetStandard() {
//   return WithForegroundTask(
//     child: GetMaterialApp(
//       title: 'My Mam App',
//       debugShowCheckedModeBanner: false,
//       initialRoute: "/login",
//       routes: getRootRoutes(),
//     ),
//   );
// }

Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/home": (context) => MainPage(), //메인
    "/login": (context) => LoginPage(), //로그인
    "/termsAgree": (context) => TermsAgreementPage(), //서비스 이용 약관
    "/signUp": (context) => SignUpInfoPage(), //회원 가입
    "/signUpComplete": (context) => SignUpCompletePage(), //가입 완료
    "/myInfoPage": (context) => MyInfoPage(), //내 정보
    "/editMyInfoPage": (context) => EditMyInfoPage(), //정보 수정
    "/smartCradlePage": (context) => SmartCradlePage(), //실시간 스마트 크래들
    "/contractListPage": (context) => ContractListPage(), //전체 계약서
    "/inviteGuidePage": (context) => InviteGuidePage(), //가족 초대 코드 발급 1st
    "/inviteCodeGeneratePage": (context) => InviteCodeGeneratePage(), //가족 초대 코드 전송 2nd
    "/familyManagementPage": (context) => FamilyManagementPage(), //가족모드 관리
    "/contractPdfPage": (context) => ContractPdfScreen(), //계약서pdf
    "/invoiceListPage": (context) => InvoiceListPage(), //내 청구서 목록
    "/invoiceDetailPage": (context) => InvoiceDetailPage(), //청구서 내역
    "/paymentPage": (context) => PaymentPage(), //토스트페이먼트 결제페이지
    "/receiptDetailPage": (context) => ReceiptDetailPage(), //점표보기
    "/authScreen": (context) => AuthScreen(), //사용자 인증
    "/searchPage": (context) => SearchPage(), //산후조리원 검색
    "/centerDetailPage": (context) => CenterDetailPage(), //산후조리원 검색 상세페이지
    "/careCenterDetailPage": (context) => CareCenterDetailPage(), //산후조리원 정보
  };
}
