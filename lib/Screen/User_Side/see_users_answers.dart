// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_constructors_in_immutables, unused_local_variable, unnecessary_new, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, avoid_print, sized_box_for_whitespace, unnecessary_null_comparison, depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Screen/User_Side/Open_Q_Page.dart';
import 'package:connectgate/Screen/User_Side/User_Main_Screen.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

class SeeAnsweres extends StatefulWidget {
  // final Map<String, dynamic> answeresData;
  final Map<String, dynamic> questionData;
  // final int totalQuestions;
  SeeAnsweres({
    super.key,
    required this.questionData,
  });

  @override
  State<SeeAnsweres> createState() => _SeeAnsweresState();
}

class _SeeAnsweresState extends State<SeeAnsweres> {
  Map<int, dynamic> _questionData = {};
  Map<int, dynamic> _questionData2 = {};

  List<String> userGroups = [];
  int currentQuestionIndex = 0;

  // bool visible = true;
  MyAppUser? currentUser;

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

  Future<void> get_all_questions() async {
    final firestore = FirebaseFirestore.instance;

    // Reference to your Firestore collection
    await Future.delayed(const Duration(seconds: 1));
    final collectionReference = firestore
        .collection(currentUser!.org)
        .doc(currentUser!.city)
        .collection('questions')
        .where('groupIds',
            arrayContainsAny: userGroups.isNotEmpty
                ? userGroups
                : ['']) // Ensure userGroups is not empty
        .where('createdAt',
            isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(
                hours: 24))) // Filter out questions older than 24 hours
        .orderBy('createdAt', descending: false);
    // Query the collection and get all documents
    QuerySnapshot querySnapshot = await collectionReference.get();

    // Initialize an empty map to store the document data
    // _questionData = {};
    // Loop through the documents and add them to the map
    int index = 0;
    _questionData = {};
    querySnapshot.docs.forEach((document) {
      final title = document.get("title") as String;
      final timestamp = document.get('createdAt') as Timestamp;
      final questionitself = document.get('question') as String;
      final questiontype = document.get('type') as String;
      final options = document.get('options') as List<dynamic>;
      final groupname = document.get('groupname') as String;

      ///
      ///

      final questionData = {
        'title': title, // Replace with the actual data you want to pass
        'createdAt': timestamp, // Replace with the actual data you want to pass
        // Add more fields as needed
        'question': questionitself,
        'type': questiontype,
        'options': options,
        'groupname': groupname,
      };

      _questionData.addAll({index: questionData});

      index++;
    });
    // Rename get_all_questions to _initializeQuestions and make it async

//this is for ansawared questions checker

    final firestore2 = FirebaseFirestore.instance;
    await Future.delayed(const Duration(seconds: 1));
    // Reference to your Firestore collection
    final collectionReference2 = firestore2
        .collection(currentUser!.org)
        .doc(currentUser!.city)
        .collection('answers')
        .where('user_email',
            isEqualTo: FirebaseAuth.instance.currentUser?.email);

    // Query the collection and get all documents
    QuerySnapshot querySnapshot2 = await collectionReference2.get();

    // Initialize an empty map to store the document data
    if (querySnapshot2.docs.isEmpty) {
      return;
    }

    // Loop through the documents and add them to the map
    querySnapshot2.docs.forEach((document) {
      _questionData.removeWhere((key, value) {
        return value['title'] == document.get("title") as String;
      });

      _questionData2 = _questionData;
    });
  }

  @override
  void dispose() {
    _questionData = {};
    // _questionData2 = {};
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1));
    fetchUserData();
    fetchUserGroups();
    getCurrentUserGroups();
    // _initializeQuestions();
  }

  Future<void> _initializeQuestions() async {
    Future.delayed(const Duration(seconds: 1));
    await get_all_questions();
    // Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      // Check if the widget is still mounted
      if (_questionData2.keys.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserMainScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OpenQPage(
              questionData: _questionData[_questionData2.keys.first],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionData = widget.questionData;

    final groupname = questionData['groupname'] as String;
    final title = questionData['title'] as String;
    final timestamp = questionData['createdAt'] as Timestamp;
    final questionitself = questionData['question'] as String;
    final questiontype = questionData['type'] as String;

    final options =
        questionData['options'] as List<dynamic>; // Cast options as a List
    // getAnswers(title);
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      if (modle.isonline != null) {
        return modle.isonline
            ? Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.white,
                    body: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(
                          new FocusNode(),
                        );
                      },
                      child: SingleChildScrollView(
                        // reverse: true,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 290,
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height,
                                    maxWidth: MediaQuery.of(context).size.width,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(50),
                                      bottomRight: Radius.circular(50),
                                    ),
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 60, left: 22, right: 20),
                                        child: Wrap(
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Icon(
                                                          Icons.arrow_back,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      title,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontFamily: 'NRT'),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                  width: double.infinity,
                                                ),
                                                const Center(
                                                  child: Icon(
                                                    Icons.message,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                  width: double.infinity,
                                                ),
                                                Center(
                                                  child: Text(
                                                    questionitself,
                                                    softWrap: true,
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 15,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontFamily: 'NRT',
                                                      letterSpacing: ln2,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 15),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 650,
                                  child: answares_card(title),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, right: 40),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Visibility(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _initializeQuestions(); // Start initializing questions
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            : Nointernet();
      }
      return CircularProgressIndicator();
    });
  }

  Widget answares_card(String myTitle) {
    return StreamBuilder<QuerySnapshot>(
      stream: currentUser != null
          ? FirebaseFirestore.instance
              .collection(currentUser!.org)
              .doc(currentUser!.city)
              .collection('answers')
              .where('title', isEqualTo: myTitle)
              .orderBy('timestamp', descending: true) // Add orderBy clause here
              .snapshots()
          : Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator()),
          );
        } else {
          final answers = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: answers.length,
            itemBuilder: (context, index) {
              final answer = answers[index];
              final userName = answer.get('user_name');
              final userAnswer = answer.get('answer');
              // final timestamp = answer.get('timestamp') as Timestamp;
              final timestamp = answer.get('timestamp') as Timestamp?;

              final finalData = timestamp != null
                  ? DateTime.parse(timestamp.toDate().toString())
                  : null;
              return Padding(
                padding: const EdgeInsets.only(
                    top: 2.5, left: 16, bottom: 16, right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Color.fromARGB(221, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Wrap(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        height: 65,
                                        width: 65,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(400)),
                                        child: const Icon(
                                          Icons.person_4,
                                          color: Colors.white,
                                          size: 45,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                letterSpacing: 1.2,
                                                color: Colors.white,
                                                fontFamily: 'ageo-bold'),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            finalData != null
                                                ? GetTimeAgo.parse(finalData)
                                                : 'N/A', // Display 'N/A' while loading
                                            style: TextStyle(
                                                color: Colors.white,
                                                //fontFamily: 'ageo',
                                                letterSpacing: 1.1,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w400),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 84.0),
                                    child: Divider(
                                      color: Colors.white30,
                                      thickness: 1.4,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    userAnswer,
                                    softWrap: true,
                                    overflow: TextOverflow.clip,
                                    maxLines: 8,
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        height: 1.25,
                                        color: Colors.white,
                                        fontFamily: 'NRT',
                                        fontSize: 14),
                                  ),
                                  SizedBox(
                                    height: 9,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
