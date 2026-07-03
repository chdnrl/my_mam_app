import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_mam_app/pages/searchAndReservation/centerDetailPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // 🌐 추후 Java 백엔드 통신(API) 결과 리스트를 대입하게 될 가상 데이터 구조
  final List<Map<String, dynamic>> _dummyCenters = [
    {
      "name": "궁 산후조리원 삼성점",
      "distance": "1.3km",
      "address": "서울특별시 강남구 언주로107길 35 \n(역삼동 658-7)",
      "tags": ["한방케어", "신생아 건강자문", "산후케어"],
      "image": "lib/assets/samsung1.png",
    },
    {
      "name": "궁 산후조리원 강남본원",
      "distance": "1.8km",
      "address": "서울특별시 강남구 언주로107길 35 \n(역삼동 658-7)",
      "tags": ["한방케어", "신생아 건강자문", "에스테틱"],
      "image": "lib/assets/gangnam.png",
    },
    {
      "name": "궁 산후조리원 화곡점",
      "distance": "24km",
      "address": "서울특별시 강남구 언주로107길 35 \n(역삼동 658-7)",
      "tags": ["한방케어", "산후풍방지", "모유 수유 지원"],
      "image": "lib/assets/gangmanbonwon.png",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "산후조리원 검색하기",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 상단 고정 검색 인풋 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "산후조리원을 검색하세요.",
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                suffixIcon: const Icon(Icons.search, color: Colors.black87),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔄 Java 데이터 수량에 맞춰 스크롤 영역이 유연하게 늘어나는 빌더 패턴
          Expanded(
            child: ListView.builder(
              itemCount: _dummyCenters.length, // 데이터 배열 길이에 맞춤
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemBuilder: (context, index) {
                final center = _dummyCenters[index];
                return _buildCenterCard(center);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🏢 리스트 내 가변 카드 컴포넌트
  Widget _buildCenterCard(Map<String, dynamic> center) {
    return GestureDetector(
      onTap: () {
        // 🚀 카드 터치 시 상세 디테일 화면으로 라우팅 이동하며 선택 지점 명 전달
        Get.to(
          () => const CenterDetailPage(),
          arguments: {"centerName": center["name"]},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📋 좌측 정보 텍스트 설명 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    center["name"],
                    style: const TextStyle(
                      color: Color(0xFF4A1A5B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    center["distance"],
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    center["address"],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 태그 칩스
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (center["tags"] as List<String>).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF785186).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFF785186),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),

            // 📸 우측 라운드 스냅샷 이미지 영역
            Container(
              width: 130,
              height: 95,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(center["image"]),
                  fit: BoxFit.cover,
                  onError: (e, s) {},
                ),
              ),
              child: Image.asset(
                center["image"],
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(
                  child: Icon(Icons.image_outlined, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
