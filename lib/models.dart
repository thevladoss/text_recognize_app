class TextRecognitionResponse {
  final String text;
  final List<TextError> errors;

  TextRecognitionResponse({required this.text, required this.errors});

  factory TextRecognitionResponse.fromJson(Map<String, dynamic> json) {
    var errorsJson = json['mistake'] as List<dynamic>;
    var errors = errorsJson.map((e) => TextError.fromJson(e)).toList();
    return TextRecognitionResponse(
      text: json['text'],
      errors: errors,
    );
  }
}

class TextError {
  final int position;
  final int length;
  final List<String> suggestions;

  TextError(
      {required this.position,
      required this.length,
      required this.suggestions});

  factory TextError.fromJson(Map<String, dynamic> json) {
    var suggestionsJson = json['s'] as List<dynamic>;
    var suggestions = suggestionsJson.cast<String>().toList();
    return TextError(
      position: json['pos'],
      length: json['len'],
      suggestions: suggestions,
    );
  }
}
