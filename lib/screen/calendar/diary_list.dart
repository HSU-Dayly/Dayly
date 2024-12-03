import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiaryListScreen extends StatelessWidget {
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

          // 모든 문서의 analyzedSentences 배열을 하나로 합치기
          final allSentences = diaryDocs.expand((doc) {
            return (doc['analyzedSentences'] as List<dynamic>? ?? []);
          }).toList();

          if (allSentences.isEmpty) {
            return Center(
              child: Text(
                '분석된 문장이 없습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: allSentences.length,
            itemBuilder: (context, index) {
              final sentence = allSentences[index];
              final date = sentence['date'] != null
                  ? DateTime.parse(sentence['date'])
                  : DateTime.now();
              final corrected = sentence['corrected'] ?? '내용 없음';

              // 날짜 형식을 "MMM d"로 변경 (e.g., Oct 8)
              final formattedDate = DateFormat('MMM d').format(date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(thickness: 2, color: Colors.grey[300]), // 구분선
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0), // 날짜 패딩
                    child: Text(
                      formattedDate, // 날짜 출력
                      style: TextStyle(
                        fontSize: 24, // 날짜 글씨 크기
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF776767),
                      ),
                    ),
                  ),
                  SizedBox(height: 8), // 날짜와 내용 사이 간격
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0), // 내용 패딩
                    child: Text(
                      corrected, // 수정된 내용 출력
                      style: TextStyle(
                        fontSize: 18, // 내용 글씨 크기
                        color: Colors.black54,
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
