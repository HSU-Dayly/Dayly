import 'package:flutter/material.dart';
import '../calendar/calendar.dart';

class VocabularyScreen extends StatelessWidget {
  // 임시 더미 데이터
  final List<Map<String, dynamic>> vocabularyList = [
    {
      "word": "work",
      "meanings": ["공부하다", "일하다", "직장에 다니다"]
    },
    {
      "word": "make progress",
      "meanings": ["어느 정도 진전이 있다"]
    },
    {
      "word": "take a short walk",
      "meanings": ["짧은 산책을 하다"]
    },
    {
      "word": "go with the flow",
      "meanings": ["흐름에 맡기다"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Dayly',
          style: TextStyle(
            fontSize: 35,
            color: Color.fromRGBO(88, 71, 51, 0.992),
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        ),
        centerTitle: true,
        // back arrow 추가
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromRGBO(88, 71, 51, 0.992)),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => CalendarScreen()),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '나의 단어장',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(88, 71, 51, 0.8),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: vocabularyList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 25, // 원 기호 크기 조절
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 5), // 단어와 원 사이 여백
                            Text(
                              vocabularyList[index]["word"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ...List.generate(
                            vocabularyList[index]["meanings"].length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              "${i + 1}. ${vocabularyList[index]["meanings"][i]}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
