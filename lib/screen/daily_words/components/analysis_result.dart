import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String originalText;
  final String analyzedText;
  final String correctedText;

  AnalysisResultScreen({
    required this.originalText,
    required this.analyzedText,
    required this.correctedText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dayly',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF776767),
          ),
        ),
        iconTheme: IconThemeData(
            color: Color(0xFF776767)
        ),
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0), // 상단 Padding을 조금 늘림
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 10.0),
                child: Text(
                  '분석 결과',
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
              ),
              _buildCombinedTextContainer(analyzedText, correctedText),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontFamily: 'HakgyoansimBadasseugiOTFL',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedTextContainer(String analyzedText, String correctedText) {
    final analyzedSpans = _parseTextWithTags(analyzedText);
    final correctedSpan = TextSpan(
      text: correctedText,
      style: TextStyle(
        fontSize: 22.0,
        color: Colors.blue,
        fontFamily: 'HakgyoansimBadasseugiOTFL',
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFF6F6F6),
        border: Border.all(color: Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: analyzedSpans,
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
                fontFamily: 'HakgyoansimBadasseugiOTFL',
              ),
            ),
          ),
          SizedBox(height: 100), // 두 텍스트 사이의 세로 간격
          RichText(
            text: correctedSpan,
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseTextWithTags(String text) {
    final regex = RegExp(r'<red>(.*?)<\/red>|<yellow>(.*?)<\/yellow>|([^<]+)');
    final matches = regex.allMatches(text);

    return matches.map((match) {
      if (match.group(1) != null) {
        // <red> 태그
        return TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(2) != null) {
        // <yellow> 태그
        return TextSpan(
          text: match.group(2),
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(3) != null) {
        // 일반 텍스트
        return TextSpan(
          text: match.group(3),
          style: TextStyle(
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      }
      return TextSpan();
    }).toList();
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'HakgyoansimBadasseugiOTFL',
      ),
    );
  }
}
