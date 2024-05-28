// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_constructors_in_immutables, unused_local_variable, unnecessary_new, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, avoid_print, sized_box_for_whitespace, unnecessary_null_comparison, depend_on_referenced_packages, no_leading_underscores_for_local_identifiers, prefer_spread_collections, prefer_const_declarations, unnecessary_cast, unused_import, unused_element

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/admin_model.dart';
// import 'package:connectgateproject/Services/auth_services.dart';
// import 'package:connectgateproject/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';

class seeAnswersAdmin extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final String questionId; // Pass the question document ID
  seeAnswersAdmin({
    super.key,
    required this.questionData,
    required this.questionId,
  });

  @override
  State<seeAnswersAdmin> createState() => _SeeAnsweresState();
}

int _list_counter = 0;
List<String> _name = [];
List<String> _email = [];
List<String> _answer = [];
List<String> _time = [];

class _SeeAnsweresState extends State<seeAnswersAdmin> {
  // Define instance variables to store question data
  String title = '';
  String questionitself = '';
  String questiontype = '';
  String groupname = '';

  void getAnswers(String myTitle) async {
    await Future.delayed(const Duration(seconds: 1));

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(currentAdmin!.org)
        .doc(currentAdmin!.city)
        .collection('answers')
        .get();

    // Initialize the map if it's null
    answersDataMap = {};
    answersDataMap[myTitle] =
        []; // Initialize the answers list for this question

    querySnapshot.docs.forEach((doc) {
      if (doc.get('title') == myTitle) {
        _list_counter += 1;
        print(_list_counter);
        print("myTitle: $myTitle");
        answersDataMap[myTitle]!.add(doc.get('user_name')); // Store username
        answersDataMap[myTitle]!.add(doc.get('user_email')); // Store user email
        answersDataMap[myTitle]!.add(doc.get('answer')); // Store user answer
        answersDataMap[myTitle]!
            .add(doc.get('timestamp').toDate().toString()); // Store timestamp
      }
    });
  }

  Map<String, dynamic>? questionData;
  Map<String, List<String>> answersDataMap =
      {}; // Store answers data for each question

  MyAppAdmins? currentAdmin;
  @override
  void initState() {
    super.initState();

    fetchQuestionAndAnswers();
    // Future.delayed(const Duration(seconds: 1));
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    AuthService authService = AuthService(context);
    MyAppAdmins? adminData = (await authService.getCurrentAdmin());
    setState(() {
      currentAdmin = adminData;
    });
  }

  Future<void> fetchQuestionAndAnswers() async {
    await Future.delayed(const Duration(seconds: 1));
    final questionDocument = await FirebaseFirestore.instance
        .collection(currentAdmin!.org)
        .doc(currentAdmin!.city)
        .collection('questions')
        .doc(widget.questionId)
        .get();

    questionData = questionDocument.data() as Map<String, dynamic>?;

    List<List<String>> answersData = []; // Define answersData here

    if (questionData != null) {
      final questionTitle = questionData!['title'] as String;
      print('Fetched question title: $questionTitle'); // Add this line

      final answersQuerySnapshot = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .where('title', isEqualTo: questionTitle)
          .get();

      answersData = answersQuerySnapshot.docs.map((answerDocument) {
        final userName = answerDocument['user_name'] as String;
        final userEmail = answerDocument['user_email'] as String;
        final userAnswer = answerDocument['answer'] as String;

        print(
            'Fetched answer data: $userName, $userEmail, $userAnswer'); // Add this line

        return [
          userName,
          userEmail,
          userAnswer,
        ];
      }).toList();
    }

    // Now, answersData is available within the scope of this function
    // You can use it as needed.
  }

  Future<List<List<dynamic>>> generateCSVData(
    Map<String, dynamic> questionData,
    List<String> answersData,
  ) async {
    if (answersData.isEmpty) {
      return []; // Handle empty data
    }

    final List<List<dynamic>> rows = [
      [
        'Questions Title',
        'Questions',
        'Questions Group',
        'Questions Type',
        'Users Name',
        'Users Email',
        'Users Answer',
      ],
    ];

    final title = questionData['title'] as String;
    final questionitself = questionData['question'] as String;
    final groupname = questionData['groupname'] as String;
    final questiontype = questionData['type'] as String;

    for (int i = 0; i < answersData.length; i += 4) {
      rows.add([
        title, // question title
        questionitself, // question itself
        groupname, // group name
        questiontype,
        answersData[i], // username
        answersData[i + 1], // useremail
        answersData[i + 2], // useranswer
      ]);
    }

    return rows;
  }

  Future<void> downloadCSV() async {
    // Generate CSV data
    final title =
        widget.questionData['title'] as String; // Get the question title

    if (answersDataMap != null && answersDataMap.containsKey(title)) {
      final csvData = await generateCSVData(
        widget.questionData, // Pass questionData
        answersDataMap[title]!, // Pass answers data for the specific question
      );

      // Get the document directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/$title.csv'; // Use the question title in the filename

      // Create a File instance and write the CSV data as bytes to it
      final file = File(filePath);
      final csvFile = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csvFile, encoding: utf8); // Use UTF-8 encoding

      // Share the file
      await Share.shareFiles([filePath], text: 'Questions and Answers CSV');
    } else {
      // Handle case where answers data is not available
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
    getAnswers(title);
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
                                  height: 245,
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
                                                  height: 10.1,
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
                                                    maxLines: 20,
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
                                                const SizedBox(height: 25),
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
                      child: ElevatedButton(
                        onPressed: downloadCSV,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        child: Icon(
                          Icons.download_rounded,
                          size: 26,
                          color: Colors
                              .white, // Set the color to green if answered, otherwise let it inherit
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Nointernet();
      }
      return CircularProgressIndicator();
    });
  }

  Widget answares_card(String myTitle) {
    return StreamBuilder<QuerySnapshot>(
      stream: currentAdmin != null
          ? FirebaseFirestore.instance
              .collection(currentAdmin!.org)
              .doc(currentAdmin!.city)
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
              final useremail = answer.get('user_email');
              final userAnswer = answer.get('answer');
              // final timestamp = answer.get('timestamp') as Timestamp;
              final timestamp = answer.get('timestamp') as Timestamp?;

              final finalData = timestamp != null
                  ? DateTime.parse(timestamp.toDate().toString())
                  : null;
              return Padding(
                padding: const EdgeInsets.only(
                    top: 0.1, left: 16, bottom: 16, right: 16),
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
