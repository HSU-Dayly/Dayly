import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DiarySwipeScreen.dart';
import 'package:provider/provider.dart';
import '../calendar/calendar.dart';
import '../main_screens.dart';
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
    final diaryModel =
        Provider.of<DiaryEntryModel>(context); // DiaryEntryModel 가져오기

    final selectedDate = Provider.of<DiaryEntryModel>(context).selectedDate;
    final analyzedSentences = analysisData.sentences;
    final analyzedVocas = analysisData.vocabulary;
    final wordList = analyzedVocas.map((vocab) => vocab.word).toList();
    final wordMeaningsList =
        analyzedVocas.map((meanings) => meanings.meanings).toList();

    // analyzedSentences 출력
    print('Analyzed Sentences:');
    for (var sentence in analyzedSentences) {
      print(sentence);
    }

    print('Analyzed word:');
    for (var word in wordList) {
      print(word);
    }

    print('Analyzed meanings:');
    for (var wordMeanings in wordMeaningsList) {
      print(wordMeanings);
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
                    print('저장 버튼이 클릭되었습니다');
                    _showSaveDialog(context, wordList,
                        wordMeaningsList); // wordMeaningsList 추가
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFEA00).withOpacity(0.34),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 20,
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
  Future<List<Map<String, dynamic>>> _showVocabularyDialog(BuildContext context,
      List<String> vocabulary, List<List<String>> meanings) async {
    FocusScope.of(context).requestFocus(FocusNode());
    List<Map<String, dynamic>> selectedWordsWithMeanings = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFEEEEEE),
              title: const Text(
                '단어장에 추가할 단어를 선택하세요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(vocabulary.length, (index) {
                    final word = vocabulary[index];
                    final wordMeanings = meanings[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          final existingEntry = selectedWordsWithMeanings
                              .firstWhere((entry) => entry['word'] == word,
                                  orElse: () => {});
                          if (existingEntry.isNotEmpty) {
                            // 이미 선택된 경우 해제
                            selectedWordsWithMeanings.remove(existingEntry);
                          } else {
                            // 선택 추가
                            selectedWordsWithMeanings.add({
                              'word': word,
                              'meanings': wordMeanings,
                            });
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
                                color: selectedWordsWithMeanings
                                        .any((entry) => entry['word'] == word)
                                    ? Colors.yellow
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(word, style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: const Text('건너뛰기',
                      style: TextStyle(
                        color: Color.fromRGBO(88, 71, 51, 0.992),
                      )),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedWordsWithMeanings.isNotEmpty) {
                      Navigator.of(context).pop(); // 선택한 단어들 반환
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('저장할 단어를 선택해주세요')),
                      );
                    }
                  },
                  child: const Text(
                    '저장',
                    style: TextStyle(
                        color: Color.fromRGBO(88, 71, 51, 0.992),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    return selectedWordsWithMeanings; // 선택된 단어들 및 뜻 반환
  }

  void _showSaveDialog(BuildContext context, List<String> vocabulary,
      List<List<String>> meanings) async {
    FocusScope.of(context).requestFocus(FocusNode());

    // DiaryEntryModel 및 날짜 가져오기
    final diaryModel = Provider.of<DiaryEntryModel>(context, listen: false);
    final selectedDate = diaryModel.selectedDate;

    // Firebase Auth를 사용하여 현재 사용자 ID 가져오기
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // 단어 선택 다이얼로그를 먼저 호출하여 선택된 단어를 가져옴
    List<Map<String, dynamic>> selectedWordsWithMeanings = [];
    if (vocabulary.isNotEmpty) {
      selectedWordsWithMeanings =
          await _showVocabularyDialog(context, vocabulary, meanings);
    }

    // 'corrected' 필드만 추출해서 하나의 문자열로 합치기
    final correctedText = analysisData.sentences
        .map((sentence) => sentence['corrected'] ?? '')
        .join(' ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEEEEEE),
          title: const Text(
            '일기 저장',
            style: TextStyle(
                color: Color.fromRGBO(88, 71, 51, 0.992),
                fontWeight: FontWeight.bold),
          ),
          content: const Text('일기를 저장하시겠습니까?',
              style: TextStyle(
                fontSize: 17,
                color: Color.fromRGBO(88, 71, 51, 0.992),
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소',
                  style: TextStyle(
                    color: Color.fromRGBO(88, 71, 51, 0.992),
                  )),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Firestore에 데이터 저장
                  await FirebaseFirestore.instance
                      .collection('diary_test') // diary_entries -> diary_test
                      .doc(selectedDate.toString())
                      .set({
                    'userId': userId, // 사용자 ID 저장
                    'date': selectedDate.toIso8601String(),
                    'analyzedSentences': correctedText,
                    'koreanSentences': diaryModel.entry,
                    'vocabulary': selectedWordsWithMeanings,
                  });

                  // 상태 초기화
                  diaryModel.resetEntry();

                  // 성공 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('저장되었습니다!')),
                  );

                  // 메인 화면으로 이동
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreens()),
                    (route) => false,
                  );
                } catch (e) {
                  // 에러 처리
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('저장 실패: $e')),
                  );
                }
              },
              child: const Text('확인',
                  style: TextStyle(
                      color: Color.fromRGBO(88, 71, 51, 0.992),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
