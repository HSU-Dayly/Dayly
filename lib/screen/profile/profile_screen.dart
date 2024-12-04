import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayly/global.dart';
import 'package:dayly/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../local_notifications.dart';
import 'components/dialogs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalDays = 0;
  int totalDiary = 45;
  int monthlyDiary = 7;
  int diaryInARow = 7;
  String alarmTime = '17:00';
  int goalDiary = 20;
  double progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // 닉네임 불러오기
    _fetchGoalDiary();
    _loadDaysSinceSignUp();
    _calculateProgress();
    _fetchDiaryStats();
  }

  // 캐시에서 닉네임 가져오기
  void _fetchUsername() async {
    final prefs = await SharedPreferences.getInstance();
    USER_NAME = prefs.getString('userName')!;
  }

  Future<void> _loadDaysSinceSignUp() async {
    int days = await calculateDaysSinceSignUp();
    setState(() {
      totalDays = days;
    });
  }

  Future<int> calculateDaysSinceSignUp() async {
    // Firebase 인증에서 현재 사용자 가져오기
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // 사용자가 로그인되지 않은 경우
      return 0;
    }

    // 가입일 가져오기
    final creationTime = user.metadata.creationTime;

    if (creationTime == null) {
      // 가입 날짜가 없는 경우
      return 0;
    }

    final now = DateTime.now();

    // 가입일부터 현재까지의 경과 일 계산
    return now.difference(creationTime).inDays;
  }

  Future<void> _fetchGoalDiary() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goalDiary = prefs.getInt('goalDiary') ?? 20; // 저장된 값 불러오기, 없으면 기본값 20
    });
  }

  Future<void> _saveGoalDiary(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goalDiary', goal); // 목표 값 저장
  }

  void _calculateProgress() {
    setState(() {
      progressValue = goalDiary > 0 ? monthlyDiary / goalDiary : 0.0;
      if (progressValue > 1.0) progressValue = 1.0; // 최대값 1.0 제한
    });
  }

  Future<void> _fetchDiaryStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(Duration(seconds: 1));

    try {
      final diaryEntries =
          await FirebaseFirestore.instance.collection('diary_entries').get();
      final monthlyEntries = await FirebaseFirestore.instance
          .collection('diary_entries')
          .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
          .where('date', isLessThanOrEqualTo: endOfMonth.toIso8601String())
          .get();

      setState(() {
        totalDiary = diaryEntries.size; // 전체 일기 개수
        monthlyDiary = monthlyEntries.size; // 이번 달 일기 개수
      });

      _calculateProgress(); // 진행률 재계산
    } catch (e) {
      print("Error fetching diary stats: $e");
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
    final adjustedAlarmTime =
        alarmTime.isBefore(now) ? alarmTime.add(Duration(days: 1)) : alarmTime;

    LocalNotifications.scheduleNotification(
      title: '알림',
      body: '일기를 작성할 시간입니다!',
      hour: adjustedAlarmTime.hour,
      minute: adjustedAlarmTime.minute,
    );
  }

  void _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEEEEEE),
          title: Text(
            '정말 로그아웃하시겠습니까?\n기존 정보가 모두 초기화됩니다.',
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 다이얼로그 닫고 false 반환
              },
              child: Text(
                '취소',
                style: TextStyle(color: Color.fromRGBO(88, 71, 51, 0.992)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 다이얼로그 닫고 true 반환
              },
              child: Text(
                '확인',
                style: TextStyle(
                    color: Color.fromRGBO(88, 71, 51, 0.992),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    // shouldLogout이 true인 경우에만 _logout 호출
    if (shouldLogout == true) {
      _logout();
    }
  }

  void _showGoalDialog() async {
    final int? goal = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return GoalDialog(goalDiary); // 현재 목표 전달
      },
    );

    if (goal != null && goal > 0) {
      setState(() {
        goalDiary = goal; // 새로운 목표로 업데이트
      });
      await _saveGoalDiary(goal);
      _calculateProgress(); // 목표 변경 후 진행률 재계산
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                onPressed: _confirmLogout, // _logout에서 _confirmLogout으로 변경
                icon: Icon(
                  Icons.logout,
                  size: 28,
                  color: Color(0xFF776767),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    USER_NAME,
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
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
                              value: progressValue,
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
                                '${(progressValue * 100).toInt()}%',
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
                              Text('$goalDiary',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
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
                              Text('$monthlyDiary', // monthDiary
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
                              Text('${goalDiary - monthlyDiary}',
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
      ),
    );
  }
}
