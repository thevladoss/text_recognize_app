import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'recognize_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(TextRecognitionApp());
}

class TextRecognitionApp extends StatefulWidget {
  @override
  _TextRecognitionAppState createState() => _TextRecognitionAppState();
}

class _TextRecognitionAppState extends State<TextRecognitionApp> {
  bool _isDarkTheme = true;
  double _textSize = 16.0;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  void _increaseTextSize() {
    setState(() {
      _textSize += 2;
    });
  }

  void _decreaseTextSize() {
    setState(() {
      _textSize = _textSize > 2 ? _textSize - 2 : 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Распознавание текста',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: RecognizePage(
        toggleTheme: _toggleTheme,
        increaseTextSize: _increaseTextSize,
        decreaseTextSize: _decreaseTextSize,
        isDarkTheme: _isDarkTheme,
        textSize: _textSize,
      ),
    );
  }
}
