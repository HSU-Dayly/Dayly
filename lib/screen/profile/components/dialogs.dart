import 'package:flutter/material.dart';

class AlarmDialog extends StatelessWidget {
  final String alarmTime;

  AlarmDialog(this.alarmTime);

  @override
  Widget build(BuildContext context) {
    // 기본값 설정 및 유효성 검사
    TimeOfDay selectedTime;
    try {
      List<String> timeParts = alarmTime.split(':');
      if (timeParts.length == 2) {
        selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      } else {
        throw FormatException("Invalid time format");
      }
    } catch (e) {
      selectedTime = TimeOfDay(hour: 0, minute: 0); // 기본값
    }

    String formattedTime =
        "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}";

    return AlertDialog(
      backgroundColor: Color(0xFFEEEEEE),
      title: Text(
        '일기 작성 알림 받을 시간을 설정해주세요!',
        style: TextStyle(fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formattedTime, style: TextStyle(fontSize: 50)),
          SizedBox(height: 16),

        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  },
                );

                if (time != null) {
                  String selectedFormattedTime =
                      "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                  Navigator.of(context).pop(selectedFormattedTime); // 선택한 시간을 반환
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF776767)),
              ),
              child: Text('시간 선택하기', style: TextStyle(fontSize: 16, color: Color(0xFF776767))),
            ),
            SizedBox(width: 8.0,),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(), // 아무 값도 반환하지 않음
              style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF776767))),
              child: Text('취소', style: TextStyle(fontSize: 16, color: Color(0xFF776767))),
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
            style: TextStyle(fontSize: 50,),
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
                side: BorderSide(
                    color: Color(0xFF776767)
                ),
              ),
              child: Text(
                '취소',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF776767),
                ),
              ),
            ),
            SizedBox(width: 20.0,),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Color(0xFF776767)
                  )
              ),
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
