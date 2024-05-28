// import 'package:connectgateproject/models/question_model.dart';
// ignore_for_file: depend_on_referenced_packages

import 'package:connectgate/Services/question_services.dart';
import 'package:connectgate/models/question_model.dart';
import 'package:flutter/material.dart';

class QuestionProvider extends ChangeNotifier {
  final QuestionService _questionService = QuestionService();

  Future<void> addQuestion({
    required BuildContext context,
    required String title,
    required String question,
    required String type,
    List<String>? options,
    List<String>? groupIds,
    required String groupname,
  }) async {
    await _questionService.addQuestionToFirestore(
      context: context,
      title: title,
      question: question,
      type: type,
      options: options,
      groupIds: groupIds,
      groupname: groupname,
    );

    // Notify listeners after adding a question
    notifyListeners();
  }

  Stream<List<Question>> getQuestionsForUser(
      String userId, List<String> userGroupIds) {
    return _questionService.getQuestionsForUser(userId, userGroupIds);
  }
// }
}
