import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'main_screens.dart';
import '../nickname.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // 구글 사용자 계정 선택
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // 사용자가 로그인 취소
        return;
      }

      // 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 인증
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('구글 로그인 성공');
      // 로그인 성공 시 메인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UsernameScreen()),
      );
    } catch (e) {
      print('구글 로그인 오류: $e');
    }
  }

  Future<void> signInWithKakao(BuildContext context) async {
    try {
      if (await isKakaoTalkInstalled()) {
        // 카카오톡 앱으로 로그인
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡 로그인 성공: ${token.accessToken}');
      } else {
        // 카카오 계정으로 로그인
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오 계정 로그인 성공: ${token.accessToken}');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UsernameScreen()),
      );

      // 추가로 Firebase Custom Token을 사용하려면 서버에서 Kakao Access Token을 Firebase Custom Token으로 변환하는 과정이 필요합니다.
    } catch (e) {
      print('카카오 로그인 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dayly',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '나의 일상을 기록하고,\n영어를 학습해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => signInWithKakao(context),
                  child: Column(
                    children: [
                      Image.asset('assets/images/kakao_icon.png',
                          width: 60, height: 60),
                      const SizedBox(height: 8),
                      const Text('카카오톡으로 \n로그인',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => signInWithGoogle(context),
                  child: Column(
                    children: [
                      Image.asset('assets/images/google_icon.png',
                          width: 60, height: 60),
                      const SizedBox(height: 8),
                      const Text('구글 계정으로 \n로그인',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
