import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../calendar/calendar.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('diary_entries')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        '저장된 단어가 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  // 필드가 존재하는 문서만 필터링
                  final vocabularyList = snapshot.data!.docs.expand((doc) {
                    if (doc.data() is Map<String, dynamic> &&
                        (doc.data() as Map<String, dynamic>)
                            .containsKey('vocabulary')) {
                      return (doc['vocabulary'] as List)
                          .map((item) => item as Map<String, dynamic>)
                          .toList();
                    }
                    return []; // 필드가 없는 문서는 빈 리스트로 처리
                  }).toList();

                  return ListView.builder(
                    itemCount: vocabularyList.length,
                    itemBuilder: (context, index) {
                      final wordData = vocabularyList[index];
                      final word = wordData['word'] as String;
                      final meanings = (wordData['meanings'] as List)
                          .map((meaning) => meaning.toString())
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    word,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ...meanings.asMap().entries.map(
                                    (entry) {
                                      final meaning = entry.value;
                                      final meaningIndex =
                                          entry.key + 1; // 번호 추가
                                      return Text(
                                        '$meaningIndex. $meaning', // 번호와 뜻
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
