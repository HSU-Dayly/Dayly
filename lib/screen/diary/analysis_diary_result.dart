import 'package:flutter/material.dart';
import 'DiarySwipeScreen.dart';
import 'package:provider/provider.dart';
import '../calendar/calendar.dart';
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
                    _showSaveDialog(context, analyzedVocas);
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

  void _showSaveDialog(BuildContext context, List<VocabularyItem> vocabulary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '일기 저장',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          content: Text(
            '첨삭된 일기를 저장하시겠습니까?',
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 첫 번째 모달 닫기
              },
              child: Text(
                '취소',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 첫 번째 모달 닫기
                _showVocabularyDialog(context, vocabulary); // 두 번째 모달 호출
              },
              child: Text(
                '확인',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            )
          ],
        );
      },
    );
  }

  void _showVocabularyDialog(
      BuildContext context, List<VocabularyItem> vocabulary) {
    // 선택된 단어를 저장할 리스트 (노란색으로 표시된 단어만 저장)
    List<VocabularyItem> selectedWords = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                '단어장에 저장할 단어를 골라주세요',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: vocabulary
                      .map((item) => GestureDetector(
                            onTap: () {
                              setState(() {
                                // 단어 클릭 시 토글
                                if (selectedWords.contains(item)) {
                                  selectedWords.remove(item); // 회색으로 변경
                                } else {
                                  selectedWords.add(item); // 노란색으로 변경
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  // 선택된 단어일 경우 노란색, 아니면 회색으로 표시되는 원
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selectedWords.contains(item)
                                          ? Colors.yellow // 노란색
                                          : Colors.grey, // 회색
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(item.word,
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              actions: [
                // 건너뛰기 버튼
                TextButton(
                  onPressed: () {
                    // 건너뛰기: 단어 선택 없이 일기만 저장
                    // 일기 저장 코드 작성 (예: 일기 저장 메소드 호출)
                    print("일기만 저장");

                    // 모달 닫기
                    Navigator.of(context).pop();

                    // 저장 완료 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('일기 저장 완료')),
                    );
                    // 이 시점에서 diaryModel.resetEntry() 호출
                    final diaryModel =
                        Provider.of<DiaryEntryModel>(context, listen: false);
                    diaryModel.resetEntry();

                    // 캘린더 화면으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarScreen()),
                    );
                  },
                  child: Text(
                    '건너뛰기',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
                // 저장 버튼
                TextButton(
                  onPressed: () {
                    if (selectedWords.isNotEmpty) {
                      // 저장된 단어 출력
                      print("저장된 단어들: ${selectedWords.map((e) => e.word)}");
                      print("저장된 뜻들: ${selectedWords.map((e) => e.meanings)}");

                      // 일기와 단어 둘 다 저장 코드 작성 (예: 일기 저장 메소드와 단어 저장 메소드 호출)
                      print("일기와 단어 저장");

                      // 모달 닫기
                      Navigator.of(context).pop();

                      // 저장 완료 메시지 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('일기와 단어 저장 완료')),
                      );

                      // 이 시점에서 diaryModel.resetEntry() 호출
                      final diaryModel =
                          Provider.of<DiaryEntryModel>(context, listen: false);
                      diaryModel.resetEntry();

                      // 캘린더 화면으로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalendarScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('저장할 단어를 선택해주세요')),
                      );
                    }
                  },
                  child: Text(
                    '저장',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
