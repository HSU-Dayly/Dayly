import 'package:flutter/material.dart';

class WritingPracticeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '영작 연습',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 표현을 활용하여 문장을 만들어 보세요!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '여기에 영작을 입력하세요...',
                hintStyle: TextStyle(
                  fontSize: 18,
                ),
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(

              onPressed: () {
                // 지피티한테 문장 보내기
              },
              child: Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}
