import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './components/writing_practice.dart';

class DailyWordsScreen extends StatefulWidget {
  @override
  _DailyWordsScreenState createState() => _DailyWordsScreenState();
}

// Firestore에 문장 데이터를 저장하는 함수
void saveExpressions() async {
  // FirebaseFirestore 인스턴스
  final firestore = FirebaseFirestore.instance;

  // 문장 데이터 (예시)
  final expressions = [
    '오늘은 좋은 날이에요.',
    '모든 일이 잘 될 거예요.',
    '즐겁게 하루를 시작하세요.',
    '항상 긍정적인 마인드를 가지세요.',
    // 추가 문장들...
  ];

  // Firestore에 문장 데이터 저장
  for (var expression in expressions) {
    await firestore.collection('expressions').add({
      'expression': expression, // 문장
      'date': Timestamp.now(), // 현재 날짜 (timestamp 형태)
    });
  }
}

class _DailyWordsScreenState extends State<DailyWordsScreen> {
  List<String> expressions = [];

  @override
  void initState() {
    super.initState();
    _loadExpressions();
  }

  // Firestore에서 데이터를 불러오는 함수
  Future<void> _loadExpressions() async {
    final todaysExpressions = await getTodaysExpressions();
    setState(() {
      expressions = todaysExpressions;
    });
  }

  Future<List<String>> getTodaysExpressions() async {
    final firestore = FirebaseFirestore.instance;

    // Firestore에서 문장 데이터를 가져옵니다
    final snapshot = await firestore
        .collection('expressions')
        .orderBy('date') // 날짜 기준으로 정렬
        .limit(10) // 10개의 문장만 가져오기
        .get();

    // 문장 데이터를 리스트로 반환
    return snapshot.docs.map((doc) => doc['expression'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Dayly가 제안하는',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '오늘의 영어 표현',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 100,
                ),
                // OutlinedButton(
                //   onPressed: () {
                //     // Navigate to WritingPracticeScreen (if exists)
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => WritingPracticeScreen()),
                //     );
                //   },
                //   child: Text('영작 연습'),
                // ),
              ],
            ),
            expressions.isEmpty
                ? Center(child: CircularProgressIndicator()) // 로딩 중
                : Expanded(
                    child: ListView.builder(
                      itemCount: expressions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(expressions[index]),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
