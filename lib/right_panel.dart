import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'models.dart';

class RightPanel extends StatelessWidget {
  final String recognizedText;
  final List<TextError> errors;
  final double textSize;
  final bool isLoading;

  RightPanel({
    required this.recognizedText,
    required this.errors,
    required this.textSize,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CupertinoActivityIndicator(radius: 25),
              ),
            )
          : SingleChildScrollView(
              child: SelectableText.rich(
                _buildTextSpan(recognizedText, errors, textSize, context),
              ),
            ),
    );
  }

  TextSpan _buildTextSpan(String text, List<TextError> errors, double textSize,
      BuildContext context) {
    List<InlineSpan> spans = [];
    int currentIndex = 0;
    Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    for (var error in errors) {
      if (currentIndex < error.position) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, error.position),
          style: TextStyle(fontSize: textSize, color: textColor),
        ));
      }
      spans.add(
        WidgetSpan(
          child: Tooltip(
            message: error.suggestions.join(', '),
            child: Text(
              text.substring(error.position, error.position + error.length),
              style: TextStyle(fontSize: textSize, color: Colors.red),
            ),
          ),
        ),
      );
      currentIndex = error.position + error.length;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyle(fontSize: textSize, color: textColor),
      ));
    }

    return TextSpan(children: spans);
  }
}
