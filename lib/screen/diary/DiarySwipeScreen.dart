import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // URL 열기 위한 패키지

class DiaryEntryModel extends ChangeNotifier {
  String _entry = '';

  String get entry => _entry;

  void updateEntry(String newEntry) {
    _entry = newEntry;
    notifyListeners(); // 변경 사항을 구독자에게 알림
  }
}

class DiarySwipeScreen extends StatefulWidget {
  const DiarySwipeScreen({super.key});

  @override
  _DiarySwipeScreenState createState() => _DiarySwipeScreenState();
}

class _DiarySwipeScreenState extends State<DiarySwipeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(238, 238, 238, 238),
      appBar: AppBar(
        title: const Text('Dayly'), // 타이틀
        leading: IconButton(
          // 뒤로 가기
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 클릭시
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController, // PageController 클래스를 등록하여 페이지 전환
              onPageChanged: _onPageChanged, // 페이지가 변경될 때 호출되는 콜백 함수
              children: const [
                DiaryEntryScreen(), // 첫번째 페이지
                OtherScreen(), // 두번째 페이지
                OtherScreen2(), // 세번째 페이지
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // 수평축의 중앙에 정렬
              children: List<Widget>.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4.0), // 좌우에 마진 추가
                  height: 8.0,
                  width: _currentPage == index ? 24.0 : 8.0, // 현재 페이지면 가로로 길게
                  decoration: BoxDecoration(
                    color: _currentPage == index // 현재 페이지를 표시
                        ? const Color.fromARGB(255, 55, 55, 55)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// 일기 작성 화면
class DiaryEntryScreen extends StatefulWidget {
  const DiaryEntryScreen({super.key});

  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 첫 줄로 위치 변경
    final diaryModel = Provider.of<DiaryEntryModel>(context); // 모델 가져오기

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 일기를 작성하세요',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  diaryModel.updateEntry(value); // 입력 내용 업데이트
                },
                maxLines: 10,
                maxLength: 200, // 글자 수 제한
                decoration: InputDecoration(
                  hintText: 'ex)앞으로 10년 후, 자신의 모습을 상상해보세요', // (수정) 주제 추천
                  contentPadding: const EdgeInsets.all(16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 일기 영어로 작성 화면
class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  // 단어 검색 함수
  void _searchWord(String word) async {
    final url = Uri.parse('https://dict.naver.com/search.nhn?query=$word');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final diaryModel = Provider.of<DiaryEntryModel>(context); // 모델 가져오기
    final TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write your diary in English',
              style: TextStyle(
                fontFamily: 'KyoboFont', // 사용자 정의 글꼴 이름
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0), // 간격 추가
            diaryModel.entry.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      diaryModel.entry,
                      style: const TextStyle(fontSize: 18),
                    ),
                  )
                : const SizedBox.shrink(), // 빈 공간을 차지하지 않도록 함
            const SizedBox(height: 16.0), // 간격 추가
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Write your diary entry here...',
                    contentPadding: const EdgeInsets.all(16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0), // 간격 추가
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter a word to search',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    final word = searchController.text;
                    if (word.isNotEmpty) {
                      _searchWord(word);
                    }
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OtherScreen2 extends StatelessWidget {
  const OtherScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '분석 화면입니다',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
