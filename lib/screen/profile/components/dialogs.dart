import 'package:flutter/material.dart';

class AlarmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TimeOfDay selectedTime = TimeOfDay.now();
    String formattedTime =
        "${selectedTime.hour}시 ${selectedTime.minute.toString().padLeft(2, '0')}분";

    return AlertDialog(
      backgroundColor: Color(0xFFEEEEEE),
      title: Text(
        '일기 작성 알림 받을 시간을 설정해주세요!',
        style: TextStyle(fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formattedTime, style: TextStyle(fontSize: 40)),
          SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Color(0xFF776767),
                          onSurface: Color(0xFF776767),
                        ),
                        dialogBackgroundColor: Color(0xFFEEEEEE),
                        timePickerTheme: TimePickerThemeData(
                          dialHandColor: Color(0xFF776767),
                          dialBackgroundColor: Color(0xFFF0F0F0),
                        ),
                      ),
                      child: child!,
                    );
                  });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFF776767)),
            ),
            child: Text('시간 선택하기',
                style: TextStyle(fontSize: 18, color: Color(0xFF776767))),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF776767))),
              child: Text('취소',
                  style: TextStyle(fontSize: 18, color: Color(0xFF776767))),
            ),
            SizedBox(width: 20.0),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF776767))),
              child: Text('확인',
                  style: TextStyle(fontSize: 18, color: Color(0xFF776767))),
            ),
          ],
        ),
      ],
    );
  }
}

class GoalDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFFEEEEEE),
      title: Text('이번달 목표를 설정해주세요!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '20',
            style: TextStyle(
              fontSize: 50,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF776767)),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF776767),
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF776767))),
              child: Text(
                '확인',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF776767),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
