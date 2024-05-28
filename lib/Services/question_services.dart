// ignore_for_file: use_build_context_synchronously, unnecessary_cast, avoid_print, depend_on_referenced_packages

// import 'package:connectgateproject/models/question_model.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:connectgate/models/question_model.dart';
import 'package:connectgate/shared_pref/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<MyAppAdmins?> getCurrentAdmin() async {
    try {
      String adminid = "";
      await Pref_Services().GetAdmin_uid().then((value) {
        adminid = value.toString();
      });

      User? currentAdmin = _auth.currentUser;
      if (currentAdmin != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('admins').doc(adminid).get();
        Map<String, dynamic> adminData =
            userSnapshot.data() as Map<String, dynamic>;

        return MyAppAdmins(
          id: currentAdmin.uid,
          name: adminData['name'] ?? '',
          email: adminData['email'] ?? '',
          password: '', // Password is not stored in Firestore
          role: AdminRole.values.firstWhere(
            (role) => role.toString() == adminData['role'],
            orElse: () => AdminRole.admin,
          ),
          city: adminData['city'] ?? '',
          org: adminData['org'] ?? '',
        );
      }
    } catch (e) {
      //   _showSnackBar('Error getting admins data: $e', Colors.red);
    }

    return null;
  }

  Future<void> addQuestionToFirestore({
    required BuildContext context,
    required String title,
    required String question,
    required String type,
    List<String>? options,
    List<String>? groupIds,
    required String groupname,

    // Add a list of group names
  }) async {
    try {
      MyAppAdmins? adminData = await getCurrentAdmin();

      final questionRef = _firestore
          .collection(adminData!.org)
          .doc(adminData.city)
          .collection('questions')
          .doc();
      await questionRef.set({
        'id': questionRef.id,
        'title': title,
        'question': question,
        'type': type,
        'options': options,
        'groupIds': groupIds,
        'groupname': groupname,
        'createdAt': FieldValue.serverTimestamp(), // Add server timestamp
        'org': adminData.org,
        'city': adminData.city
      });
      _showSnackBar('Question sent successfully!'.tr, Colors.green, context);
    } catch (e) {
      _showSnackBar(
          'Error saving question to Firestore: $e', Colors.red, context);
    }
  }

  // Stream<List<Question>> getQuestionsForUser(
  //     String userId, List<String> userGroupIds) {
  //   try {
  //     return FirebaseFirestore.instance
  //         .collection('questions')
  //         .where('groupIds',
  //             arrayContainsAny:
  //                 userGroupIds) // Use arrayContainsAny to match any of the user's group IDs
  //         .orderBy('createdAt', descending: true)
  //         .snapshots()
  //         .map((querySnapshot) {
  //       return querySnapshot.docs.map((doc) {
  //         final data = doc.data();
  //         return Question(
  //           id: doc.id,
  //           title: data['title'] ?? '',
  //           question: data['question'] ?? '',
  //           type: data['type'] ?? '',
  //           options: data['options'] != null
  //               ? List<String>.from(data['options'])
  //               : [],
  //           groupIds: data['groupIds'] != null
  //               ? List<String>.from(data['groupIds'])
  //               : [],
  //           groupname: data['groupname'] ?? '',
  //           createdAt: data['createdAt'] ?? Timestamp.now(),
  //         );
  //       }).toList();
  //     });
  //   } catch (e) {
  //     print('Error getting questions: $e');
  //     return Stream.value([]);
  //   }
  // }
  Stream<List<Question>> getQuestionsForUser(
      String userId, List<String> userGroupIds) {
    try {
      return Stream.fromFuture(getCurrentAdmin()).asyncExpand((adminData) {
        if (adminData != null) {
          return FirebaseFirestore.instance
              .collection(adminData.org)
              .doc(adminData.city)
              .collection('questions')
              .where('groupIds', arrayContainsAny: userGroupIds)
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((querySnapshot) {
            return querySnapshot.docs.map((doc) {
              final data = doc.data();
              return Question(
                id: doc.id,
                title: data['title'] ?? '',
                question: data['question'] ?? '',
                type: data['type'] ?? '',
                options: data['options'] != null
                    ? List<String>.from(data['options'])
                    : [],
                groupIds: data['groupIds'] != null
                    ? List<String>.from(data['groupIds'])
                    : [],
                groupname: data['groupname'] ?? '',
                createdAt: data['createdAt'] ?? Timestamp.now(),
              );
            }).toList();
          });
        } else {
          // Handle the case when adminData is null (e.g., admin not logged in)
          return Stream.value([]);
        }
      });
    } catch (e) {
      print('Error getting questions: $e');
      return Stream.value([]);
    }
  }

  void _showSnackBar(
      String message, Color backgroundColor, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
