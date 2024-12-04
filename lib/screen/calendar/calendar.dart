import 'package:dayly/screen/calendar/diary_modify.dart';
import 'package:dayly/screen/diary/DiarySwipeScreen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'diary_list.dart'; // 리스트 화면을 불러오기 위해 추가

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<String> _correctedSentences = [];
  String? _diaryContent;
  Map<DateTime, List<String>> _diaryEvents = {}; // 날짜별 일기 이벤트 저장

  @override
  void initState() {
    super.initState();
    _fetchCorrectedSentences(_selectedDate);
    _fetchDiaryContent(_selectedDate);
    _fetchDiaryEvents(); // Firestore 데이터 가져오기
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text(
          'Dayly',
          style:
              TextStyle(fontSize: 35, color: Color.fromRGBO(88, 71, 51, 0.992)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted, size: 28), // 리스트 아이콘
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // 추가된 부분
        child: Column(
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
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              calendarFormat: CalendarFormat.month,
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDate = focusedDay;
                });
                _fetchCorrectedSentences(selectedDay);
                _fetchDiaryContent(selectedDay);
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
              ),

              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return _diaryEvents[normalizedDay] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 5,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.brown,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft, // 텍스트를 왼쪽에 정렬
                    child: Text(
                      DateFormat('MMM d, EEEE').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (_diaryContent == null ||
                          _diaryContent == "일기 작성하러 가기") {
                        // DiarySwipeScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiarySwipeScreen(
                              selectedDate: _selectedDate,
                              korean: '', // 일기를 새로 작성하는 경우, 빈 문자열
                              english: '', // 일기를 새로 작성하는 경우, 빈 문자열
                            ),
                          ),
                        );
                      } else {
                        print('전 : $_diaryEvents');
                        print('전 날짜 : $_selectedDate');

                        // DiaryModifyScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryModifyScreen(
                              date: _selectedDate,
                              content: _diaryContent!,
                              onDelete: (date) {
                                // 날짜의 시간 정보를 제거하고 삭제
                                DateTime normalizedSelectedDate = DateTime(
                                    _selectedDate.year,
                                    _selectedDate.month,
                                    _selectedDate.day);

                                setState(() {
                                  _diaryContent = null;
                                  _diaryEvents.remove(
                                      normalizedSelectedDate); // 시간 정보 제거 후 날짜 삭제
                                });

                                // 캘린더 화면으로 돌아오면 다시 DiaryEvents를 업데이트
                                _fetchDiaryEvents(); // 강제로 캘린더 업데이트
                                print('후 날짜 : $_selectedDate');
                                print('후 : $_diaryEvents');
                              },
                            ),
                          ),
                        ).then((_) {
                          // 삭제 후 돌아왔을 때 캘린더 데이터를 다시 가져옴
                          _fetchDiaryEvents();
                        });
                      }
                    },
                    child: Text(
                      _diaryContent ?? "일기 작성하러 가기",
                      style: TextStyle(
                        fontSize: 16,
                        color: _diaryContent != "일기 작성하러 가기"
                            ? Color.fromRGBO(88, 71, 51, 0.992)
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
      ),
    );
  }

  Future<void> _fetchCorrectedSentences(DateTime selectedDate) async {
    final formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('diary_entries')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: formattedDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final analyzedSentences = doc['analyzedSentences'] as String?;
        setState(() {
          _correctedSentences = [analyzedSentences ?? 'N/A'];
        });
      } else {
        setState(() {
          _correctedSentences = [];
        });
      }
    } catch (e) {
      print('데이터 가져오기 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 가져오는 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _fetchDiaryEvents() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('diary_entries').get();
      final Map<DateTime, List<String>> events = {};

      for (var doc in querySnapshot.docs) {
        final date = DateTime.parse(doc.id);
        final analyzedSentences = doc['analyzedSentences'] as String?;
        if (analyzedSentences != null && analyzedSentences.isNotEmpty) {
          events[DateTime(date.year, date.month, date.day)] = [
            analyzedSentences
          ];
        }
      }

      setState(() {
        _diaryEvents = events;
      });
    } catch (e) {
      print('일기 이벤트 데이터 가져오기 실패: $e');
    }
  }

  Future<void> _fetchDiaryContent(DateTime selectedDate) async {
    final startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('diary_entries')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final analyzedSentences = doc['analyzedSentences'] as String?;
        setState(() {
          _diaryContent = analyzedSentences ?? '내용 없음';
        });
      } else {
        setState(() {
          _diaryContent = '일기 작성하러 가기';
        });
      }
    } catch (e) {
      print('일기 내용 가져오기 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기 내용을 가져오는 중 오류가 발생했습니다.')),
      );
    }
  }
}
