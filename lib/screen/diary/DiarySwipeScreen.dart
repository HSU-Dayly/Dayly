import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analysis_diary_result.dart';
import 'korean_diary.dart';
import 'english_diary.dart';
import 'analysis_diary.dart';

// DiaryEntryModel: 일기 모델
class DiaryEntryModel extends ChangeNotifier {
  String _entry = '';
  String _secondEntry = '';
  List<Map<String, String>> _analyzedSentences = [];
  List<VocabularyItem> _analyzedVocabulary = [];
  bool _isAnalysisComplete = false;
  DateTime _selectedDate;

  // 생성자에서 selectedDate를 받지 않고, setSelectedDate 메서드를 통해 초기화
  DiaryEntryModel() : _selectedDate = DateTime.now();

  String get entry => _entry;
  String get secondEntry => _secondEntry; // 두 번째 텍스트박스의 내용 가져오기
  DateTime get selectedDate => _selectedDate; // selectedDate getter 추가
  // 분석된 문장과 단어를 getter로 가져오기
  List<Map<String, String>> get analyzedSentences => _analyzedSentences;
  // List<VocabularyItem> get analyzedVocabulary => _analyzedVocabulary;
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
    _analyzedSentences = []; // 분석된 문장 리스트 초기화
    _analyzedVocabulary = []; // 분석된 단어 리스트 초기화
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

class VocabularyItem {
  final String word;
  final List<String> meanings; // 단수형이 아닌 복수형으로 처리

  VocabularyItem({
    required this.word,
    required this.meanings,
  });
}

class AnalysisData {
  final List<Map<String, String>> sentences;
  final List<VocabularyItem> vocabulary;

  AnalysisData({
    required this.sentences,
    required this.vocabulary,
  });
}

// DiarySwipeScreen: 메인 화면
class DiarySwipeScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String korean; // 초기 내용 파라미터 추가
  final String english; // 초기 내용 파라미터 추가

  // 생성자에서 selectedDate와 initialContent 둘 다 받음
  const DiarySwipeScreen({
    super.key,
    required this.selectedDate,
    required this.korean, // 초기 내용 추가
    required this.english, // 초기 내용 추가
  });

  @override
  _DiarySwipeScreenState createState() => _DiarySwipeScreenState();
}

class _DiarySwipeScreenState extends State<DiarySwipeScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _textController =
      TextEditingController(); // 내용 표시용
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
                      style: TextStyle(fontSize: 17),
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
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // 취소
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // 확인
                  },
                  child: const Text('확인'),
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
    final diaryModel = Provider.of<DiaryEntryModel>(context);

    final isAnalysisComplete = diaryModel.isAnalysisComplete;

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
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        korean_diary(initialContent: widget.korean), // 값 전달
                        english_diary(
                          KoreanInitialContent: widget.korean,
                          EnglishInitialContent: widget.english,
                        ),
                        if (diaryModel.secondEntry.isNotEmpty)
                          analysis_diary(pageController: _pageController),
                        if (isAnalysisComplete &&
                            diaryModel.secondEntry.isNotEmpty)
                          AnalysisResultScreen(
                            analysisData: diaryModel.analyzedAnalysisData,
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
