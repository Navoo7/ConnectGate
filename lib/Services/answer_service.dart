// answer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnswerService {
  final String org;
  final String city;

  AnswerService({required this.org, required this.city});

  // Add a reply and update the reply count
  Future<void> addReply(String answerId, String reply, String adminName) async {
    try {
      final replyCollection = FirebaseFirestore.instance
          .collection(org)
          .doc(city)
          .collection('answers')
          .doc(answerId)
          .collection('replies');

      await replyCollection.add({
        'reply': reply,
        'Name': adminName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the reply count in the answer document
      await FirebaseFirestore.instance
          .collection(org)
          .doc(city)
          .collection('answers')
          .doc(answerId)
          .update({'replyCount': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error adding reply: $e');
    }
  }

  // Calculate option percentages for MultipleChoice questions
  Future<Map<String, double>> calculateOptionPercentages(
      String title, List<dynamic> options) async {
    try {
      final answersQuerySnapshot = await FirebaseFirestore.instance
          .collection(org)
          .doc(city)
          .collection('answers')
          .where('title', isEqualTo: title)
          .get();

      final optionCounts = <String, int>{};
      int totalAnswers = 0;

      // Initialize optionCounts with all available options set to 0
      for (var option in options) {
        optionCounts[option] = 0;
      }

      for (var answerDoc in answersQuerySnapshot.docs) {
        final userAnswer = answerDoc.get('answer') as String? ?? '';
        final selectedOptions =
            userAnswer.split(',').map((e) => e.trim()).toList();

        for (var option in selectedOptions) {
          if (optionCounts.containsKey(option)) {
            optionCounts[option] = (optionCounts[option] ?? 0) + 1;
            totalAnswers++;
          }
        }
      }

      final optionPercentages = <String, double>{};
      if (totalAnswers > 0) {
        optionCounts.forEach((option, count) {
          optionPercentages[option] = (count / totalAnswers) * 100;
        });
      } else {
        // If there are no answers, set all options to 0%
        for (var option in options) {
          optionPercentages[option] = 0.0;
        }
      }

      return optionPercentages;
    } catch (e) {
      debugPrint('Error calculating percentages: $e');
      return {};
    }
  }

  // Get all answers for CSV export
  Future<QuerySnapshot> getAllAnswersSnapshot(String title) async {
    return await FirebaseFirestore.instance
        .collection(org)
        .doc(city)
        .collection('answers')
        .where('title', isEqualTo: title)
        .get();
  }

  // Fetch answers with pagination
  Future<QuerySnapshot> getAnswers(String title,
      {DocumentSnapshot? lastDoc, int limit = 5}) async {
    Query query = FirebaseFirestore.instance
        .collection(org)
        .doc(city)
        .collection('answers')
        .where('title', isEqualTo: title)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    return await query.get(GetOptions(source: Source.serverAndCache));
  }

  Future<List<Map<String, dynamic>>> getRepliesData(String answerId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(org)
        .doc(city)
        .collection('answers')
        .doc(answerId)
        .collection('replies')
        .orderBy('timestamp', descending: false)
        .get();

    List<Map<String, dynamic>> replies = [];
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      replies.add({
        'adminName': data['Name'] ?? '',
        'replyText': data['reply'] ?? '',
        'timestamp': data['timestamp'] != null
            ? (data['timestamp'] as Timestamp).toDate().toIso8601String()
            : '',
      });
    }
    return replies;
  }

  // Get replies for a specific answer
  Stream<QuerySnapshot> getRepliesStream(String answerId) {
    return FirebaseFirestore.instance
        .collection(org)
        .doc(city)
        .collection('answers')
        .doc(answerId)
        .collection('replies')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
