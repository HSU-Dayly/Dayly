import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // URL 열기 위한 패키지
import 'DiarySwipeScreen.dart';

// english_diary: 영어로 일기 작성
// english_diary: 영어로 일기 작성
class english_diary extends StatefulWidget {
  final String KoreanInitialContent; // 전달받은 초기 내용
  final String EnglishInitialContent; // 전달받은 초기 내용

  const english_diary(
      {super.key,
      required this.KoreanInitialContent,
      required this.EnglishInitialContent});

  @override
  _english_diary_state createState() => _english_diary_state();
}

class _english_diary_state extends State<english_diary>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController diaryController = TextEditingController();

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    // build가 완료된 후에 diaryModel 상태를 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final diaryModel = Provider.of<DiaryEntryModel>(context, listen: false);
      diaryModel.updateEntry(widget.KoreanInitialContent); // 초기 값 설정
    });
    // diaryModel을 초기화하는 대신 초기 값으로 설정
    diaryController.text = widget.EnglishInitialContent;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final diaryModel = Provider.of<DiaryEntryModel>(context);
    final selectedDate = Provider.of<DiaryEntryModel>(context).selectedDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
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
              '오늘의 일기를 영어로 작성해보세요',
              style: TextStyle(
                fontSize: 20,
                backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
              ),
            ),
            // 첫 번째 일기 항목이 있으면 보여줌
            diaryModel.entry.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 10.0), // 간격 추가
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          diaryModel.entry,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),

            // 두 번째 일기 항목 작성
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: diaryController,
                  onChanged: (value) {
                    diaryModel.updateSecondEntry(value); // 일기 내용이 변경되면 모델 업데이트
                  },
                  maxLines: 10,
                  maxLength: 500, // 글자 수 제한
                  decoration: InputDecoration(
                    hintText: 'Write your diary entry here...',
                    contentPadding: const EdgeInsets.all(16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5.0), // 간격 추가

            // 단어 검색
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
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
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // 버튼 클릭 시 검색어가 비어있지 않으면 검색
                    final word = searchController.text;
                    if (word.isNotEmpty) {
                      _searchWord(word);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF776767),
                    minimumSize: Size(50, 50),
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
          ],
        ),
      ),
    );
  }

  // 단어 검색 함수
  void _searchWord(String word) async {
    final url = Uri.parse('https://dict.naver.com/search.nhn?query=$word');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
