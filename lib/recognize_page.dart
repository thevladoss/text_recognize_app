import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:html' as html;
import 'models.dart';
import 'text_recognition_service.dart';

class RecognizePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback increaseTextSize;
  final VoidCallback decreaseTextSize;
  final bool isDarkTheme;
  final double textSize;

  RecognizePage({
    required this.toggleTheme,
    required this.increaseTextSize,
    required this.decreaseTextSize,
    required this.isDarkTheme,
    required this.textSize,
  });

  @override
  _RecognizePageState createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  String? imageUrl;
  String recognizedText = '';
  List<TextError> errors = [];
  bool _isLoading = false;
  final TextRecognitionService _service = TextRecognitionService();

  void _pickFile() async {
    if (_isLoading) return;

    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);

        reader.onLoadEnd.listen((e) async {
          if (reader.readyState == html.FileReader.DONE) {
            setState(() {
              imageUrl = reader.result as String;
            });
            await _sendFileForRecognition(file);
          }
        });
      }
    });
  }

  Future<void> _sendFileForRecognition(html.File file) async {
    setState(() {
      _isLoading = true;
    });

    final response = await _service.sendFileForRecognition(file);
    if (response != null) {
      setState(() {
        recognizedText = response.text;
        errors = response.errors;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Не удалось распознать текст. Попробуйте еще раз.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Распознавание текста'),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: widget.increaseTextSize,
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: widget.decreaseTextSize,
          ),
          IconButton(
            icon: Icon(
                widget.isDarkTheme ? Icons.brightness_7 : Icons.brightness_2),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                Expanded(
                  child: _buildLeftPanel(),
                ),
                Expanded(
                  child: _buildRightPanel(),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildLeftPanel(),
                _buildRightPanel(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: _isLoading ? null : _pickFile,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: imageUrl == null
                ? Text(
                    'Выберите фотографию',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _pickFile,
                            child: Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: _isLoading
          ? Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CupertinoActivityIndicator(radius: 50),
              ),
            )
          : SingleChildScrollView(
              child: RichText(
                text: _buildTextSpan(recognizedText, errors, widget.textSize),
              ),
            ),
    );
  }

  TextSpan _buildTextSpan(
      String text, List<TextError> errors, double textSize) {
    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (var error in errors) {
      if (currentIndex < error.position) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, error.position),
          style: TextStyle(fontSize: textSize),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(error.position, error.position + error.length),
        style: TextStyle(fontSize: textSize, color: Colors.red),
      ));
      currentIndex = error.position + error.length;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: TextStyle(fontSize: textSize),
      ));
    }

    return TextSpan(children: spans);
  }
}
