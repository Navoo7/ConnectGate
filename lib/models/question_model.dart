// question_model.dart

// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String title;
  final String question;
  final String type;
  final List<String>? options;
  final List<String>? groupIds;
  final String groupname;
  final Timestamp createdAt; // Add a timestamp field

  Question({
    required this.id,
    required this.title,
    required this.question,
    required this.type,
    this.options,
    this.groupIds,
    required this.groupname,
    required this.createdAt, // Initialize createdAt when creating a question
  });
}
