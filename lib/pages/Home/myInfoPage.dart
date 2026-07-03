import 'package:dio/dio.dart'; // 업로드/통신 담당 (FormData 등 사용)
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_mam_app/constants/index.dart';

import 'package:my_mam_app/stores/UserController.dart';
import 'package:my_mam_app/utils/ToastUtils.dart';

// 🌐 프로젝트 내부의 글로벌 상수 주소 파일이 있다면 임포트하세요.
// 없다면 아래 _dio.post 내부에 직접 주소를 적으셔도 됩니다.
// import 'package:my_mam_app/constants/global_constants.dart';

class MyInfoPage extends StatefulWidget {
  final bool isFamilyMode;

  const MyInfoPage({super.key, this.isFamilyMode = false});

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  // --- 📸 이미지 선택 및 자바 백엔드 서버 업로드 로직 ---
  Future<void> _pickAndUploadImage(ImageSource source) async {
    final userController = UserController.to;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      // 1. Multipart FormData 구성
      String fileName = pickedFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(pickedFile.path, filename: fileName),
        // 필요 시 회원 식별을 위해 세션 토큰이나 ID 전달
        "userId": userController.userInfo.value?.userId ?? "",
      });

      // 2. 백엔드 업로드 API 호출
      // TODO: 프로젝트의 실제 API 게이트웨이 주소(GlobalConstants.BASE_URL 등)로 대체하세요.
      String uploadUrl = "http://your-java-server.com/api/v1/file/upload";

      Response response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            // 인증 토큰이 필요하다면 헤더에 첨부
            "Authorization": "Bearer ${userController.userInfo.value?.token}",
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        print("서버 업로드 성공: ${response.data}");

        // 백엔드 응답 스펙 예시: { "success": true, "fileId": "1f750a6c..." }
        String? serverFileId = response.data['fileId'];

        if (serverFileId != null && serverFileId.isNotEmpty) {
          // 🎯 핵심 연동: 전역 상태(UserController)의 fileId를 갱신하여 전체 화면 실시간 동기화
          userController.userInfo.value = userController.userInfo.value?.copyWith(fileId: serverFileId);

          if (mounted) {
            ToastUtils.showCustomSnackBar(context, "프로필 사진이 변경되었습니다.");
          }
        }
      }
    } catch (e) {
      print("이미지 선택 및 업로드 중 오류 발생: $e");
      _showPermissionDeniedDialog();
    }
  }

  // [iOS 대응] 권한 미허용 알림창
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("권한 필요"),
        content: const Text("사진을 업로드하려면 설정에서 카메라 및 사진 권한을 허용해주세요."),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text("확인"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = UserController.to;

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
          "내 정보",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (!widget.isFamilyMode)
            TextButton(
              onPressed: () {
                if (userController.userInfo.value != null) {
                  Get.toNamed("/editMyInfoPage");
                }
              },
              child: const Text(
                "수정",
                style: TextStyle(color: Color(0xFF785186), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        final userData = userController.userInfo.value;
        if (userData == null) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF785186)));
        }

        // 🎯 서버 다운로드 URL 주소 조립
        String? fileId = userData.fileId;
        String downloadUrl = "${GlobalConstants.BASE_URL}/file/download?fileId=$fileId";

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- 🔘 프로필 이미지 뷰 렌더링 영역 ---
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: fileId.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: downloadUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 140,
                            height: 140,
                            color: const Color(0xFFF3EAF6),
                            child: const Center(child: CircularProgressIndicator(color: Color(0xFF785186))),
                          ),
                          errorWidget: (context, url, error) =>
                              Image.asset('lib/assets/test_Image.png', width: 140, height: 140, fit: BoxFit.cover),
                        )
                      : Image.asset('lib/assets/test_Image.png', width: 140, height: 140, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 25),

              // --- 내 사진 업로드 버튼 ---
              if (!widget.isFamilyMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () => _showImageSourceDialog(),
                      icon: const Icon(Icons.add, color: Color(0xFF785186)),
                      label: const Text(
                        "내 사진 업로드",
                        style: TextStyle(color: Color(0xFF785186), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF785186), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),

              // --- 정보 리스트 영역 ---
              _buildInfoTile("이름", userData.userName),
              _buildInfoTile("아이디", userData.userId),
              _buildInfoTile("비밀번호", userData.password.isNotEmpty ? '•' * userData.password.length : '••••••••'),
              _buildInfoTile("휴대전화", userData.telephone),
              _buildInfoTile("생년월일", userData.birthday),
              _buildInfoTile("주소", userData.address ?? ""),

              if (!widget.isFamilyMode) ...[
                _buildInfoTile("출산일", userData.estimatedDueDate),
                _buildInfoTile("내 아이", userData.myChild),
              ],

              const SizedBox(height: 15),

              // --- 로그아웃 버튼 ---
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => _showLogoutDialog(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "로그아웃",
                        style: TextStyle(color: Color(0xFF667085), fontSize: 16, fontFamily: 'Pretendard'),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.logout, color: Colors.grey, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1D2939), fontFamily: 'Pretendard'),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 사진 찍기'),
              onTap: () {
                Get.back();
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('앨범에서 선택하기'),
              onTap: () {
                Get.back();
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("정말 로그아웃 하시겠습니까?\n로그아웃 시 모든 데이터가 초기화됩니다."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _executeLogoutWorkflow();
            },
            child: const Text(
              "확인",
              style: TextStyle(color: Color(0xFF785186), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeLogoutWorkflow() async {
    final userController = UserController.to;
    bool logoutResult = await userController.handleServerLogout();

    if (logoutResult) {
      print("🎉 원격 서버 및 로컬 인프라 초기화 완료");
      userController.clearUserInfo();
      Get.offAllNamed('/login');
    } else {
      if (mounted) {
        ToastUtils.showCustomSnackBar(context, "서버와 통신이 불안정하여 로그아웃에 실패했습니다. 다시 시도해 주세요.");
      }
    }
  }
}

//ios/Runner/Info.plist 파일의 <dict> 태그 내부에 아래 내용을 추가하세요.
// <key>NSCameraUsageDescription</key>
// <string>프로필 사진 촬영을 위해 카메라 접근 권한이 필요합니다.</string>
// <key>NSPhotoLibraryUsageDescription</key>
// <string>프로필 사진 설정을 위해 사진첩 접근 권한이 필요합니다.</string>
// <key>NSMicrophoneUsageDescription</key>
// <string>영상 촬영 시 마이크 접근 권한이 필요할 수 있습니다.</string>
