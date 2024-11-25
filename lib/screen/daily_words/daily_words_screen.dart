import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../global.dart';
import 'components/writing_practice.dart';

class DailyWordsScreen extends StatefulWidget {
  @override
  _DailyWordsScreenState createState() => _DailyWordsScreenState();
}

class _DailyWordsScreenState extends State<DailyWordsScreen> {
  List<Map<String, dynamic>> expressions = [];

  @override
  void initState() {
    super.initState();
    _fetchAndLoadExpressions();
  }

  Future<List<Map<String, dynamic>>> fetchExpressionsFromGPT() async {
    final apiUrl = 'https://api.openai.com/v1/chat/completions';
    final messages = [
      {
        'role': 'system',
        'content': '''
당신은 영어 표현을 추천하고, 각 표현의 의미와 예문을 제공하는 도우미입니다. 오늘의 영어 단어 또는 표현 10개를 추천해 주세요. 일상에서 자주 쓰이는 단어와 표현 위주로 작성해 주세요.
각 표현에 대해 "expression", "meaning", "example"을 포함한 JSON 객체로 응답해 주세요.
예시:
[
  {
    "expression": "Go with the flow",
    "meaning": "현재 상황을 받아들이고 자연스럽게 흘러가도록 하는 것",
    "example": "Sometimes it's best to just go with the flow and not stress about the little things."
  },
  {
    "expression": "Break the ice",
    "meaning": "처음 만나는 사람들과의 어색함을 깨뜨리는 것",
    "example": "She told a funny story to break the ice at the beginning of the meeting."
  },
  ...
]
'''
      }
    ];

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openapiKey', // OpenAI API 키
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': messages,
        'max_tokens': 1000, // 충분한 토큰 수 설정
        'temperature': 0.0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'];
      print('GPT 응답: $content');

      // JSON 파싱
      try {
        final List<dynamic> jsonList = jsonDecode(content);
        List<Map<String, dynamic>> expressions = jsonList.map((item) {
          return {
            'expression': item['expression'] ?? '',
            'meaning': item['meaning'] ?? '',
            'example': item['example'] ?? '',
          };
        }).toList();
        return expressions;
      } catch (e) {
        print('JSON 파싱 오류: $e');
        throw Exception('GPT 응답을 파싱하는 데 실패했습니다.');
      }
    } else {
      throw Exception('GPT에서 영어 표현을 가져오는 데 실패했습니다.');
    }
  }

  Future<void> saveTodaysExpressions(List<Map<String, dynamic>> expressions) async {
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now();

    final formattedDate = '${today.year}-${today.month}-${today.day}';

    final doc = firestore.collection('daily_words').doc(formattedDate);

    final docSnapshot = await doc.get();

    if (!docSnapshot.exists) {
      // Firestore에 JSON 객체 형태로 저장
      await doc.set({
        'expressions': expressions, // List<Map<String, String>> 타입
        'date': Timestamp.now(),
      });
    }
  }

  // Firestore에서 데이터를 불러오는 함수
  Future<List<Map<String, String>>> getTodaysExpressions() async {
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month}-${today.day}';

    final doc = await firestore.collection('daily_words').doc(formattedDate).get();

    if (doc.exists) {
      try {
        final List<dynamic> dynamicList = doc.get('expressions');
        return dynamicList.map((e) => {
          'expression': e['expression'] as String,
          'meaning': e['meaning'] as String,
          'example': e['example'] as String,
        }).toList();
      } catch (e) {
        print('데이터 변환 오류: $e');
        return [];
      }
    } else {
      return []; // 데이터가 없는 경우 빈 리스트 반환
    }
  }

  // Firestore에서 데이터를 불러오고 상태를 업데이트하는 함수
  Future<void> _fetchAndLoadExpressions() async {
    try {
      // 오늘의 데이터 불러오기
      final todaysExpressions = await getTodaysExpressions();

      if (todaysExpressions.isEmpty) {
        // 데이터가 없으면 GPT로 새로운 표현 생성 후 저장
        final newExpressions = await fetchExpressionsFromGPT();
        await saveTodaysExpressions(newExpressions);
        setState(() {
          expressions = newExpressions;
        });
      } else {
        // Firestore에 데이터가 있으면 불러오기
        setState(() {
          expressions = todaysExpressions;
        });
      }
    } catch (e) {
      print('데이터를 가져오는 중 오류 발생: $e');
    }
  }

  String _randomEng() {
    int index = Random().nextInt(10) + 1;
    return expressions.elementAt(index).values.elementAt(0); // 랜덤 표현 리턴
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
                Spacer(), // SizedBox 대신 Spacer로 여백 조절
                OutlinedButton(
                  onPressed: () {
                    String eng = _randomEng();
                    // Navigate to WritingPracticeScreen (if exists)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WritingPracticeScreen(eng)),
                    );
                  },
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide(color: Color(0xFF776767))),
                  ),
                  child: Text(
                    '영작 연습',
                    style: TextStyle(
                        color: Color(0xFF776767),
                        fontSize: 15
                    ),
                  ),
                ),
              ],
            ),
            expressions.isEmpty
                ? Expanded(child: Center(child: CircularProgressIndicator())) // 로딩 중
                : Expanded(
              child: ListView.builder(
                itemCount: expressions.length,
                itemBuilder: (context, index) {
                  final expression = expressions[index]['expression'] ?? '';
                  final meaning = expressions[index]['meaning'] ?? '';
                  final example = expressions[index]['example'] ?? '';

                  return Column(
                    children: [
                      Divider(
                        thickness: 0.2,
                        color: Color(0xFF776767),
                      ),
                      Card(
                        color: Color(0xFFEEEEEE),
                        shadowColor: Colors.transparent,
                        elevation: 2.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            expression,
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.0),
                              Text(
                                '$meaning',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                '$example',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
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
