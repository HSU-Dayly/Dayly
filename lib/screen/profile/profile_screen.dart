import 'dart:ui';

import 'package:dayly/global.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  void _showAlarmDialog() {
    TimeOfDay selectedTime = TimeOfDay.now();
    String formattedTime = "${selectedTime.hour}시 ${selectedTime.minute.toString().padLeft(2, '0')}분";
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    },
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                      formattedTime = "${selectedTime.hour}시 ${selectedTime.minute.toString().padLeft(2, '0')}분";
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF776767)),
                ),
                child: Text('시간 선택하기', style: TextStyle(color: Color(0xFF776767))),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF776767))),
                  child: Text('취소', style: TextStyle(color: Color(0xFF776767))),
                ),
                SizedBox(width: 20.0),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Color(0xFF776767))),
                  child: Text('확인', style: TextStyle(color: Color(0xFF776767))),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showGoalDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFEEEEEE),
            title: Text(
              '이번달 목표를 설정해주세요!'
            ),
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
                      side: BorderSide(
                          color: Color(0xFF776767)
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                          color: Color(0xFF776767)
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
                          color: Color(0xFF776767)
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text(
            'Dayly',
            style: TextStyle(
              fontSize: 40.0,
              color: Colors.brown,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFEEEEEE),
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$USER_NAME 님',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('✨ 30일째 함께 하고 있어요', style: TextStyle(fontSize: 20)),
            Text('📝 지금까지 45개의 일기를 썼어요', style: TextStyle(fontSize: 20)),
            Text('🔥 연속 작성 기록 7일', style: TextStyle(fontSize: 20)),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dayly 알림',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    _showAlarmDialog();
                  },
                  child: Text(
                    '알람 설정 >',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '매일 17 : 00',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이번달 목표',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    _showGoalDialog();
                  },
                  child: Text(
                    '목표 설정 >',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: 0.2,
                            strokeWidth: 30,
                            color: Color(0xFFFFE566).withOpacity(0.62),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                        Text(
                          '목표 달성',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Color(0XFF776767)),
                        ),
                        Text(
                          '20%',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 20, color: Colors.yellow),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('목표 일기', style: TextStyle(fontSize: 16, color: Colors.brown)),
                            Text('20', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('작성한 일기', style: TextStyle(fontSize: 16, color: Colors.yellow)),
                            Text('7', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.yellow)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('작성할 일기', style: TextStyle(fontSize: 16, color: Colors.red)),
                            Text('13', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
