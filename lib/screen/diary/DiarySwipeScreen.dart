import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // URL 열기 위한 패키지
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../global.dart';
import 'analysis_diary_result.dart';

// DiaryEntryModel: 일기 모델
class DiaryEntryModel extends ChangeNotifier {
  String _entry = '';
  String _secondEntry = '';
  List<Map<String, String>> _analyzedSentences = [];
  List<String> _analyzedVocabulary = [];
  bool _isAnalysisComplete = false;
  DateTime _selectedDate;

  // 생성자에서 selectedDate를 받지 않고, setSelectedDate 메서드를 통해 초기화
  DiaryEntryModel() : _selectedDate = DateTime.now();

  String get entry => _entry;
  String get secondEntry => _secondEntry; // 두 번째 텍스트박스의 내용 가져오기
  DateTime get selectedDate => _selectedDate; // selectedDate getter 추가
  // 분석된 문장과 단어를 getter로 가져오기
  List<Map<String, String>> get analyzedSentences => _analyzedSentences;
  List<String> get analyzedVocabulary => _analyzedVocabulary;
  bool get isAnalysisComplete => _isAnalysisComplete;

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
    _secondEntry = ''; // 두 번째 텍스트박스 내용 초기화
    notifyListeners(); // 초기화된 상태를 구독자에게 알림
  }

  // 분석된 데이터 전체를 반환하는 getter
  AnalysisData get analyzedAnalysisData {
    return AnalysisData(
      sentences: _analyzedSentences,
      vocabulary: _analyzedVocabulary,
    );
  }

  // 분석된 데이터 설정 함수
  void setAnalysisResult(AnalysisData analysisData) {
    _analyzedSentences = analysisData.sentences;
    _analyzedVocabulary = analysisData.vocabulary;
    _isAnalysisComplete = true;
    notifyListeners();
  }

  // 분석 초기화 함수
  void resetAnalysis() {
    _analyzedSentences = [];
    _analyzedVocabulary = [];
    _isAnalysisComplete = false;
    notifyListeners();
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners(); // 날짜가 변경되면 notify
  }
}

class AnalysisData {
  final List<Map<String, String>> sentences; // 문장 데이터
  final List<String> vocabulary; // 단어 데이터

  AnalysisData({
    required this.sentences,
    required this.vocabulary,
  });
}

// DiarySwipeScreen: 메인 화면
class DiarySwipeScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DiarySwipeScreen({super.key, required this.selectedDate});

  @override
  _DiarySwipeScreenState createState() => _DiarySwipeScreenState();
}

class _DiarySwipeScreenState extends State<DiarySwipeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Provider로 selectedDate 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiaryEntryModel>(context, listen: false)
          .updateSelectedDate(widget.selectedDate);
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    FocusScope.of(context).unfocus();
  }

  Future<bool> _showExitDialog() async {
    // 모달창을 띄우는 함수
    return (await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: const Text('뒤로 가기'),
              content: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '작성한 내용이 모두 ',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                    TextSpan(
                      text: '삭제',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      // '삭제'에 빨간색 적용
                    ),
                    const TextSpan(
                      text: '됩니다. \n정말로 일기 작성을 취소할까요?',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // 취소
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // 확인
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],

              contentPadding: const EdgeInsets.all(20.0), // content의 padding 조정
              actionsPadding: const EdgeInsets.all(10.0), // actions의 padding 조정
            );
          },
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final diaryModel = Provider.of<DiaryEntryModel>(context); // diaryModel을 가져옴
    final isAnalysisComplete = diaryModel.isAnalysisComplete;
    final analyzedSentences = diaryModel.analyzedSentences; // 분석된 데이터

    return GestureDetector(
        onTap: () {
          // 화면 탭 시 키보드 닫기
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
            onWillPop: () async {
              if (_currentPage == 0) {
                return true; // 첫 번째 페이지에서는 뒤로 가기 허용
              }
              _pageController.jumpToPage(0); // 첫 번째 페이지로 이동
              return false; // 뒤로 가기 동작을 막음
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFEEEEEE),
              appBar: AppBar(
                title: const Text('Dayly'), // 타이틀
                backgroundColor: const Color(0xFFEEEEEE),
                leading: IconButton(
                  // 뒤로 가기
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    bool shouldExit = await _showExitDialog();
                    if (shouldExit) {
                      Navigator.pop(context); // 뒤로 가기 확인 후 뒤로가기
                      diaryModel.resetEntry();
                    }
                  },
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0), // 간격 추가
                  //   child: Column(
                  //     crossAxisAlignment:
                  //         CrossAxisAlignment.start, // 내부 텍스트 왼쪽 정렬
                  //     children: [
                  //       Text(
                  //         _formatDateToEnglish(widget.selectedDate), // 날짜 출력
                  //         style: const TextStyle(
                  //           fontSize: 22,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // DiarySwipeScreen
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        DiaryEntryScreen(), // 날짜를 DiaryEntryScreen에 전달
                        OtherScreen(),
                        if (diaryModel.secondEntry.isNotEmpty)
                          OtherScreen2(pageController: _pageController),
                        if (isAnalysisComplete &&
                            diaryModel.secondEntry.isNotEmpty)
                          AnalysisResultScreen(
                            analysisData:
                                diaryModel.analyzedAnalysisData, // 객체 전달
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 수평축의 중앙에 정렬
                      children: List<Widget>.generate(4, (index) {
                        return AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 300), // 애니메이션 지속 시간
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4.0), // 좌우에 마진 추가
                          height: 8.0,
                          width: _currentPage == index
                              ? 24.0
                              : 8.0, // 현재 페이지면 가로로 길게
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
            )));
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
  // 텍스트 필드의 상태를 관리할 컨트롤러 추가
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 첫 줄로 위치 변경
    final diaryModel = Provider.of<DiaryEntryModel>(context); // 모델 가져오기
    final selectedDate = Provider.of<DiaryEntryModel>(context).selectedDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDateToKorean(selectedDate), // 날짜 포맷 함수 사용
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '오늘의 일기를 한글로 작성해보세요',
              style: TextStyle(
                fontSize: 20,
                backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
              ),
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
                controller: _controller, // 텍스트 필드에 컨트롤러 연결
                onChanged: (value) {
                  diaryModel.updateEntry(value); // 입력 내용 업데이트
                },
                maxLines: 10,
                maxLength: 500, // 글자 수 제한
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

