import 'dart:convert';

import 'package:tmcapp/model/question_survey.dart';

class Survey {
  int? id;
  String? title;
  String? description;
  String? draftID;
  bool? isDraft;
  List<QuestionSurvey>? questions = [];

  Survey(
      {this.id,
      this.title,
      this.description,
      this.draftID,
      this.isDraft,
      this.questions});

  factory Survey.fromMap(Map<String, dynamic> data) => Survey(
      id: data['id'] as int?,
      title: data['title'] as String?,
      description: data['description'] as String?,
      isDraft: data['draft'] ?? false as bool?,
      draftID: data['draftID'] ?? "" as String?);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'isDraft': isDraft,
        'questions': questions
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Survey].
  factory Survey.fromJson(String data) {
    return Survey.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Survey] to a JSON string.
  String toJson() => json.encode(toMap());

  addQuestion(QuestionSurvey qs) {
    if (questions == null) {
      questions = [];
    }
    questions!.add(qs);
  }
}
