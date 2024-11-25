import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  final List<Map<String, String>> analyzedSentences;

  const AnalysisResultScreen({
    super.key,
    required this.analyzedSentences,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: analyzedSentences.length,
          itemBuilder: (context, index) {
            final sentence = analyzedSentences[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   sentence['original'] ?? "N/A",
                    //   style: const TextStyle(fontSize: 16),
                    // ),
                    // const SizedBox(height: 8.0),
                    Text(
                      sentence['translation'] ?? "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8.0),
                    if (sentence['analysis'] != sentence['corrected'])
                      RichText(
                        text: TextSpan(
                          children:
                              _parseAnalysisText(sentence['analysis'] ?? ''),
                        ),
                      ),
                    const SizedBox(height: 8.0),
                    RichText(
                      text: TextSpan(
                        children:
                            _parseCorrectedText(sentence['corrected'] ?? ''),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<TextSpan> _parseAnalysisText(String text) {
    final regex = RegExp(r'<red>(.*?)<\/red>|<yellow>(.*?)<\/yellow>|([^<]+)');
    final matches = regex.allMatches(text);

    return matches.map((match) {
      if (match.group(1) != null) {
        // <red> 태그
        return TextSpan(
          text: match.group(1),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(2) != null) {
        // <yellow> 태그
        return TextSpan(
          text: match.group(2),
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(3) != null) {
        // 일반 텍스트
        return TextSpan(
          text: match.group(3),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      }
      return const TextSpan();
    }).toList();
  }

  List<TextSpan> _parseCorrectedText(String text) {
    final regex = RegExp(r'<blue>(.*?)<\/blue>|<green>(.*?)<\/green>|([^<]+)');
    final matches = regex.allMatches(text);

    return matches.map((match) {
      if (match.group(1) != null) {
        // <blue> 태그
        return TextSpan(
          text: match.group(1),
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(2) != null) {
        // <blue> 태그
        return TextSpan(
          text: match.group(2),
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      } else if (match.group(3) != null) {
        // 일반 텍스트
        return TextSpan(
          text: match.group(3),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'HakgyoansimBadasseugiOTFL',
          ),
        );
      }
      return const TextSpan();
    }).toList();
  }
}
