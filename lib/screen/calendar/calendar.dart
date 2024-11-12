import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'diary_list.dart';
import '../words/word_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 초기화
  await initializeDateFormatting(); // 'ko_KR'를 생략
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary App',
      // theme: ThemeData.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 로케일
      ],
      home: CalendarScreen(),
      theme: ThemeData(
        fontFamily: 'HakgyoansimBadasseugiOTFL',
        primaryColor: const Color.fromRGBO(88, 71, 51, 0.992),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(88, 71, 51, 0.992),
        ), // 기본 폰트 전체 적용
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  int _selectedIndex = 0; // BottomNavigationBar의 선택된 인덱스 초기화

  // // 임시 데이터 예시: 날짜별 일기 내용
  // Map<DateTime, String> diaryEntries = {
  //   DateTime(2024, 11, 7):
  //       "Today, I went to school. I will learn about programming language.",
  //   DateTime(2024, 11, 8): "It's pouring here all day. I think I got a cold.",
  // };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 선택된 인덱스에 따라 다른 화면으로 이동하려면 추가 코드 작성 가능// 선택된 인덱스에 따라 다른 화면으로 이동
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VocabularyScreen()),
        );
        break;
      case 2:
        break;
      case 3:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // _selectedDay에서 시간을 제거하여 비교
    DateTime selectedDateOnly =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    String formattedDate =
        DateFormat('MMM d, EEEE', 'en_US').format(_selectedDay);

    // 선택된 날짜에 해당하는 일기 내용을 diaryEntries에서 가져오기
    String? diaryContent = DiaryListScreen.diaryEntries.firstWhere(
      (entry) => entry['date'] == selectedDateOnly,
      orElse: () => {'content': null},
    )['content'];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text(
          // '${_focusedDay.month}월',
          'Dayly',
          style:
              TextStyle(fontSize: 35, color: Color.fromRGBO(88, 71, 51, 0.992)),
        ),
        centerTitle: true, // _focusedDay를 사용하여 제목 동적으로 설정
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0), // 오른쪽 여백 설정
            child: IconButton(
              icon: const Icon(Icons.format_list_bulleted, size: 28),
              onPressed: () {
                // 아이콘 버튼 클릭시 동작 추가 가능
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiaryListScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            headerStyle: const HeaderStyle(
              leftChevronIcon: Icon(
                Icons.arrow_left,
                size: 30,
              ),
              rightChevronIcon: Icon(
                Icons.arrow_right,
                size: 30,
              ),
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20, // 상단 연도와 월 글씨 크기 설정
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontWeight: FontWeight.bold, // 요일 텍스트 볼드 처리
              ),
              weekendStyle: TextStyle(
                fontWeight: FontWeight.bold, // 주말 요일 텍스트 볼드 처리
              ),
            ),
            locale: 'ko_KR', // 한국어 설정
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            focusedDay: _focusedDay, // 현재 포커스된 날
            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day), // 선택된 날을 판단
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // 선택한 날에 따라 focusedDay 업데이트
              });
            },

            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(
                color: Colors.brown,
              ),
              weekendTextStyle: const TextStyle(
                color: Colors.brown,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.brown, // 선택된 날짜 글씨색
              ),
              todayTextStyle: const TextStyle(
                color: Colors.black,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color.fromRGBO(105, 62, 29, 0.1), // 선택된 날짜 배경색
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black38,
                  width: 2,
                ),
                color: Colors.transparent,
              ),

              // 일기 작성된 날 표시
              markerDecoration: const BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle, // 일기가 작성된 날은 작은 점으로 표시
              ),
              markersMaxCount: 1, // 작은 점은 하루에 하나만 표시
            ),

            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, date, _) {
                return Container(
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black38, // 항상 유지되는 todayDecoration
                      width: 2,
                    ),
                    color: Colors.transparent,
                  ),
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, _) {
                if (isSameDay(date, DateTime.now())) {
                  // 오늘 날짜가 선택된 경우, todayDecoration 유지
                  return Container(
                    width: 40, // todayDecoration의 너비 조정
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black54,
                        width: 2,
                      ),
                      color: const Color.fromRGBO(105, 62, 29, 0.1),
                    ),
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                } else {
                  // 일반 선택된 날짜 반투명 원 표시
                  return Container(
                    width: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(105, 62, 29, 0.1), // 선택된 날짜 배경색
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        color: Colors.brown,
                      ),
                    ),
                  );
                }
              },
            ),

            // 일기 작성된 날짜 아래 갈색 점
            eventLoader: (day) {
              // 예시
              // if (day.day <= 9) {
              //   return ['Event'];
              // }
              // return [];
              // 일기 작성된 날에만 이벤트 반환
              DateTime dayWithoutTime = DateTime(day.year, day.month, day.day);
              return DiaryListScreen.diaryEntries
                      .any((entry) => entry['date'] == dayWithoutTime)
                  ? ['Event']
                  : [];
            },
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
            height: 20,
            indent: 20,
            endIndent: 20,
          ),

          // 캘린더 아래 해당 날짜 일기 내용 칸
          Padding(
            padding: const EdgeInsetsDirectional.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                      fontSize: 20, color: Color.fromRGBO(88, 71, 51, 0.592)),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$formattedDate : 일기 작성 화면으로 이동합니다.'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: '이동',
                          onPressed: () {
                            // 일기 작성 화면으로 이동
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => NewDiaryScreen()),
                            // );
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    diaryContent ?? "새로운 일기를 작성해보세요.",
                    style: TextStyle(
                      fontSize: 16,
                      color: diaryContent != null
                          ? const Color.fromRGBO(88, 71, 51, 0.992)
                          : Colors.grey,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 하단 아이콘 바
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: Container(
                width: MediaQuery.of(context).size.width / 4,
                height: 60,
                color: _selectedIndex == index
                    ? Colors.grey[300]
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _getIcon(index),
                // color: const Color.fromRGBO(88, 71, 51, 0.992),
                //   size: 25,
                // ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// 하단 바 이미지 반환 함수
Widget _getIcon(int index) {
  switch (index) {
    case 0:
      return Image.asset(
        'assets/images/home.png',
        // cacheHeight: 25,
        // cacheWidth: 25,
        width: 25,
        height: 25,
        color: const Color.fromRGBO(88, 71, 51, 0.992),
      );
    case 1:
      return Image.asset(
        'assets/images/dictionary.png',
        // cacheHeight: 25,
        // cacheWidth: 25,
        width: 25,
        height: 25,
        color: const Color.fromRGBO(88, 71, 51, 0.992),
      );
    case 2:
      return Image.asset(
        'assets/images/words.png',
        // cacheHeight: 25,
        // cacheWidth: 25,
        width: 25,
        height: 25,
        color: const Color.fromRGBO(88, 71, 51, 0.992),
      );
    case 3:
      return Image.asset(
        'assets/images/user.png',
        // cacheHeight: 25,
        // cacheWidth: 25,
        width: 25,
        height: 25,
        color: const Color.fromRGBO(88, 71, 51, 0.992),
      );
    default:
      return Image.asset(
        'assets/images/home.png',
        width: 25,
        height: 25,
        color: const Color.fromRGBO(88, 71, 51, 0.992),
      );
  }
}
