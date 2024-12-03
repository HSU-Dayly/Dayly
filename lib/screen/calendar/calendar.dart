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
      appBar: AppBar(
        title: Text('Diary Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.list), // 리스트 아이콘
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
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
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
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                DateFormat('MMM d').format(_selectedDate),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _correctedSentences.isEmpty
                ? Center(
                    child: Text(
                      '해당 날짜에 저장된 일기가 없습니다.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true, // 추가된 부분
                    physics: NeverScrollableScrollPhysics(), // 추가된 부분
                    itemCount: _correctedSentences.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.check),
                        title: Text(_correctedSentences[index]),
                      );
                    },
                  ),
            // 캘린더 아래 해당 날짜 일기 내용 칸
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DiarySwipeScreen(
                                    selectedDate: _selectedDate,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: Text(
                      _diaryContent ?? "새로운 일기를 작성해보세요.",
                      style: TextStyle(
                        fontSize: 16,
                        color: _diaryContent != null
                            ? const Color.fromRGBO(88, 71, 51, 0.992)
                            : Colors.grey,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  // ListView.builder 추가 부분
                  ListView.builder(
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
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _correctedSentences[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
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
