import 'package:dayly/screen/calendar/diary_modify.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiaryListScreen extends StatelessWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text(
            'Dayly',
            style: TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              color: Color(0XFF776767),
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFEEEEEE),
          elevation: 0,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('diary_entries') // Firestore 컬렉션 이름
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                '저장된 일기가 없습니다.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final diaryDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: diaryDocs.length,
            itemBuilder: (context, index) {
              final doc = diaryDocs[index];
              final date = doc['date'] != null
                  ? DateTime.parse(doc['date']).toLocal() // ISO 형식의 날짜를 변환
                  : DateTime.now();
              final analyzedSentences =
                  doc['analyzedSentences'] ?? '분석된 내용이 없습니다'; // 문자열로 처리
              final formattedDate = DateFormat('MMM d, EEE').format(date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(thickness: 2, color: Colors.grey[300]), // 구분선
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0), // 날짜 패딩
                    child: Text(
                      formattedDate, // 날짜 출력 (요일 포함)
                      style: TextStyle(
                        fontSize: 24, // 날짜 글씨 크기
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF776767),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 일기 수정 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryModifyScreen(
                            date: date,
                            content: analyzedSentences, // 문서의 문자열 전달
                            onDelete: (date) {
                              // 삭제 콜백 동작 정의
                              FirebaseFirestore.instance
                                  .collection('diary_entries')
                                  .doc(doc.id)
                                  .delete()
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('일기가 삭제되었습니다.')),
                                );
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        analyzedSentences, // 수정된 문장들 출력
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 16), // 다음 항목과 간격
                ],
              );
            },
          );
        },
      ),
    );
  }
}
