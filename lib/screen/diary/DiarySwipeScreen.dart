import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // URL 열기 위한 패키지

// DiaryEntryModel: 일기 모델
class DiaryEntryModel extends ChangeNotifier {
  String _entry = '';
  String _secondEntry = '';

  String get entry => _entry;
  String get secondEntry => _secondEntry; // 두 번째 텍스트박스의 내용 가져오기

  void updateEntry(String newEntry) {
    _entry = newEntry;
    notifyListeners(); // 변경 사항을 구독자에게 알림
  }

  void updateSecondEntry(String newEntry) {
    _secondEntry = newEntry; // 두 번째 텍스트박스 내용 업데이트
    notifyListeners(); // 변경 사항 알림
  }

  void resetEntry() {
    _entry = ''; // 상태 초기화
    notifyListeners(); // 초기화된 상태를 구독자에게 알림
  }
}

// DiarySwipeScreen: 메인 화면
class DiarySwipeScreen extends StatefulWidget {
  final DateTime selectedDate; // selectedDate를 받는 변수

  const DiarySwipeScreen(
      {super.key, required this.selectedDate}); // 생성자에서 selectedDate 받기

  @override
  _DiarySwipeScreenState createState() => _DiarySwipeScreenState();
}

class _DiarySwipeScreenState extends State<DiarySwipeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 상태 초기화는 Future.delayed를 통해 지연시키기
    Future.delayed(Duration.zero, () {
      Provider.of<DiaryEntryModel>(context, listen: false).resetEntry();
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text('Dayly'), // 타이틀
        backgroundColor: const Color(0xFFEEEEEE),
        leading: IconButton(
          // 뒤로 가기
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 클릭시
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // 간격 추가
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 내부 텍스트 왼쪽 정렬
              children: [
                Text(
                  _formatDateToEnglish(widget.selectedDate), // 날짜 출력
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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

// 날짜를 영어로 포맷하는 함수
// 날짜를 영어로 포맷하는 함수
  String _formatDateToEnglish(DateTime date) {
    // 날짜 포맷 지정
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    final weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final weekday =
        weekdays[date.weekday - 1]; // DateTime.weekday는 1부터 시작 (Monday)

    // "Weekday, Day Month Year" 형태로 반환
    return "$weekday, $day $month $year";
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘의 일기를 작성하세요',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
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

// OtherScreen: 영어로 일기 작성
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
    final diaryModel = Provider.of<DiaryEntryModel>(context);
    final TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write your diary in English',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),

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
            // const SizedBox(height: 16.0), // 간격 추가
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
                  onChanged: diaryModel.updateSecondEntry, // 입력값 저장
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
            const SizedBox(height: 5.0), // 간격 추가
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
                    // 버튼 동작
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

// OtherScreen2: 분석 화면
class OtherScreen2 extends StatelessWidget {
  const OtherScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final diaryModel =
        Provider.of<DiaryEntryModel>(context); // DiaryEntryModel 가져오기

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 텍스트만 표시
          Text(
            diaryModel.secondEntry.isNotEmpty
                ? diaryModel.secondEntry // 저장된 내용을 출력
                : 'No entry yet.', // 내용이 없을 때 표시
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16.0),
          // 버튼을 중앙 정렬
          Center(
            child: ElevatedButton(
              onPressed: () {
                // 버튼 클릭 시 동작
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Button Pressed!')),
                );
              },
              child: const Text('Press Me'),
            ),
          ),
        ],
      ),
    );
  }
}
