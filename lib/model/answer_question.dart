import 'dart:convert';

class AnswerQuestion {
  String? id;
  List<String>? answer;
  String? questionType;
  bool? required;

  AnswerQuestion({this.id, this.answer, this.required, this.questionType});

  factory AnswerQuestion.fromMap(Map<String, dynamic> data) {
    return AnswerQuestion(
      id: data['id'] as String?,
      answer: data['answer'] as List<String>?,
      required: data['required'] as bool?,
      questionType: data['question_type'] ?? "",
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'answer': answer,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AnswerQuestion].
  factory AnswerQuestion.fromJson(String data) {
    return AnswerQuestion.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AnswerQuestion] to a JSON string.
  String toJson() => json.encode(toMap());
}
