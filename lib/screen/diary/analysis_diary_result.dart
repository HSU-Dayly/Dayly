import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DiarySwipeScreen.dart';
import 'package:provider/provider.dart';
import '../calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
// class VocabularyItem {
//   final String word;
//   final List<String> meanings;

//   VocabularyItem({
//     required this.word,
//     required this.meanings,
//   });
// }

class AnalysisResultScreen extends StatelessWidget {
  final AnalysisData analysisData;
  const AnalysisResultScreen({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = Provider.of<DiaryEntryModel>(context).selectedDate;
    final analyzedSentences = analysisData.sentences;
    final analyzedVocas = analysisData.vocabulary;
    final wordList = analyzedVocas.map((vocab) => vocab.word).toList();

    // analyzedSentences 출력
    print('Analyzed Sentences:');
    for (var sentence in analyzedSentences) {
      print(sentence);
    }

    return Scaffold(
      // 키보드가 화면을 밀지 않도록 설정
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
              children: [
                Text(
                  formatDateToEnglish(selectedDate), // 날짜 포맷 함수 사용
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(), // 두 텍스트 사이의 여백을 추가
                GestureDetector(
                  onTap: () {
                    // '저장' 클릭 시 실행될 함수
                    print('저장 버튼이 클릭되었습니다');
                    _showSaveDialog(context, wordList);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // 텍스트에 여백을 줘서 노란색 배경에 여유를 추가
                    decoration: BoxDecoration(
                      color: Color(0xFFFFEA00).withOpacity(0.34),
                      borderRadius: BorderRadius.circular(5.0), // 버튼 모서리를 둥글게
                    ),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 20,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // 분석된 문장 리스트
            Expanded(
              child: ListView.builder(
                itemCount: analyzedSentences.length,
                itemBuilder: (context, index) {
                  final sentence = analyzedSentences[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.white, // 카드 배경 색상 설정
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 원본 문장 (주석 처리된 부분)
                          // Text(
                          //   sentence['original'] ?? "N/A",
                          //   style: const TextStyle(fontSize: 16),
                          // ),
                          // 번역된 문장
                          Text(
                            sentence['translation'] ?? "N/A",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8.0),
                          // 분석 결과가 수정된 문장과 다를 경우 분석 표시
                          if (sentence['analysis'] != sentence['corrected'])
                            RichText(
                              text: TextSpan(
                                children: _parseAnalysisText(
                                    sentence['analysis'] ?? ''),
                              ),
                            ),
                          const SizedBox(height: 8.0),
                          // 수정된 문장
                          Text(
                            sentence['corrected'] ?? "N/A",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _parseAnalysisText(String text) {
    final regex = RegExp(r'<red>(.*?)<\/red>|<yellow>(.*?)<\/yellow>|([^<]+)');
    final matches = regex.allMatches(text);

    return matches.map((match) {
      if (match.group(1) != null) {
        // <red> 태그
        return TextSpan(
          text: match.group(1),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(2) != null) {
        // <yellow> 태그
        return TextSpan(
          text: match.group(2),
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(3) != null) {
        // 일반 텍스트
        return TextSpan(
          text: match.group(3),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      }
      return const TextSpan();
    }).toList();
  }

  // vocabulary를 List<String>으로 받음
  void _showSaveDialog(BuildContext context, List<String> vocabulary) async {
    // 선택된 단어를 반환받음
    FocusScope.of(context).requestFocus(FocusNode());
    final selectedWords = await _showVocabularyDialog(context, vocabulary);

    if (selectedWords.isNotEmpty) {
      final selectedDate =
          Provider.of<DiaryEntryModel>(context, listen: false).selectedDate;
      final sentences = analysisData.sentences;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('저장'),
            content: Text('저장하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // 다이얼로그 닫기

                  // Firestore에 저장
                  try {
                    await FirebaseFirestore.instance
                        .collection('diary_entries')
                        .doc(selectedDate.toString())
                        .set({
                      'date': selectedDate.toIso8601String(),
                      'analyzedSentences': sentences,
                      'vocabulary': selectedWords, // 선택된 단어 저장
                    });

                    // 성공 메시지
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('저장되었습니다!')),
                    );
                    // 저장 후 CalendarPage로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarScreen(),
                      ),
                    );
                  } catch (e) {
                    // 실패 메시지
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('저장 실패: $e')),
                    );
                  }
                },
                child: Text('확인'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: Text('취소'),
              ),
            ],
          );
        },
      );
    }
  }

  // vocabulary를 List<String>으로 받음
  Future<List<String>> _showVocabularyDialog(
      BuildContext context, List<String> vocabulary) async {
    FocusScope.of(context).requestFocus(FocusNode());
    List<String> selectedWords = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                '단어장에 추가하고 싶은 단어를 골라주세요',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: vocabulary
                      .map((word) => GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedWords.contains(word)) {
                                  selectedWords.remove(word); // 선택 해제
                                } else {
                                  selectedWords.add(word); // 선택
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selectedWords.contains(word)
                                          ? Colors.yellow
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(word,
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedWords.isNotEmpty) {
                      Navigator.of(context).pop(); // 선택한 단어들 반환
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('저장할 단어를 선택해주세요')),
                      );
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    return selectedWords; // 선택된 단어들 반환
  }
}
