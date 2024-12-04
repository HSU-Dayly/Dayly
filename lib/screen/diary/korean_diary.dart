import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DiarySwipeScreen.dart';

// 일기 작성 화면
class korean_diary extends StatefulWidget {
  const korean_diary({super.key});
  @override
  _korean_diary_state createState() => _korean_diary_state();
}

class _korean_diary_state extends State<korean_diary>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();

  // 주제 추천 목록
  final List<String> _suggestions = [
    '오늘 가장 도전적이었던 순간은 무엇이었나요?',
    '최근에 만난 사람 중 인상 깊었던 사람은 누구인가요?',
    '내가 가장 좋아하는 장소와 그곳에서 느낀 감정은?',
    '꿈속에서 만날 사람은 누구인가요?',
    '내가 가장 두려워하는 것은 무엇인가요?',
    '시간이 멈춘다면 가장 하고 싶은 일은 무엇인가요?',
    '내가 사랑하는 것과 그것이 미치는 영향은?',
    '지금 가장 기다려지는 순간은 언제인가요?',
    '이상적인 하루는 어떻게 보내고 싶나요?',
    '가장 의미 깊었던 책과 그 교훈은?',
    '어린 시절 기억에 남는 순간은 무엇인가요?',
    '행복이란 나에게 무엇인가요?',
    '다른 나라에서 하루를 보내면 무엇을 하고 싶나요?',
    '내가 한 작은 친절이 어떤 변화를 주었나요?',
    '내가 추구하는 삶의 가치는 무엇인가요?',
    '나의 가장 큰 성취는 무엇이었나요?',
    '내가 감동받고 힐링되는 음악은 무엇인가요?',
    '특별한 하루를 어떻게 보내고 싶나요?',
    '놓치고 싶지 않은 순간은 무엇인가요?',
    '최근에 나를 웃게 만든 일은 무엇인가요?',
    '미래에 이루고 싶은 일과 그 계획은 무엇인가요?'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 첫 줄로 위치 변경
    final diaryModel = Provider.of<DiaryEntryModel>(context); // 모델 가져오기
    final selectedDate = Provider.of<DiaryEntryModel>(context).selectedDate;

    // 랜덤으로 주제를 선택
    final randomSuggestion = _suggestions[
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) % _suggestions.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDateToKorean(selectedDate), // 날짜 포맷 함수 사용
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '오늘의 일기를 한글로 작성해보세요',
              style: TextStyle(
                fontSize: 20,
                backgroundColor: Color(0xFFFFEA00).withOpacity(0.34),
              ),
            ),
            const SizedBox(height: 10),
            Container(
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
                controller: _controller, // 텍스트 필드에 컨트롤러 연결
                onChanged: (value) {
                  diaryModel.updateEntry(value); // 입력 내용 업데이트
                },
                maxLines: 10,
                maxLength: 500, // 글자 수 제한
                decoration: InputDecoration(
                  hintText: "ex) $randomSuggestion", // 랜덤 주제를 hintText로 설정
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
          ],
        ),
      ),
    );
  }
}

// 날짜를 한글로 포맷하는 함수
String formatDateToKorean(DateTime date) {
  final months = [
    "1월",
    "2월",
    "3월",
    "4월",
    "5월",
    "6월",
    "7월",
    "8월",
    "9월",
    "10월",
    "11월",
    "12월"
  ];

  final weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];

  final day = date.day;
  final month = months[date.month - 1];
  final weekday = weekdays[date.weekday - 1];

  // "요일, 일 월 연도" 형태로 반환
  return "$month $day일, $weekday";
}
