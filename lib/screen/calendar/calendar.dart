import 'package:dayly/screen/calendar/diary_modify.dart';
import 'package:dayly/screen/diary/DiarySwipeScreen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'diary_list.dart'; // 리스트 화면을 불러오기 위해 추가

class CalendarScreen extends StatefulWidget {
  
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<String> _correctedSentences = [];
  String? _diaryContent;

  @override
  void initState() {
    super.initState();
    _fetchCorrectedSentences(_selectedDate);
    _fetchDiaryContent(_selectedDate);
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
            ),
            const SizedBox(height: 10),
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
            height: 20,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 10),
            Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
    children: [
      // 날짜 표시
      Text(
        DateFormat('MMM d, EEEE').format(_selectedDate),
        style: const TextStyle(
          fontSize: 20,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 10),
      // 메시지 또는 일기 리스트
      _correctedSentences.isEmpty
          ? Text(
              '해당 날짜에 저장된 일기가 없습니다.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _correctedSentences.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // 일기 수정 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryModifyScreen(
                          date: _selectedDate,
                          content: _correctedSentences[index],
                          onDelete: (date) {
                            // 삭제 콜백 동작 정의
                            setState(() {
                              _correctedSentences.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('일기가 삭제되었습니다.'),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      _correctedSentences[index],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(88, 71, 51, 0.992),
                      ),
                    ),
                  ),
                );
              },
            ),
    ],
  ),
)

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
        final analyzedSentences = doc['analyzedSentences'] as List<dynamic>?;
        if (analyzedSentences != null) {
          setState(() {
            _correctedSentences = analyzedSentences
                .map((sentence) => sentence['corrected'] as String? ?? 'N/A')
                .toList();
          });
        } else {
          setState(() {
            _correctedSentences = [];
          });
        }
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

  Future<void> _fetchDiaryContent(DateTime selectedDate) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('diary_entries')
          .doc(formattedDate)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _diaryContent = docSnapshot['content'] as String?;
        });
      } else {
        setState(() {
          _diaryContent = null;
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
