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
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CalendarScreen()),
            );
          }
        },
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
