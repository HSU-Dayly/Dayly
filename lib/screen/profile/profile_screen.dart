import 'dart:ui';

import 'package:dayly/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../local_notifications.dart';
import 'components/dialogs.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalDays = 30;
  int totalDiary = 45;
  int diaryInARow = 7;
  String alarmTime = '17:00';

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // 닉네임 불러오기
  }

  // Firebase에서 닉네임 가져오기
  void _fetchUsername() async {
    try {
      DatabaseReference ref =
      FirebaseDatabase.instance.ref('users/USER_NAME'); // Firebase 경로
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          USER_NAME = snapshot.child('username').value.toString();
        });
      } else {
        setState(() {
          USER_NAME = '사용자'; // 닉네임 없을 경우 기본값
        });
      }
    } catch (e) {
      print('닉네임 불러오기 실패: $e');
      setState(() {
        USER_NAME = '사용자'; // 오류 시 기본값
      });
    }
  }

  void _showAlarmDialog() async {
    final String? selectedTime = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlarmDialog(alarmTime); // 현재 alarmTime 전달
      },
    );

    if (selectedTime != null) {
      setState(() {
        alarmTime = selectedTime; // 반환된 값을 alarmTime에 반영
      });

      List<String> timeParts = alarmTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      _scheduleAlarm(hour, minute);
    }
  }

  void _scheduleAlarm(int hour, int minute) {
    final now = DateTime.now();
    final alarmTime = DateTime(now.year, now.month, now.day, hour, minute);

    // 현재 시간보다 이전 시간인 경우 다음 날로 예약
    final adjustedAlarmTime = alarmTime.isBefore(now)
        ? alarmTime.add(Duration(days: 1))
        : alarmTime;

    LocalNotifications.scheduleNotification(
      title: '알림',
      body: '일기를 작성할 시간입니다!',
      hour: adjustedAlarmTime.hour,
      minute: adjustedAlarmTime.minute,
    );
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GoalDialog();
      },
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
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              color: Color(0XFF776767),
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
            Row(
              children: [
                Text(
                  '$USER_NAME',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '님',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Text('✨ $totalDays일째 함께 하고 있어요',
                style: TextStyle(
                  fontSize: 20,
                )),
            Text('📝 지금까지 $totalDiary개의 일기를 썼어요',
                style: TextStyle(
                  fontSize: 20,
                )),
            Text('🔥 연속 작성 기록 $diaryInARow일',
                style: TextStyle(
                  fontSize: 20,
                )),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dayly 알림',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
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
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '매일 $alarmTime',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이번 달 목표',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
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
            SizedBox(height: 8),
            Center(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
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
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '목표 달성',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '20%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEFD454)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('목표 일기',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text('20',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          width: 1.0,
                          height: 60.0,
                          color: Colors.grey, // 선 색상 설정
                        ),
                        Column(
                          children: [
                            Text('작성한 일기',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text('7',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEFD454))),
                          ],
                        ),
                        Container(
                          width: 1.0,
                          height: 60.0,
                          color: Colors.grey, // 선 색상 설정
                        ),
                        Column(
                          children: [
                            Text('작성할 일기',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text('13',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
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
