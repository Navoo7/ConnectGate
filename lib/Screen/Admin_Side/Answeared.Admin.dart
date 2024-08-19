// ignore_for_file: prefer_const_constructors, file_names, depend_on_referenced_packages, unused_element, avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Screen/Admin_Side/see_users_answers_admin.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

class AnswearedAdmin extends StatefulWidget {
  const AnswearedAdmin({super.key});

  @override
  State<AnswearedAdmin> createState() => _AnswearedAdminState();
}

class _AnswearedAdminState extends State<AnswearedAdmin> {
  List<String> userGroups = [];
  int currentQuestionIndex = 0;
  MyAppAdmins? currentAdmin;

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(
      builder: (context, model, child) {
        return model.isonline
            ? Scaffold(
                body: StreamBuilder<QuerySnapshot>(
                  stream: currentAdmin != null
                      ? FirebaseFirestore.instance
                          .collection(currentAdmin!.org)
                          .doc(currentAdmin!.city)
                          .collection('questions')
                          .where(
                            'createdAt',
                            isGreaterThanOrEqualTo: DateTime.now().subtract(
                              const Duration(hours: 48),
                            ),
                          )
                          .orderBy('createdAt', descending: false)
                          .snapshots()
                      : Stream.empty(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      );
                    }

                    final questions = snapshot.data!.docs;

                    return CustomScrollView(
                      slivers: [
                        SliverAppBar(
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
                              color: Colors.white,
                            ),
                            centerTitle: true,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'A N S W E R S'.tr,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'ageo-bold',
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final question = questions[index];
                              currentQuestionIndex = index;
                              final title = question['title'] as String;
                              final timestamp =
                                  question['createdAt'] as Timestamp;
                              final questionitself =
                                  question['question'] as String;
                              final questiontype = question['type'] as String;
                              final options =
                                  question['options'] as List<dynamic>;
                              final groupname = question['groupname'] as String;
                              final finalData = DateTime.parse(
                                timestamp.toDate().toString(),
                              );

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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'NRT',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    GetTimeAgo.parse(finalData),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 40),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  SizedBox(
                                                    height: 45,
                                                    width: 60,
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        final questionData = {
                                                          'title': title,
                                                          'createdAt':
                                                              timestamp,
                                                          'question':
                                                              questionitself,
                                                          'type': questiontype,
                                                          'options': options,
                                                          'groupname':
                                                              groupname,
                                                        };
                                                        final questionId =
                                                            question.id;
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                SeeAnswersAdmin(
                                                              questionId:
                                                                  questionId,
                                                              questionData:
                                                                  questionData,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(
                                                          255,
                                                          41,
                                                          41,
                                                          41,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 20,
                                                      ),
                                                    ),
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
                                          // This section seems to be empty in the original code
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            : Nointernet();
      },
    );
  }

  Future<void> deleteOldQuestions() async {
    if (currentAdmin == null) return; // Check if currentAdmin is not null

    try {
      final currentTime = DateTime.now();
      final thresholdTime = currentTime.subtract(const Duration(hours: 48));

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(currentAdmin!.org)
          .doc(currentAdmin!.city)
          .collection('questions')
          .where('createdAt', isLessThan: thresholdTime)
          .get();

      for (final DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Consider using a logging library or error handling mechanism
      debugPrint('Error deleting old documents: $e');
    }
  }

  Future<void> fetchUserData() async {
    AuthService authService = AuthService(context);
    final adminData = await authService.getCurrentAdmin();
    setState(() {
      currentAdmin = adminData;
    });
  }

  @override
  void initState() {
    super.initState();
    SeendUpdate(context);
    Timer.periodic(const Duration(hours: 24), (Timer timer) {
      deleteOldQuestions();
    });
    fetchUserData();
  }
}














































// // ignore_for_file: prefer_const_constructors, file_names, depend_on_referenced_packages, unused_element, avoid_print
// import 'dart:async';
// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Screen/Admin_Side/see_users_answers_admin.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/core/CeckForUpdate.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/admin_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_time_ago/get_time_ago.dart';
// import 'package:provider/provider.dart';

// class AnswearedAdmin extends StatefulWidget {
//   const AnswearedAdmin({super.key});

//   @override
//   State<AnswearedAdmin> createState() => _AnswearedAdminState();
// }

// class _AnswearedAdminState extends State<AnswearedAdmin> {
//   List<String> userGroups = [];
//   int currentQuestionIndex = 0;
//   MyAppAdmins? currentAdmin;
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<connectivitycheck>(builder: (context, modle, child) {
//       return modle.isonline
//           ? Scaffold(
//               body: StreamBuilder<QuerySnapshot>(
//                 stream: currentAdmin != null
//                     ? FirebaseFirestore.instance
//                         .collection(currentAdmin!.org)
//                         .doc(currentAdmin!.city)
//                         .collection('questions')
//                         .where('createdAt',
//                             isGreaterThanOrEqualTo:
//                                 DateTime.now().subtract(Duration(hours: 48)))
//                         .orderBy('createdAt', descending: false)
//                         .snapshots()
//                     : Stream.empty(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.black,
//                       ),
//                     );
//                   }

//                   final questions = snapshot.data!.docs;

//                   return CustomScrollView(
//                     slivers: [
//                       SliverAppBar(
//                         automaticallyImplyLeading: false,
//                         expandedHeight: 130,
//                         floating: false,
//                         pinned: true,
//                         snap: false,
//                         shadowColor: Colors.transparent,
//                         backgroundColor: Colors.white,
//                         flexibleSpace: FlexibleSpaceBar(
//                           expandedTitleScale: 1.3,
//                           background: Container(
//                             color: Colors.white,
//                           ),
//                           centerTitle: true,
//                           title: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'A N S W E R S'.tr,
//                                 style: const TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 20,
//                                   fontFamily: 'ageo-bold',
//                                   letterSpacing: ln2,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                             final question = questions[index];
//                             currentQuestionIndex = index;
//                             final title = question['title'] as String;
//                             final timestamp =
//                                 question['createdAt'] as Timestamp;
//                             final questionitself =
//                                 question['question'] as String;
//                             final questiontype = question['type'] as String;
//                             final options =
//                                 question['options'] as List<dynamic>;
//                             final groupname = question['groupname'] as String;
//                             Timestamp data =
//                                 snapshot.data!.docs[index]['createdAt'];
//                             final finalData =
//                                 DateTime.parse(data.toDate().toString());

//                             return Padding(
//                               padding: const EdgeInsets.all(20),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(20),
//                                 child: Container(
//                                   height: 70,
//                                   color: Colors.black87,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 20, vertical: 10),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   title,
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontFamily: 'NRT',
//                                                       fontSize: 16),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 6,
//                                                 ),
//                                                 Text(
//                                                   GetTimeAgo.parse(finalData),
//                                                   style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 12),
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(
//                                               width: 40,
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 SizedBox(
//                                                   height: 45,
//                                                   width: 60,
//                                                   child: ElevatedButton(
//                                                     onPressed: () async {
//                                                       final questionData = {
//                                                         'title': title,
//                                                         'createdAt': timestamp,
//                                                         'question':
//                                                             questionitself,
//                                                         'type': questiontype,
//                                                         'options': options,
//                                                         'groupname': groupname,
//                                                       };
//                                                       final questionId = question
//                                                           .id; // Get the question document ID
//                                                       Navigator.push(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               seeAnswersAdmin(
//                                                             questionId:
//                                                                 questionId, // Pass the question ID
//                                                             questionData:
//                                                                 questionData,
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                     style: ElevatedButton
//                                                         .styleFrom(
//                                                             foregroundColor:
//                                                                 Colors.white,
//                                                             backgroundColor:
//                                                                 Color.fromARGB(
//                                                                     255,
//                                                                     41,
//                                                                     41,
//                                                                     41),
//                                                             shape:
//                                                                 RoundedRectangleBorder(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           10.0),
//                                                             )),
//                                                     child: Icon(
//                                                       Icons.arrow_forward_ios,
//                                                       size: 20,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                           childCount: questions.length,
//                         ),
//                       ),
//                       SliverToBoxAdapter(
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(20),
//                             child: Container(
//                               height: 25,
//                               color: Colors.transparent,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: const [
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 10),
//                                     child: Row(
//                                       children: [
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [],
//                                         ),
//                                         SizedBox(
//                                           width: 70,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             )
//           : Nointernet();
//     });
//   }

//   Future<void> deleteOldQuestions() async {
//     try {
//       final currentTime = DateTime.now();
//       final thresholdTime = currentTime.subtract(Duration(hours: 48));

//       final QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection(currentAdmin!.org)
//           .doc(currentAdmin!.city)
//           .collection('questions')
//           .where('createdAt', isLessThan: thresholdTime)
//           .get();

//       for (final DocumentSnapshot doc in snapshot.docs) {
//         // Delete the document
//         await doc.reference.delete();
//       }

//       print('Old documents deleted successfully.');
//     } catch (e) {
//       print('Error deleting old documents: $e');
//     }
//   }

//   Future<void> fetchUserData() async {
//     AuthService authService = AuthService(context);
//     MyAppAdmins? adminData = (await authService.getCurrentAdmin());
//     setState(() {
//       currentAdmin = adminData;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 1));
//     SeendUpdate(context);
//     Timer.periodic(Duration(hours: 24), (Timer timer) {
//       deleteOldQuestions();
//     });
//     fetchUserData();
//   }
// }
