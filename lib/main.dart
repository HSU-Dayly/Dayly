import 'package:dayly/firebase_options.dart';
import 'package:dayly/screen/login_screen.dart'; // 로그인 화면 추가
import 'package:dayly/screen/diary/DiarySwipeScreen.dart'; // DiaryEntryModel을 가져옵니다
import 'package:dayly/screen/main_screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Provider 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  KakaoSdk.init(nativeAppKey: "a0b3d9c0805d766e05b4fede843b62aa"); // 카카오 앱 키 추가

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId'); // 캐시에서 로그인 상태 확인

  runApp(
    ChangeNotifierProvider(
      create: (_) => DiaryEntryModel(), // DiaryEntryModel 제공
      child: MyApp(isLoggedIn: userId != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dayly',
      theme: ThemeData(
        fontFamily: 'HakgyoansimBadasseugiOTFL',
        scaffoldBackgroundColor: Color(0xFFEEEEEE),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0XFF776767)),
          bodyMedium: TextStyle(color: Color(0XFF776767)),
          headlineLarge: TextStyle(color: Color(0XFF776767)),
        ),
      ),
      locale: const Locale('ko'), // 한국어로 기본 설정
      supportedLocales: const [
        Locale('ko'), // 한국어 지원
        Locale('en'), // 영어 지원 (필요시 추가)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isLoggedIn ? MainScreens() : LoginScreen(), // 자동 로그인 구현
    );
  }
}
