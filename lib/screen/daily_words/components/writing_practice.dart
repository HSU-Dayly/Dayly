import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../../global.dart';
import 'analysis_result.dart';

class WritingPracticeScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _writeEngController = TextEditingController();

  Future<void> _getAnalyzeFromGpt(BuildContext context) async {
    final apiUrl = 'https://api.openai.com/v1/chat/completions';
    final text = _writeEngController.text;

    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('영작을 입력하세요!')),
      );
      return;
    }

    // 로딩 다이얼로그 표시
    _showLoadingDialog(context);

    final messages = [
      {
        'role': 'system',
        'content': '''
당신은 사용자의 영어 문장을 교정해주는 도우미입니다.

- 틀린 부분만 찾아서 해당 단어나 구문을 <red></red> 태그로 감싸주세요.
- 아쉬운 표현만 찾아서 해당 단어나 구문을 <yellow></yellow> 태그로 감싸주세요.
- 전체 문장이 틀렸더라도, 개별 단어나 구문 수준에서 태그로 감싸주세요.
- 절대로 전체 문장을 한꺼번에 태그로 감싸지 마세요.
- 아래의 JSON 형식으로만 응답해주세요. 그 외의 설명이나 텍스트는 포함하지 마세요.

응답 형식:
{
  "content": "원본 텍스트",
  "analysis": "태그를 포함한 텍스트",
  "result": "교정된 최종 텍스트"
}

예시:
사용자 입력: "I am go to school."
응답:
{
  "content": "I am go to school.",
  "analysis": "I <red>am go</red> to school.",
  "result": "I am going to school."
}

사용자 입력: "She is more smarter than me."
응답:
{
  "content": "She is more smarter than me.",
  "analysis": "She is <red>more smarter</red> than me.",
  "result": "She is smarter than me."
}

중요: 반드시 올바른 JSON 형식으로만 응답해야 하며, 틀린 부분만 태그로 감싸주세요.
'''
      },
      { 'role': 'user', 'content': text },
    ];

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openapiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.0,
        }),
      );

      Navigator.pop(context); // 로딩 다이얼로그 닫기

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        final analysis = data['choices'][0]['message']['content'];
        print(analysis);
        final Map<String, dynamic> parsedData = jsonDecode(analysis);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              originalText: parsedData['content'],
              analyzedText: parsedData['analysis'],
              correctedText: parsedData['result'],
            ),
          ),
        );
      } else {
        throw Exception('Failed to analyze text');
      }
    } catch (e) {
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      print('분석 중 오류가 발생했습니다: $e');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Opacity(
              opacity: 0.4,
              child: ModalBarrier(
                dismissible: false,
                color: Color(0xFF040404),
              ),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '영작 연습',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'go with the flow',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
                    ),
                  ),
                  TextSpan(
                    text: '을 사용해 문장을 작성해 보세요.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _writeEngController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '여기에 영작을 입력하세요...',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFACACAC),
                ),
                filled: true,
                fillColor: Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: '단어를 검색해보세요',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFACACAC),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF6F6F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final query = _searchController.text;
                    final url = 'https://en.dict.naver.com/#/search?query=${Uri.encodeComponent(query)}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF776767),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _getAnalyzeFromGpt(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  '제출',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF776767),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
