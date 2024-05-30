import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TextRecognitionApp());
}

class TextRecognitionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Recognition App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> messages = [];
  bool _isLoading = false;

  void _pickFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        setState(() {
          _isLoading = true;
        });
        await _sendFileForRecognition(file);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _sendFileForRecognition(html.File file) async {
    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((e) async {
        if (reader.readyState == html.FileReader.DONE) {
          final bytes = reader.result as Uint8List;
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('https://hand-written-to-text.onrender.com/transform'),
          );
          request.files.add(http.MultipartFile.fromBytes(
            'file_bytes', // используем правильное название поля
            bytes,
            filename: file.name,
          ));
          var response = await request.send();

          if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            var jsonResponse = json.decode(responseData);
            setState(() {
              messages.add(jsonResponse['text']);
            });
          } else {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to recognize text. Please try again.')),
            );
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
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
        title: Text('Text Recognition Chat'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            ModalBarrier(
              color: Colors.black54,
              dismissible: false,
            ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: Icon(Icons.attach_file),
      ),
    );
  }
}
