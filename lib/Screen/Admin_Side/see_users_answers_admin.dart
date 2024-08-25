import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/Widgets/answer_card_admin_side.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart'; // Ensure this is defined elsewhere
import 'package:connectgate/models/admin_model.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class SeeAnswersAdmin extends StatefulWidget {
  final Map<String, dynamic> questionData;
  final String questionId;

  const SeeAnswersAdmin({
    Key? key,
    required this.questionData,
    required this.questionId,
  }) : super(key: key);

  @override
  _SeeAnswersAdminState createState() => _SeeAnswersAdminState();
}

class _SeeAnswersAdminState extends State<SeeAnswersAdmin> {
  final Map<String, List<List<dynamic>>> answersDataMap = {};
  MyAppAdmins? currentAdmin;

  late String title;
  late String questionItself;
  late String questionType;
  late String groupName;

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, model, child) {
      return model.isonline
          ? Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 245,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 60, left: 22, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(' '),
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'NRT',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              SizedBox(height: 15),
                              Center(
                                child: Text(
                                  questionItself,
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                  maxLines: 20,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'NRT',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add a bottom widget to customize appearance when minimized
                  ),
                  SliverToBoxAdapter(
                    child: AnswersCard(
                      myTitle: widget.questionData['title'] ?? 'N/A',
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: downloadCSV,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                ),
              ),
            )
          : Nointernet(); // Ensure this widget is defined or replace with appropriate widget
    });
  }

  Future<void> downloadCSV() async {
    if (title.isEmpty || !answersDataMap.containsKey(title)) return;

    final csvData = await generateCSVData(
      widget.questionData,
      answersDataMap[title]!,
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$title.csv';
    final file = File(filePath);
    final csvFile = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvFile, encoding: utf8);

    await Share.shareFiles([filePath], text: 'Questions and Answers CSV');
  }

  Future<void> fetchQuestionAndAnswers() async {
    if (currentAdmin == null) return;

    try {
      final questionDocument = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('questions')
          .doc(widget.questionId)
          .get();

      if (!questionDocument.exists) return;

      final questionData = questionDocument.data() as Map<String, dynamic>;
      setState(() {
        title = questionData['title'] as String? ?? '';
        questionItself = questionData['question'] as String? ?? '';
        groupName = questionData['groupname'] as String? ?? '';
        questionType = questionData['type'] as String? ?? '';
      });

      final answersQuerySnapshot = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('answers')
          .where('title', isEqualTo: title)
          .get();

      final answersList = answersQuerySnapshot.docs.map((answerDocument) {
        final userName = answerDocument['user_name'] as String? ?? 'Unknown';
        final userEmail = answerDocument['user_email'] as String? ?? 'N/A';
        final userAnswer = answerDocument['answer'] as String? ?? 'No answer';
        final timestamp = answerDocument['timestamp'] as Timestamp?;

        return [
          userName,
          userEmail,
          userAnswer,
          timestamp != null ? timestamp.toDate().toString() : ''
        ];
      }).toList();

      setState(() {
        answersDataMap[title] = answersList;
      });
    } catch (e) {
      print('Error fetching question and answers: $e');
    }
  }

  Future<void> fetchUserData() async {
    final authService = AuthService(context);
    final adminData = await authService.getCurrentAdmin();
    setState(() {
      currentAdmin = adminData;
    });
  }

  Future<List<List<dynamic>>> generateCSVData(
    Map<String, dynamic> questionData,
    List<List<dynamic>> answersData,
  ) async {
    if (answersData.isEmpty) {
      return [];
    }

    final rows = [
      [
        'Questions Title',
        'Questions',
        'Questions Group',
        'Questions Type',
        'Users Name',
        'Users Email',
        'Users Answer',
        'Timestamp', // Added Timestamp for clarity
      ],
    ];

    final title = questionData['title'] as String? ?? '';
    final questionItself = questionData['question'] as String? ?? '';
    final groupName = questionData['groupname'] as String? ?? '';
    final questionType = questionData['type'] as String? ?? '';

    for (var answer in answersData) {
      rows.add([
        title,
        questionItself,
        groupName,
        questionType,
        answer[0],
        answer[1],
        answer[2],
        answer[3], // Timestamp column
      ]);
    }

    return rows;
  }

  @override
  void initState() {
    super.initState();
    _initialize();

    title = widget.questionData['title'] ?? '';
    questionItself = widget.questionData['question'] ?? '';
    questionType = widget.questionData['type'] ?? '';
    groupName = widget.questionData['groupname'] ?? '';
  }

  Future<void> _initialize() async {
    await fetchUserData();
    await fetchQuestionAndAnswers();
  }
}

























// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/Widgets/answer_card.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart'; // Make sure this is defined elsewhere
// import 'package:connectgate/models/admin_model.dart';
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';

// class SeeAnswersAdmin extends StatefulWidget {
//   final Map<String, dynamic> questionData;
//   final String questionId;

//   const SeeAnswersAdmin({
//     Key? key,
//     required this.questionData,
//     required this.questionId,
//   }) : super(key: key);

//   @override
//   _SeeAnswersAdminState createState() => _SeeAnswersAdminState();
// }

// class _SeeAnswersAdminState extends State<SeeAnswersAdmin> {
//   final Map<String, List<String>> answersDataMap = {};
//   MyAppAdmins? currentAdmin;

