import 'package:flutter/material.dart';
import 'left_panel.dart';
import 'right_panel.dart';
import 'text_recognition_service.dart';
import 'models.dart';
import 'dart:html' as html;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Любой код инициализации, если потребуется в будущем
    });
  }

  void _pickFile() async {
    if (_isLoading) return;

    _service.pickFile((file) async {
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
        title: Text(
          'Распознавание текста',
          style: TextStyle(fontSize: 24),
        ),
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
                  child: LeftPanel(
                    imageUrl: imageUrl,
                    isLoading: _isLoading,
                    pickFile: _pickFile,
                  ),
                ),
                Expanded(
                  child: RightPanel(
                    recognizedText: recognizedText,
                    errors: errors,
                    textSize: widget.textSize,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  height: 250,
                  child: LeftPanel(
                    imageUrl: imageUrl,
                    isLoading: _isLoading,
                    pickFile: _pickFile,
                  ),
                ),
                Expanded(
                  child: RightPanel(
                    recognizedText: recognizedText,
                    errors: errors,
                    textSize: widget.textSize,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
