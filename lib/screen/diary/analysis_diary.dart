import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../global.dart';
import 'DiarySwipeScreen.dart';

// analysis_diary: 분석 화면
class analysis_diary extends StatelessWidget {
  final PageController pageController; // PageController 받기

  const analysis_diary({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final diaryModel =
        Provider.of<DiaryEntryModel>(context); // DiaryEntryModel 가져오기
    final selectedDate = diaryModel.selectedDate; // selectedDate 가져오기

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDateToEnglish(selectedDate), // 날짜 포맷 함수 사용
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'AI 분석을 통해 첨삭을 받아 보세요 ',
            style: TextStyle(
              fontSize: 20,
              backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
            ),
          ),
          // SizedBox(height: 5.0), // 간격 추가
          Padding(
            padding: const EdgeInsets.all(12.0), // 패딩 추가
            child: Text(
              diaryModel.secondEntry.isNotEmpty
                  ? diaryModel.secondEntry // 저장된 내용을 출력
                  : 'No entry yet.', // 내용이 없을 때 표시
              style: const TextStyle(
                fontSize: 17, // 글자 크기 키움
                height: 1.6, // 줄 간격 설정
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          // 버튼을 중앙 정렬
          if (diaryModel.secondEntry.isNotEmpty)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _getAnalyzeFromGpt(context, diaryModel.secondEntry);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF776767),
                  minimumSize: Size(50, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  '분석',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getAnalyzeFromGpt(BuildContext context, String text) async {
    final apiUrl = 'https://api.openai.com/v1/chat/completions';

    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석할 내용을 입력하세요!')),
      );
      return;
    }

    _showLoadingDialog(context);

    final messages = [
      {
        "role": "system",
        "content": """
당신은 사용자의 영어 문장을 교정하고, 문장 단위로 분석하며, 해석을 제공하는 도우미입니다.

- 사용자의 입력을 문장 단위로 구분하세요.
- 각 문장에 대해:
  1. 틀린 부분만 찾아 해당 단어나 구문을 <red></red> 태그로 감싸서 분석 내용을 제공하세요.
  2. 아쉬운 표현이나 개선할 부분은 <yellow></yellow> 태그로 감싸주세요.
  3. 수정된 구문을 따로 제공하며, `sentences` 배열에 각 문장에 대한 해석(`translation`), 분석된 문장(`analysis`), 수정된 문장(`corrected`)을 포함하세요.
  4. `vocabulary` 배열은 교정된 부분 중 주요 단어, 구문 또는 숙어를 정리하며, 각 항목은 다음 정보를 포함합니다:
    - **`word`**: 수정된 문장에서 교정 또는 개선된 단어나 표현.
    - **`meanings`**: 단어 또는 표현의 의미를 배열 형태로 제공. 문맥에 맞게 정리합니다.
  5. 절대로 전체 문장을 한꺼번에 태그로 감싸지 마세요 .
  6. 반드시 한 문장씩 분석해서 응답하세요.

응답 형식:
{
  "sentences": [
    {
      "translation": "한국어 해석",
      "analysis": "분석된 문장 (태그 포함)",
      "corrected": "수정된 문장"
    },
    ...
  ],
  "vocabulary": [
    {
      "word": "example word",
      "meanings": ["뜻1", "뜻2", "뜻3"]
    },
    ...
  ]
}

예시:
사용자 입력: "I am go to school. She is more smarter than me."
응답:
{
  "sentences": [
    {
      "translation": "나는 학교에 가고 있다.",
      "analysis": "I <red>am go</red> to school.",
      "corrected": "I am going to school."
    },
    {
      "translation": "그녀는 나보다 더 똑똑하다.",
      "analysis": "She is <red>more smarter</red> than me.",
      "corrected": "She is smarter than me."
    }
  ],
  "vocabulary": [
    {
      "word": "be going to",
      "meanings": ["미래의 계획이나 의도를 나타냄. ~할 예정이다."]
    },
    {
      "word": "smarter than",
      "meanings": ["~보다 더 똑똑한", "~보다 더 현명한"]
    }
  ]
}

중요: 반드시 올바른 JSON 형식으로만 응답해야 하며, 틀린 부분만 태그로 감싸주세요.
"""
      },
      {"role": "user", "content": text},
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
      print('Raw Response: ${response.body}');
      if (response.statusCode == 200) {
        // `response.bodyBytes`를 UTF-8로 디코딩
        final responseBody =
            utf8.decode(response.bodyBytes); // 바이너리 데이터를 UTF-8로 디코딩
        print('Decoded Response Body: $responseBody'); // 디코딩 후 결과 확인

        final data = jsonDecode(responseBody); // 디코딩된 본문을 JSON으로 파싱

        // `content`는 이미 JSON 형식이므로, 바로 파싱
        final String analysisContent = data['choices'][0]['message']['content'];
        print('Analysis: $analysisContent'); // 분석 내용 출력

        // 분석된 내용은 이미 JSON 형식으로 되어 있으므로 바로 파싱
        final parsedData = jsonDecode(analysisContent);

        //// 분석된 문장과 단어가 있는지 확인
        final sentences = parsedData['sentences'] ?? [];
        final vocabulary = parsedData['vocabulary'] ?? [];

        // 문장이 있을 때 화면으로 전달
        if (sentences.isNotEmpty) {
          // 분석 결과를 Provider를 통해 상태로 저장
          Provider.of<DiaryEntryModel>(context, listen: false)
              .setAnalysisResult(
            AnalysisData(
              sentences: (sentences as List<dynamic>)
                  .map((e) => Map<String, String>.from(e as Map))
                  .toList(),
              vocabulary: (vocabulary as List<dynamic>)
                  .map((e) => VocabularyItem(
                        word: e['word'] as String,
                        meanings: List<String>.from(
                            e['meanings'] as List<dynamic>), // 배열로 처리
                      ))
                  .toList(),
            ),
          );

          // PageController를 사용하여 다음 페이지로 이동
          Future.delayed(Duration.zero, () {
            pageController.animateToPage(
              3, // 결과 화면이 PageView의 네 번째 페이지일때
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });

          print("분석 결과가 상태로 저장되고 다음 페이지로 이동했습니다.");
        } else {
          throw Exception('분석된 문장이 없습니다.');
        }
      } else {
        throw Exception('텍스트 분석에 실패했습니다.');
      }
    } catch (e) {
      Navigator.pop(context); // 로딩 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 중 오류가 발생했습니다: ${e.toString()}')),
      );
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
}
