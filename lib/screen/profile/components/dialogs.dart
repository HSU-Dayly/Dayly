import 'package:flutter/material.dart';

class AlarmDialog extends StatelessWidget {
  final String alarmTime;

  const AlarmDialog(this.alarmTime, {super.key});

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
        '일기 작성 알림 시간을 설정하세요!',
        style: TextStyle(fontSize: 19),
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
              onPressed: () => Navigator.of(context).pop(), // 아무 값도 반환하지 않음
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF776767))),
              child: Text('취소',
                  style: TextStyle(fontSize: 16, color: Color(0xFF776767))),
            ),
            SizedBox(
              width: 8.0,
            ),
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
                  Navigator.of(context)
                      .pop(selectedFormattedTime); // 선택한 시간을 반환
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF776767)),
              ),
              child: Text('시간 선택하기',
                  style: TextStyle(fontSize: 16, color: Color(0xFF776767))),
            ),
          ],
        ),
      ],
    );
  }
}

class GoalDialog extends StatelessWidget {
  final int currentGoal; // 현재 목표 전달받기

  const GoalDialog(this.currentGoal, {super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController goalController = TextEditingController(
      text: currentGoal.toString(), // 현재 목표를 초기값으로 설정
    );

    return AlertDialog(
      backgroundColor: Color(0xFFEEEEEE),
      title: Text(
        '이번달 목표를 설정하세요!',
        style: TextStyle(fontSize: 20),
      ),
      content: SingleChildScrollView(
        // 스크롤 가능하도록 수정
        child: TextField(
          controller: goalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '목표 일기 수 입력',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF776767), // 활성 상태의 줄 색상
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
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
                  color: Color(0xFF776767),
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
            SizedBox(width: 20.0),
            OutlinedButton(
              onPressed: () {
                int? newGoal = int.tryParse(goalController.text);
                if (newGoal != null && newGoal > 0 && newGoal <= 30) {
                  Navigator.of(context).pop(newGoal); // 입력된 목표 반환
                } else if (newGoal != null && newGoal > 30) {
                  // 30 초과 입력 시 알림
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('목표는 최대 30개까지만 설정할 수 있습니다!')),
                  );
                } else {
                  // 유효하지 않은 입력일 경우 알림
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('유효한 숫자를 입력해주세요!')),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Color(0xFF776767),
                ),
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