// 날짜를 한글로 포맷하는 함수
String formatDateToKorean(DateTime date) {
  final months = [
    "1월",
    "2월",
    "3월",
    "4월",
    "5월",
    "6월",
    "7월",
    "8월",
    "9월",
    "10월",
    "11월",
    "12월"
  ];

  final weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];

  final day = date.day;
  final month = months[date.month - 1];
  final weekday = weekdays[date.weekday - 1];

  // "요일, 일 월 연도" 형태로 반환
  return "$month $day일, $weekday";
}

// 날짜를 영어로 포맷하는 함수
String formatDateToEnglish(DateTime date) {
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
  final weekday =
      weekdays[date.weekday - 1]; // DateTime.weekday는 1부터 시작 (Monday)

  // "Weekday, Day Month Year" 형태로 반환
  return "$weekday, $day $month";
}

// OtherScreen: 영어로 일기 작성
class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key}); // 생성자에서 selectedDate 받기

  @override
  _OtherScreenState createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController diaryController = TextEditingController();

  @override
  bool get wantKeepAlive => true; // 상태 유지 설정

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin의 호출

    final diaryModel = Provider.of<DiaryEntryModel>(context);
    final selectedDate = Provider.of<DiaryEntryModel>(context).selectedDate;

    // 일기 내용이 있다면 controller에 초기화
    diaryController.text = diaryModel.secondEntry;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDateToEnglish(selectedDate), // 날짜 포맷 함수 사용
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '오늘의 일기를 영어로 작성해보세요',
              style: TextStyle(
                fontSize: 20,
                backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
              ),
            ),
            // 첫 번째 일기 항목이 있으면 보여줌
            diaryModel.entry.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10.0), // 간격 추가
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10.0),
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
                      ),
                    ],
                  )
                : const SizedBox.shrink(),

            // 두 번째 일기 항목 작성
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
                  controller: diaryController,
                  onChanged: (value) {
                    diaryModel.updateSecondEntry(value); // 일기 내용이 변경되면 모델 업데이트
                  },
                  maxLines: 10,
                  maxLength: 500, // 글자 수 제한
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

            // 단어 검색
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: '단어를 검색해보세요',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFACACAC),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF6F6F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // 버튼 클릭 시 검색어가 비어있지 않으면 검색
                    final word = searchController.text;
                    if (word.isNotEmpty) {
                      _searchWord(word);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF776767),
                    minimumSize: Size(50, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 단어 검색 함수
  void _searchWord(String word) async {
    final url = Uri.parse('https://dict.naver.com/search.nhn?query=$word');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// OtherScreen2: 분석 화면
class OtherScreen2 extends StatelessWidget {
  final PageController pageController; // PageController 받기

  const OtherScreen2({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final diaryModel =
        Provider.of<DiaryEntryModel>(context); // DiaryEntryModel 가져오기
    final selectedDate = diaryModel.selectedDate; // selectedDate 가져오기

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDateToEnglish(selectedDate), // 날짜 포맷 함수 사용
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'AI 분석을 통해 첨삭을 받아 보세요 ',
            style: TextStyle(
              fontSize: 20,
              backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
            ),
          ),
          // SizedBox(height: 5.0), // 간격 추가
          Padding(
            padding: const EdgeInsets.all(12.0), // 패딩 추가
            child: Text(
              diaryModel.secondEntry.isNotEmpty
                  ? diaryModel.secondEntry // 저장된 내용을 출력
                  : 'No entry yet.', // 내용이 없을 때 표시
              style: const TextStyle(
                fontSize: 17, // 글자 크기 키움
                height: 1.6, // 줄 간격 설정
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          // 버튼을 중앙 정렬
          if (diaryModel.secondEntry.isNotEmpty)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _getAnalyzeFromGpt(context, diaryModel.secondEntry);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF776767),
                  minimumSize: Size(50, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  '분석',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getAnalyzeFromGpt(BuildContext context, String text) async {
    final apiUrl = 'https://api.openai.com/v1/chat/completions';

    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석할 내용을 입력하세요!')),
      );
      return;
    }

    _showLoadingDialog(context);

    final messages = [
      {
        "role": "system",
        "content": """
당신은 사용자의 영어 문장을 교정하고, 문장 단위로 분석하며, 해석을 제공하는 도우미입니다.

- 사용자의 입력을 문장 단위로 구분하세요.
- 각 문장에 대해:
  1. 틀린 부분만 찾아 해당 단어나 구문을 <red></red> 태그로 감싸서 분석 내용을 제공하세요.
  2. 아쉬운 표현이나 개선할 부분은 <yellow></yellow> 태그로 감싸주세요.
  3. 수정된 구문을 따로 제공하며, `sentences` 배열에 각 문장에 대한 해석(`translation`), 분석된 문장(`analysis`), 수정된 문장(`corrected`)을 포함하세요.
  4. `vocabulary` 배열에는 교정된 부분 중 중요한 원형, 숙어, 또는 단어를 나열해 주세요. 즉, **틀린 부분이나 아쉬운 표현을 수정한 후 그 수정된 표현만 포함**하도록 하세요.
  5. 절대로 전체 문장을 한꺼번에 태그로 감싸지 마세요.

응답 형식:
{
  "sentences": [
    {
      "translation": "한국어 해석",
      "analysis": "분석된 문장 (태그 포함)",
      "corrected": "수정된 문장"
    },
    ...
  ],
  "vocabulary": [
    "be going to", "more than", "smarter than"
  ]
}

예시:
사용자 입력: "I am go to school. She is more smarter than me."
응답:
{
  "sentences": [
    {
      "translation": "나는 학교에 가고 있다.",
      "analysis": "I <red>am go</red> to school.",
      "corrected": "I am going to school."
    },
    {
      "translation": "그녀는 나보다 더 똑똑하다.",
      "analysis": "She is <red>more smarter</red> than me.",
      "corrected": "She is smarter than me."
    }
  ],
  "vocabulary": [
    "be going to", "smarter than"
  ]
}

중요: 반드시 올바른 JSON 형식으로만 응답해야 하며, 틀린 부분만 태그로 감싸주세요.
"""
      },
      {"role": "user", "content": text},
    ];

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openapiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.0,
        }),
      );

      Navigator.pop(context); // 로딩 다이얼로그 닫기
      print('Raw Response: ${response.body}');
      if (response.statusCode == 200) {
        // `response.bodyBytes`를 UTF-8로 디코딩
        final responseBody =
            utf8.decode(response.bodyBytes); // 바이너리 데이터를 UTF-8로 디코딩
        print('Decoded Response Body: $responseBody'); // 디코딩 후 결과 확인

        final data = jsonDecode(responseBody); // 디코딩된 본문을 JSON으로 파싱

        // `content`는 이미 JSON 형식이므로, 바로 파싱
        final String analysisContent = data['choices'][0]['message']['content'];
        print('Analysis: $analysisContent'); // 분석 내용 출력

        // 분석된 내용은 이미 JSON 형식으로 되어 있으므로 바로 파싱
        final parsedData = jsonDecode(analysisContent);

        //// 분석된 문장과 단어가 있는지 확인
        final sentences = parsedData['sentences'] ?? [];
        final vocabulary = parsedData['vocabulary'] ?? [];

        // 문장과 단어가 모두 있을 때 화면으로 전달
        if (sentences.isNotEmpty || vocabulary.isNotEmpty) {
          // 분석 결과를 Provider를 통해 상태로 저장
          Provider.of<DiaryEntryModel>(context, listen: false)
              .setAnalysisResult(
            AnalysisData(
              sentences: (sentences as List<dynamic>)
                  .map((e) => Map<String, String>.from(e as Map)) // 문장 데이터 변환
                  .toList(),
              vocabulary: List<String>.from(vocabulary), // 단어 데이터 변환
            ),
          );

          // PageController를 사용하여 다음 페이지로 이동
          Future.delayed(Duration.zero, () {
            pageController.animateToPage(
              3, // 결과 화면이 PageView의 네 번째 페이지일때
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });

          print("분석 결과가 상태로 저장되고 다음 페이지로 이동했습니다.");
        } else {
          throw Exception('분석된 문장이 없습니다.');
        }
      } else {
        throw Exception('텍스트 분석에 실패했습니다.');
      }
    } catch (e) {
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 중 오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Opacity(
              opacity: 0.4,
              child: ModalBarrier(
                dismissible: false,
                color: Color(0xFF040404),
              ),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }
}
