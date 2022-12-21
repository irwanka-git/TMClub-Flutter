import 'dart:convert';

class QuestionSurvey {
  String? init;
  String? questionID;
  String? questionDraftID;
  String? questionText;
  String? questionType;
  String? description;
  bool? isRequired;
  List<dynamic>? options;
  bool? isOtherOption;
  List<dynamic>? subQuestions;

  QuestionSurvey({
    this.questionID,
    this.questionDraftID,
    this.init,
    this.questionText,
    this.questionType,
    this.description,
    this.isRequired,
    this.options,
    this.isOtherOption,
    this.subQuestions,
  });

  factory QuestionSurvey.fromMap(Map<String, dynamic> data) {
    return QuestionSurvey(
      init: data['init'] as String?,
      questionID: (data['question_id']).toString(),
      questionDraftID: data['question_draftid'] ?? "" as String?,
      questionText: data['question_text'] as String?,
      questionType: data['question_type'] as String?,
      description: data['description'] as String?,
      isRequired: data['is_required'] as bool?,
      options: data['options'] as List<dynamic>?,
      isOtherOption: data['is_other_option'] as bool?,
      subQuestions: data['sub_questions'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toMap() => {
        'init': init,
        'questionID': questionID,
        'questionDraftID': questionDraftID,
        'question_text': questionText,
        'question_type': questionType,
        'description': description,
        'is_required': isRequired,
        'options': options,
        'is_other_option': isOtherOption,
        'sub_questions': subQuestions,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [QuestionSurvey].
  factory QuestionSurvey.fromJson(String data) {
    return QuestionSurvey.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [QuestionSurvey] to a JSON string.
  String toJson() => json.encode(toMap());
}
