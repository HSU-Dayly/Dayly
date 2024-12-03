import 'package:dayly/screen/daily_words/daily_words_screen.dart';
import 'package:dayly/screen/calendar/calendar.dart';
import 'package:dayly/screen/calendar/diary_list.dart';
import 'package:dayly/screen/profile/profile_screen.dart';
import 'package:dayly/screen/words/word_list.dart';
import 'package:flutter/material.dart';

class MainScreens extends StatefulWidget {
  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CalendarScreen(),
          VocabularyScreen(),
          DailyWordsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/home.png', height: 35),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/dictionary.png', height: 35),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/words.png', height: 35),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/user.png',
              height: 35,
            ),
            label: '',
            backgroundColor: Colors.black,
          ),
        ],
        backgroundColor: Color(0xFFEEEEEE),
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
