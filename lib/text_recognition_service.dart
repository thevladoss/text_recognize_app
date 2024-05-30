import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'models.dart';

class TextRecognitionService {
  Future<TextRecognitionResponse?> sendFileForRecognition(
      html.File file) async {
    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      final completer = Completer<TextRecognitionResponse?>();

      reader.onLoadEnd.listen((e) async {
        if (reader.readyState == html.FileReader.DONE) {
          final bytes = reader.result as Uint8List;
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('https://hand-written-to-text.onrender.com/transform'),
          );
          request.files.add(http.MultipartFile.fromBytes(
            'file_bytes',
            bytes,
            filename: file.name,
          ));
          var response = await request.send();

          if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            var jsonResponse = json.decode(responseData);
            var textResponse = TextRecognitionResponse.fromJson(jsonResponse);
            completer.complete(textResponse);
          } else {
            completer.complete(null);
          }
        }
      });

      return completer.future;
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

  void pickFile(Function(html.File) onFilePicked) {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        onFilePicked(file);
      }
    });
  }
}
