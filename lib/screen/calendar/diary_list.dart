import 'package:flutter/material.dart';
import './calendar.dart';
import '../words/word_list.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DiaryListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DiaryListScreen extends StatelessWidget {
  static final List<Map<String, dynamic>> diaryEntries = [
    {
      "date": DateTime(2024, 11, 8),
      "content":
          "Today, I worked on my UI design. I did well in the morning and walked in the afternoon. After dinner, I relaxed by reading a book. It was a simple but productive day."
    },
    {
      "date": DateTime(2024, 11, 7),
      "content":
          "Today I spent the entire day studying for my upcoming exams. I feel a bit stressed, but I'm trying to stay focused. Hopefully, all the hard work will pay off soon!"
    },
    {
      "date": DateTime(2024, 11, 15),
      "content":
          "Woke up early and felt surprisingly refreshed. The afternoon was spent reading a book and enjoying some quiet time. Ended the day with a short walk, which helped clear my mind before bed."
    },
    // 추가 임시 일기 데이터
  ];

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()), // 메인 화면
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VocabularyScreen()), // 단어장 화면
        );
        break;
      case 2:
        break;
      case 3:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜 기준 diaryEntries를 내림차순 정렬 - 최근 날짜가 맨 위로 오도록
    final sortedDiaryEntries = List<Map<String, dynamic>>.from(diaryEntries)
      ..sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromRGBO(88, 71, 51, 0.992)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: sortedDiaryEntries.length,
        itemBuilder: (context, index) {
          final entry = sortedDiaryEntries[index];
          final dateText = DateFormat.MMMd().format(entry['date'] as DateTime);

          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$dateText : 일기 화면으로 이동??'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      entry['content'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'HakgyoansimBadasseugiOTFL',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // 하단 아이콘 바
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: 0,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationBarWidget({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            // icon: Icons.home_outlined,
            imagePath: 'assets/images/home.png',
            index: 0,
            context: context,
          ),
          _buildBottomNavItem(
            // icon: Icons.book_outlined,
            imagePath: 'assets/images/dictionary.png',
            index: 1,
            context: context,
          ),
          _buildBottomNavItem(
            // icon: Icons.library_books_outlined,
            imagePath: 'assets/images/words.png',
            index: 2,
            context: context,
          ),
          _buildBottomNavItem(
            // icon: Icons.person_outlined,
            imagePath: 'assets/images/user.png',
            index: 3,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    // required IconData icon,
    required String imagePath,
    required int index,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        height: 60,
        color: selectedIndex == index ? Colors.grey[300] : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10),
        // child: Icon(
        //   icon,
        //   color: Color.fromRGBO(88, 71, 51, 0.992),
        //   size: 25,
        // ),
        child: Image.asset(
          imagePath,
          color: const Color.fromRGBO(88, 71, 51, 0.992),
          width: 25,
          height: 25,
        ),
      ),
    );
  }
}