//   late String title;
//   late String questionItself;
//   late String questionType;
//   late String groupName;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<connectivitycheck>(builder: (context, model, child) {
//       return model.isonline
//           ? Stack(
//               children: [
//                 Scaffold(
//                   backgroundColor: Colors.white,
//                   body: GestureDetector(
//                     onTap: () => FocusScope.of(context).unfocus(),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: [
//                           Container(
//                             height: 245,
//                             constraints: BoxConstraints(
//                               maxHeight: MediaQuery.of(context).size.height,
//                               maxWidth: MediaQuery.of(context).size.width,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(50),
//                                 bottomRight: Radius.circular(50),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                   top: 60, left: 22, right: 20),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () => Navigator.pop(context),
//                                         child: Icon(Icons.arrow_back,
//                                             color: Colors.white),
//                                       ),
//                                       Text(
//                                         title,
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontFamily: 'NRT',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 10),
//                                   Center(
//                                     child: Icon(Icons.message,
//                                         color: Colors.white, size: 22),
//                                   ),
//                                   SizedBox(height: 15),
//                                   Center(
//                                     child: Text(
//                                       questionItself,
//                                       softWrap: true,
//                                       overflow: TextOverflow.clip,
//                                       maxLines: 20,
//                                       textAlign: TextAlign.justify,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 14,
//                                         fontFamily: 'NRT',
//                                         letterSpacing: 1.2,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 25),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: double.infinity,
//                             height: 640,
//                             child: AnswersCard(
//                                 myTitle: widget.questionData['title'] ??
//                                     'N/A'), // Pass the question ID
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 40,
//                   right: 40,
//                   child: ElevatedButton(
//                     onPressed: downloadCSV,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50.0),
//                       ),
//                     ),
//                     child: Icon(Icons.download_rounded,
//                         size: 26, color: Colors.white),
//                   ),
//                 ),
//               ],
//             )
//           : Nointernet(); // Ensure this widget is defined or replace with appropriate widget
//     });
//   }

//   Future<void> downloadCSV() async {
//     if (title.isEmpty || !answersDataMap.containsKey(title)) return;

//     final csvData = await generateCSVData(
//       widget.questionData,
//       answersDataMap[title]!,
//     );

//     final directory = await getApplicationDocumentsDirectory();
//     final filePath = '${directory.path}/$title.csv';
//     final file = File(filePath);
//     final csvFile = const ListToCsvConverter().convert(csvData);
//     await file.writeAsString(csvFile, encoding: utf8);

//     await Share.shareFiles([filePath], text: 'Questions and Answers CSV');
//   }

//   Future<void> fetchQuestionAndAnswers() async {
//     if (currentAdmin == null) return;

//     final questionDocument = await FirebaseFirestore.instance
//         .collection(currentAdmin!.org)
//         .doc(currentAdmin!.city)
//         .collection('questions')
//         .doc(widget.questionId)
//         .get();

//     if (!questionDocument.exists) return;

//     final questionData = questionDocument.data() as Map<String, dynamic>;
//     setState(() {
//       title = questionData['title'] as String;
//       questionItself = questionData['question'] as String;
//       groupName = questionData['groupname'] as String;
//       questionType = questionData['type'] as String;
//     });

//     final answersQuerySnapshot = await FirebaseFirestore.instance
//         .collection(currentAdmin!.org)
//         .doc(currentAdmin!.city)
//         .collection('answers')
//         .where('title', isEqualTo: title)
//         .get();

//     final answersList = answersQuerySnapshot.docs.map((answerDocument) {
//       final userName = answerDocument['user_name'] as String;
//       final userEmail = answerDocument['user_email'] as String;
//       final userAnswer = answerDocument['answer'] as String;
//       final timestamp = answerDocument['timestamp']?.toDate().toString() ?? '';

//       return [userName, userEmail, userAnswer, timestamp];
//     }).toList();

//     setState(() {
//       answersDataMap[title] = answersList.expand((i) => i).toList();
//     });
//   }

//   Future<void> fetchUserData() async {
//     final authService = AuthService(context);
//     final adminData = await authService.getCurrentAdmin();
//     setState(() {
//       currentAdmin = adminData;
//     });
//   }

//   Future<List<List<dynamic>>> generateCSVData(
//     Map<String, dynamic> questionData,
//     List<String> answersData,
//   ) async {
//     if (answersData.isEmpty) {
//       return [];
//     }

//     final rows = [
//       [
//         'Questions Title',
//         'Questions',
//         'Questions Group',
//         'Questions Type',
//         'Users Name',
//         'Users Email',
//         'Users Answer',
//       ],
//     ];

//     final title = questionData['title'] as String;
//     final questionItself = questionData['question'] as String;
//     final groupName = questionData['groupname'] as String;
//     final questionType = questionData['type'] as String;

//     for (int i = 0; i < answersData.length; i += 4) {
//       rows.add([
//         title,
//         questionItself,
//         groupName,
//         questionType,
//         answersData[i],
//         answersData[i + 1],
//         answersData[i + 2],
//       ]);
//     }

//     return rows;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initialize();

//     title = widget.questionData['title'] ?? '';
//     questionItself = widget.questionData['question'] ?? '';
//     questionType = widget.questionData['type'] ?? '';
//     groupName = widget.questionData['groupName'] ?? '';
//   }

//   Future<void> _initialize() async {
//     await fetchUserData();
//     await fetchQuestionAndAnswers();
//   }
// }















































