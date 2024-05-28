// ignore_for_file: file_names, prefer_const_constructors, unused_element, avoid_function_literals_in_foreach_calls, avoid_print, unnecessary_cast, unused_import, unused_local_variable, prefer_const_literals_to_create_immutables, depend_on_referenced_packages

import 'dart:math';

import 'package:connectgate/Screen/User_Side/Open_Q_Page.dart';
import 'package:connectgate/Screen/User_Side/see_users_answers.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

class QuestionUser extends StatefulWidget {
  const QuestionUser({super.key});

  @override
  State<QuestionUser> createState() => _QuestionUserState();
}

class _QuestionUserState extends State<QuestionUser> {
  List<String> userGroups = [];
  int currentQuestionIndex = 0; // Initialize it with 0
  MyAppUser? currentUser;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1));
    SeendUpdate(context);
    fetchUserGroups();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    AuthService authService = AuthService(context);
    MyAppUser? userData = (await authService.getCurrentUser());
    setState(() {
      currentUser = userData;
    });
  }

  Future<void> fetchUserGroups() async {
    try {
      final groups = await getCurrentUserGroups();
      setState(() {
        userGroups = groups;
      });
    } catch (e) {
      print('Error fetching user groups: $e');
    }
  }

// Function to retrieve current user's group IDs
  Future<List<String>> getCurrentUserGroups() async {
    List<String> userGroups = [];
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? groupsData = userDoc['groups'];

          if (groupsData != null) {
            // Add all group IDs to the userGroups list
            userGroups.addAll(groupsData.keys);
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return userGroups;
  }

  // Future<bool> hasUserAnsweredQuestion(String questionTitle) async {
  //   try {
  //     final User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       final userEmail = user.email;
  //       final QuerySnapshot result = await FirebaseFirestore.instance
  //           .collection('answers')
  //           .where('title', isEqualTo: questionTitle)
  //           .where('user_email', isEqualTo: userEmail)
  //           .get();

  //       return result.docs.isNotEmpty;
  //     } else {
  //       return false; // User is not authenticated
  //     }
  //   } catch (e) {
  //     print('Error checking if the user has answered the question: $e');
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      return modle.isonline
          ? Scaffold(
              body: StreamBuilder<QuerySnapshot>(
                //   final questions = snapshot.data!.docs;
                stream: currentUser != null
                    ? FirebaseFirestore.instance
                        .collection(currentUser!.org)
                        .doc(currentUser!.city)
                        .collection('questions')
                        .where('groupIds',
                            arrayContainsAny: userGroups.isNotEmpty
                                ? userGroups
                                : ['']) // Ensure userGroups is not empty
                        .where('createdAt',
                            isGreaterThanOrEqualTo: DateTime.now().subtract(
                                Duration(
                                    hours:
                                        24))) // Filter out questions older than 24 hours
                        .orderBy('createdAt', descending: false)
                        .snapshots()
                    : Stream.empty(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator()));
                  }

                  final questions = snapshot.data!.docs;

                  return CustomScrollView(
                    slivers: [
                      //sliver appbar
                      SliverAppBar(
                        // /leading: const Icon(Icons.menu),
                        automaticallyImplyLeading: false,
                        expandedHeight: 130,

                        floating: false,
                        pinned: true,
                        snap: false,
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.white,
                        flexibleSpace: FlexibleSpaceBar(
                          expandedTitleScale: 1.3,
                          background: Container(
                              color:
                                  Colors.white //Color.fromARGB(255, 31, 0, 0),
                              ),
                          centerTitle: true,
                          title: Text(
                            'Q U E S T I O N S'.tr,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'ageo-bold',
                              letterSpacing: ln2,
                            ),
                          ),
                        ),
                      ),

                      //sliver Items
                      ////,
                      ///////////////////////////
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final question = questions[index];
                            // Update the currentQuestionIndex
                            currentQuestionIndex = index;
//////////////
                            final title = question['title'] as String;
                            final timestamp =
                                question['createdAt'] as Timestamp;
                            final questionitself =
                                question['question'] as String;
                            final questiontype = question['type'] as String;
                            final options =
                                question['options'] as List<dynamic>;
                            final groupname = question['groupname'] as String;

                            // final formattedTimestamp = formatTimestamp(timestamp);
                            Timestamp data =
                                snapshot.data!.docs[index]['createdAt'];
                            final finalData =
                                DateTime.parse(data.toDate().toString());
                            // Define isAnswered variable here

                            // Check if the user has answered the question
                            //  final hasAnswered = hasUserAnsweredQuestion(title);

                            // Check if the user has answered the question in real-time
                            return StreamBuilder<QuerySnapshot>(
                              stream: currentUser != null
                                  ? FirebaseFirestore.instance
                                      .collection(currentUser!.org)
                                      .doc(currentUser!.city)
                                      .collection('answers')
                                      .where('title', isEqualTo: title)
                                      .where('user_email',
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser?.email)
                                      .snapshots()
                                  : Stream.empty(),
                              builder: (context, answerSnapshot) {
                                if (answerSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Handle the case when the answer data is still loading
                                  return Center(
                                      child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator()));
                                } else if (answerSnapshot.hasError) {
                                  // Handle error
                                  return Text('Error: ${answerSnapshot.error}');
                                } else {
                                  final hasAnswered =
                                      answerSnapshot.data?.docs.isNotEmpty ??
                                          false;
                                  return Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        height: 70,
                                        color: Colors.black87,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        title,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'NRT',
                                                            fontSize: 16),
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Text(
                                                        GetTimeAgo.parse(
                                                            finalData),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            // fontFamily: 'NRT',
                                                            fontSize: 12),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 40,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      SizedBox(
                                                        height: 45,
                                                        width: 45,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            // Assuming you have a "question" variable representing the question data
                                                            final questionData =
                                                                {
                                                              'title':
                                                                  title, // Replace with the actual data you want to pass
                                                              'createdAt':
                                                                  timestamp, // Replace with the actual data you want to pass
                                                              // Add more fields as needed
                                                              'question':
                                                                  questionitself,
                                                              'type':
                                                                  questiontype,
                                                              'options':
                                                                  options,
                                                              'groupname':
                                                                  groupname,
                                                            };

                                                            if (hasAnswered) {
                                                              // Show check icon button
                                                              // Handle navigation to seeAnswers page

                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SeeAnsweres(
                                                                    questionData:
                                                                        questionData,
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              // Show forward icon button
                                                              // Handle navigation to OpenQPage
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          OpenQPage(
                                                                    questionData:
                                                                        questionData,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          41,
                                                                          41,
                                                                          41), // Use the default color for unanswered questions
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  )),
                                                          child: Icon(
                                                            hasAnswered
                                                                ? Icons.check
                                                                : Icons
                                                                    .arrow_forward_ios,
                                                            size: 20,
                                                            color: hasAnswered
                                                                ? Colors.green
                                                                : Colors
                                                                    .white, // Set the color to green if answered, otherwise let it inherit
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                          childCount: questions.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 25,
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [],
                                        ),
                                        SizedBox(
                                          width: 70,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      /////////////////////
                    ],
                  );
                },
              ),
            )
          : Nointernet();
    });
  }
}

// String formatTimestamp(Timestamp timestamp) {
//   final now = DateTime.now();
//   final dateTime = timestamp.toDate();
//   final difference = now.difference(dateTime);

//   if (difference.inMinutes < 1) {
//     return 'Just now';
//   } else if (difference.inMinutes < 60) {
//     final minutes = difference.inMinutes;
//     return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
//   } else if (difference.inHours < 24) {
//     final hours = difference.inHours;
//     return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
//   } else {
//     final formatter = DateFormat('dd MMM yyyy HH:mm');
//     return formatter.format(dateTime);
//   }
// }
