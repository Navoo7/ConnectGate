import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String title;
  final String question;
  final String type;
  final List<String>? options;
  final List<String>? groupIds;
  final String groupname;
  final String? imageUrl; // Add imageUrl field
  final Timestamp createdAt;

  Question({
    required this.id,
    required this.title,
    required this.question,
    required this.type,
    this.options,
    this.groupIds,
    required this.groupname,
    this.imageUrl, // Initialize imageUrl
    required this.createdAt,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Question(
      id: doc.id,
      title: data['title'] ?? '',
      question: data['question'] ?? '',
      type: data['type'] ?? '',
      options:
          data['options'] != null ? List<String>.from(data['options']) : [],
      groupIds:
          data['groupIds'] != null ? List<String>.from(data['groupIds']) : [],
      groupname: data['groupname'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}









// // question_model.dart

// // ignore_for_file: depend_on_referenced_packages

// import 'package:cloud_firestore/cloud_firestore.dart';

// class Question {
//   final String id;
//   final String title;
//   final String question;
//   final String type;
//   final List<String>? options;
//   final List<String>? groupIds;
//   final String groupname;
//   final Timestamp createdAt; // Add a timestamp field

//   Question({
//     required this.id,
//     required this.title,
//     required this.question,
//     required this.type,
//     this.options,
//     this.groupIds,
//     required this.groupname,
//     required this.createdAt, // Initialize createdAt when creating a question
//   });
// }
