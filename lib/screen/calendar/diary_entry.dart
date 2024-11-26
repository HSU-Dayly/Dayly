import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'diary_list.dart';

class DiaryEntryScreen extends StatelessWidget {
  final DateTime date;
  final String content;
  final void Function(DateTime) onDelete;

  DiaryEntryScreen({
    required this.date,
    required this.content,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM d, EEEE', 'en_US').format(date);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Color.fromRGBO(88, 71, 51, 0.992)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dayly',
          style: TextStyle(
            fontSize: 28,
            color: Color.fromRGBO(88, 71, 51, 0.992),
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 날짜는 맨 왼쪽에 위치
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(88, 71, 51, 0.592),
                  ),
                ),
                // 수정/삭제 버튼은 맨 오른쪽에 위치
                Row(
                  children: [
                    Container(
                      color: Colors.yellow[100],
                      child: TextButton(
                        onPressed: () {
                          // 수정 버튼 동작
                          // 일기 작성 화면
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '수정',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      color: Colors.yellow[100],
                      child: TextButton(
                        onPressed: () {
                          // 삭제 버튼 동작
                          _showDeleteDialog(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content.isNotEmpty ? content : "새로운 일기를 작성해보세요.",
              style: TextStyle(
                fontSize: 16,
                color: content.isNotEmpty
                    ? const Color.fromRGBO(88, 71, 51, 0.992)
                    : Colors.grey,
                fontFamily: 'HakgyoansimBadasseugiOTFL',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 4,
                height: 60,
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _getIcon(index),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 삭제 확인 다이얼로그 함수 추가
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('일기를 삭제하시겠습니까? 삭제한 일기 내용은 복구할 수 없습니다.',
              style: TextStyle(fontSize: 17)),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.pop(dialogContext); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                // 일기 삭제 로직 실행
                Navigator.pop(dialogContext); // 다이얼로그 닫기
                onDelete(date); // 삭제 처리 후 뒤로 가기
              },
            ),
          ],
        );
      },
    );
  }

// DiaryListScreen의 diaryEntries에서 해당 날짜 일기 삭제
  // void _deleteDiaryEntry(DateTime date, BuildContext context) {
  //   DiaryListScreen.diaryEntries.removeWhere(
  //     (entry) => entry['date'] == date,
  //   );
  //   Navigator.pop(context); // 이전 화면으로 이동
  // }

  Widget _getIcon(int index) {
    switch (index) {
      case 0:
        return Image.asset(
          'assets/images/home.png',
          width: 25,
          height: 25,
          color: const Color.fromRGBO(88, 71, 51, 0.992),
        );
      case 1:
        return Image.asset(
          'assets/images/dictionary.png',
          width: 25,
          height: 25,
          color: const Color.fromRGBO(88, 71, 51, 0.992),
        );
      case 2:
        return Image.asset(
          'assets/images/words.png',
          width: 25,
          height: 25,
          color: const Color.fromRGBO(88, 71, 51, 0.992),
        );
      case 3:
        return Image.asset(
          'assets/images/user.png',
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
}
