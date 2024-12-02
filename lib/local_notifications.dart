import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final StreamController<String?> notificationStream = StreamController<String?>.broadcast();
  static void onNotificationTap(NotificationResponse notificationResponse) {
    notificationStream.add(notificationResponse.payload!);
  }
  static Future init() async {
    const DarwinInitializationSettings darwinInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      iOS: darwinInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    // iOS 권한 요청
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future scheduleNotification({
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    print("알림 스케줄링 시작");
    tz.initializeTimeZones();

    // 한국 시간 계산
    final adjustedAlarmTime = _getKoreanTime(hour, minute);
    print("예약 시간 (한국 시간대): $adjustedAlarmTime");

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        title,
        body,
        adjustedAlarmTime,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            sound: 'default',
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print("알림 스케줄링 성공");
    } catch (e) {
      print("알림 스케줄링 실패: $e");
    }
  }

  static tz.TZDateTime _getKoreanTime(int hour, int minute) {
    // 한국 시간대 가져오기
    final korea = tz.getLocation('Asia/Seoul');
    final now = tz.TZDateTime.now(korea);

    // 예약 시간 계산
    final alarmTime = tz.TZDateTime(korea, now.year, now.month, now.day, hour, minute);

    // 현재 시간보다 이전인 경우 다음 날로 예약
    return alarmTime.isBefore(now) ? alarmTime.add(Duration(days: 1)) : alarmTime;
  }

}