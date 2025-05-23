// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../diary/DiarySwipeScreen.dart';
// import 'diary_list.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

// class DiaryModifyScreen extends StatelessWidget {
//   final DateTime date;
//   final String content;
//   final void Function(DateTime) onDelete;

//   DiaryModifyScreen({
//     required this.date,
//     required this.content,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String formattedDate = DateFormat('MMM d, EEEE', 'en_US').format(date);

//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         backgroundColor: Colors.grey[200],
//         elevation: 0,
//         leading: IconButton(
//           icon:
//               Icon(Icons.arrow_back, color: Color.fromRGBO(88, 71, 51, 0.992)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Dayly',
//           style: TextStyle(
//             fontSize: 28,
//             color: Color.fromRGBO(88, 71, 51, 0.992),
//             fontFamily: 'HakgyoansimBadasseugiOTFL',
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   formattedDate,
//                   style: TextStyle(
//                     fontSize: 20,
//                     color: Color.fromRGBO(88, 71, 51, 0.592),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Container(
//                       color: Colors.yellow[100],
//                       child: TextButton(
//                         onPressed: () {
//                           // 수정 화면으로 이동하면서 기존 내용 전달
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => DiarySwipeScreen(
//                                 selectedDate: date,
//                                 initialContent: content, // 기존 내용을 전달
//                               ),
//                             ),
//                           );
//                         },
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           minimumSize: Size(0, 0),
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                         child: const Text(
//                           '수정',
//                           style: TextStyle(fontSize: 15, color: Colors.black),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       color: Colors.yellow[100],
//                       child: TextButton(
//                         onPressed: () {
//                           _showDeleteDialog(context);
//                         },
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           minimumSize: Size(0, 0),
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                         child: const Text(
//                           '삭제',
//                           style: TextStyle(fontSize: 15, color: Colors.black),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               content.isNotEmpty ? content : "새로운 일기를 작성해보세요.",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: content.isNotEmpty
//                     ? const Color.fromRGBO(88, 71, 51, 0.992)
//                     : Colors.grey,
//                 fontFamily: 'HakgyoansimBadasseugiOTFL',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text(
//             '일기를 삭제하시겠습니까? 삭제한 일기 내용은 복구할 수 없습니다.',
//             style: TextStyle(fontSize: 17),
//           ),
//           actions: [
//             TextButton(
//               child: const Text('취소'),
//               onPressed: () {
//                 Navigator.pop(dialogContext); // 다이얼로그 닫기
//               },
//             ),
//             TextButton(
//               child: const Text('삭제'),
//               onPressed: () {
//                 Navigator.pop(dialogContext); // 다이얼로그 닫기
//                 _deleteDiaryFromFirestore(context, date); // Firestore에서 삭제
//                 onDelete(date); // 부모에서 전달된 삭제 함수 호출
//                 Navigator.pop(context); // 현재 화면 닫고 이전 화면으로 돌아가기
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Firestore에서 일기 삭제하는 함수
//   Future<void> _deleteDiaryFromFirestore(
//       BuildContext context, DateTime date) async {
//     try {
//       // 날짜 형식 지정 (문서 ID로 사용)
//       String formattedDate = DateFormat('yyyy-MM-dd').format(date);

//       // Firestore 컬렉션 참조
//       CollectionReference diaries =
//           FirebaseFirestore.instance.collection('diaries');

//       // 해당 문서 삭제
//       await diaries.doc(formattedDate).delete();

//       // 삭제 성공 메시지 표시
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('일기가 성공적으로 삭제되었습니다.'),
//         ),
//       );
//     } catch (e) {
//       // 삭제 실패 시 에러 처리
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('일기 삭제에 실패했습니다.'),
//         ),
//       );
//       print("Error deleting diary: $e");
//     }
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../diary/DiarySwipeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

class DiaryModifyScreen extends StatelessWidget {
  final DateTime date;
  final String content;
  final void Function(DateTime) onDelete;

  const DiaryModifyScreen({
    super.key,
    required this.date,
    required this.content,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM d, EEEE', 'en_US').format(date);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Color.fromRGBO(88, 71, 51, 0.992)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dayly',
          style: TextStyle(
            fontSize: 28,
            color: Color.fromRGBO(88, 71, 51, 0.992),
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(88, 71, 51, 0.592),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      color: Colors.yellow[100],
                      child: TextButton(
                        onPressed: () {
                          // 수정 화면으로 이동하면서 기존 내용 전달
                          _fetchDiaryDataAndNavigate(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '수정',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      color: Colors.yellow[100],
                      child: TextButton(
                        onPressed: () {
                          _showDeleteDialog(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content.isNotEmpty ? content : "새로운 일기를 작성해보세요.",
              style: TextStyle(
                fontSize: 16,
                color: content.isNotEmpty
                    ? const Color.fromRGBO(88, 71, 51, 0.992)
                    : Colors.grey,
                fontFamily: 'HakgyoansimBadasseugiOTFL',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Firestore에서 일기 데이터를 가져오고 수정 화면으로 이동하는 함수
  Future<void> _fetchDiaryDataAndNavigate(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String firestoreDate = '$formattedDate 00:00:00.000Z';

      // Firestore에서 일기 데이터 가져오기
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('diary_test') // diary_entries -> diary_test
          .doc(firestoreDate)
          .get();

      if (docSnapshot.exists && docSnapshot['userId'] == userId) {
        // Firestore에서 데이터 가져오기
        String koreanContent = docSnapshot['koreanSentences'] ?? '';
        String englishContent = docSnapshot['analyzedSentences'] ?? '';

        // DiarySwipeScreen으로 전달하며 수정 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiarySwipeScreen(
              selectedDate: date,
              korean: koreanContent,
              english: englishContent,
            ),
          ),
        );
      } else {
        print('일기 데이터를 찾을 수 없습니다.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일기 데이터를 찾을 수 없습니다.')),
        );
      }
    } catch (e) {
      print('일기 데이터를 가져오는 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기 데이터를 가져오는 중 오류가 발생했습니다.')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            '일기를 삭제하시겠습니까? 삭제한 일기 내용은 복구할 수 없습니다.',
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.pop(dialogContext); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                Navigator.pop(dialogContext); // 다이얼로그 닫기
                _deleteDiaryFromFirestore(context, date); // Firestore에서 삭제
                onDelete(date); // 부모에서 전달된 삭제 함수 호출
                Navigator.pop(context); // 현재 화면 닫고 이전 화면으로 돌아가기
              },
            ),
          ],
        );
      },
    );
  }

  // Firestore에서 일기 삭제하는 함수
  Future<void> _deleteDiaryFromFirestore(
      BuildContext context, DateTime date) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String firestoreDate = '$formattedDate 00:00:00.000Z';

      // Firestore 컬렉션 참조
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('diary_test') // diary_entries -> diary_test
          .doc(firestoreDate)
          .get();

      if (docSnapshot.exists && docSnapshot['userId'] == userId) {
        // 문서 삭제
        await FirebaseFirestore.instance
            .collection('diary_test')
            .doc(firestoreDate)
            .delete();

        // 삭제 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일기가 성공적으로 삭제되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일기를 찾을 수 없습니다.')),
        );
      }
    } catch (e) {
      print("Error deleting diary: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기 삭제에 실패했습니다.')),
      );
    }
  }
}
