// ignore_for_file: unnecessary_new, file_names, unused_local_variable, prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Screen/User_Side/see_users_answers.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class OpenQPage extends StatefulWidget {
  final Map<String, dynamic> questionData;

  OpenQPage({
    super.key,
    required this.questionData,
  });
  @override
  State<OpenQPage> createState() => _OpenQPageState();
}

class _OpenQPageState extends State<OpenQPage> {
  TextEditingController answerController = TextEditingController();
  MyAppUser? currentUser;
  bool isLoading = false;
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final questionData = widget.questionData;

    final groupname = questionData['groupname'] as String;
    final title = questionData['title'] as String;
    final timestamp = questionData['createdAt'] as Timestamp;
    final questionitself = questionData['question'] as String;
    final questiontype = questionData['type'] as String;
    final imageUrl = questionData['imageUrl'] as String?; // Nullable imageUrl
    final options = questionData['options'] as List<dynamic>;

    return Consumer<connectivitycheck>(builder: (context, model, child) {
      if (model.isonline != null) {
        return model.isonline
            ? Scaffold(
                backgroundColor: Colors.white,
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(
                      new FocusNode(),
                    );
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(50),
                                    bottomRight: Radius.circular(50),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 60, left: 22, right: 20, bottom: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  Navigator.pop(context),
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
                                      const SizedBox(height: 15),
                                      const Center(
                                        child: Icon(
                                          Icons.message,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Center(
                                        child: Text(
                                          questionitself,
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'NRT',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      // // // Replace your existing image display code in the FlexibleSpaceBar background:
                                      if (imageUrl != null &&
                                          imageUrl.isNotEmpty)
                                        RepaintBoundary(
                                          key: _globalKey,
                                          child: PinchZoom(
                                            maxScale: 10.0,
                                            child: Container(
                                              height: 200,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl ?? '',
                                                fit: BoxFit.cover,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ).paddingSymmetric(vertical: 8),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // White spot
                        const SizedBox(height: 20),

                        // Conditional rendering based on questiontype
                        if (questiontype == 'MultipleChoice') ...[
                          // Render buttons for multiple choice
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: options.map<Widget>((option) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 35, vertical: 8),
                                  child: SizedBox(
                                    height: 47,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              final answer =
                                                  answerController.text;
                                              if (answer.isNotEmpty) {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                              }
                                              await saveAnswer(option);
                                              final questionData = {
                                                'title': title,
                                                'createdAt': timestamp,
                                                'question': questionitself,
                                                'type': questiontype,
                                                'options': options,
                                                'groupname': groupname,
                                              };

                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SeeAnswersUser(
                                                    questionData: questionData,
                                                  ),
                                                ),
                                              );
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 45,
                                        shadowColor: Colors.grey,
                                        backgroundColor:
                                            Color.fromARGB(255, 20, 20, 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(60.0),
                                        ),
                                      ),
                                      child: isLoading
                                          ? CircularProgressIndicator(
                                              color: Colors.white)
                                          : Text(
                                              option,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'NRT',
                                                  fontSize: 16),
                                            ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ] else if (questiontype == 'Regular') ...[
                          // Render text field for regular
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: answerController,
                              textInputAction: TextInputAction.done,
                              minLines: 1,
                              maxLines: 8,
                              maxLength: 280,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelText: 'Message',
                                hintText: 'Enter Message Here',
                                labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                                prefixIcon: const Icon(
                                  Icons.question_answer,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 183, 183, 183),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: 47,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        final answer = answerController.text;
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (answer.isNotEmpty) {
                                          await saveAnswer(answer);
                                          answerController.clear();
                                          final questionData = {
                                            'title': title,
                                            'createdAt': timestamp,
                                            'question': questionitself,
                                            'type': questiontype,
                                            'options': options,
                                            'groupname': groupname,
                                          };
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SeeAnswersUser(
                                                questionData: questionData,
                                              ),
                                            ),
                                          );
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Send',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              )
            : Nointernet();
      }
      return CircularProgressIndicator(
        color: Colors.black,
      );
    });
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    AuthService authService = AuthService(context);
    MyAppUser? userData = (await authService.getCurrentUser());
    setState(() {
      currentUser = userData;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> saveAnswer(String answer) async {
    AuthService authService = AuthService(context);
    MyAppUser? userData = (await authService.getCurrentUser());

    if (userData != null) {
      final Map<String, dynamic> answerData = {
        'title': widget.questionData['title'],
        'question': widget.questionData['question'],
        'type': widget.questionData['type'],
        'group': widget.questionData['groupname'],
        'user_name': userData.name,
        'user_email': userData.email,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection(currentUser!.org)
            .doc(currentUser!.city)
            .collection('answers')
            .add(answerData);
      } catch (e) {
        print('Error saving answer: $e');
      }
    }
  }
}








































































































































































































































































































// // ignore_for_file: unnecessary_new, file_names, unused_local_variable, prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, depend_on_referenced_packages

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Screen/User_Side/see_users_answers.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/user_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pinch_zoom/pinch_zoom.dart';
// import 'package:provider/provider.dart';

// class OpenQPage extends StatefulWidget {
//   final Map<String, dynamic> questionData;

//   OpenQPage({
//     super.key,
//     required this.questionData,
//   });
//   @override
//   State<OpenQPage> createState() => _OpenQPageState();
// }

// class _OpenQPageState extends State<OpenQPage> {
//   TextEditingController answerController =
//       TextEditingController(); // Controller for the answer
//   MyAppUser? currentUser;
//   bool isLoading = false;
//   final GlobalKey _globalKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     final questionData = widget.questionData;

//     final groupname = questionData['groupname'] as String;
//     final title = questionData['title'] as String;
//     final timestamp = questionData['createdAt'] as Timestamp;
//     final questionitself = questionData['question'] as String;
//     final questiontype = questionData['type'] as String;
//     final imageUrl =
//         questionData['imageUrl'] as String?; // Image URL for question
//     final options =
//         questionData['options'] as List<dynamic>; // Cast options as a List

//     return Consumer<connectivitycheck>(builder: (context, modle, child) {
//       if (modle.isonline != null) {
//         return modle.isonline
//             ? Scaffold(
//                 backgroundColor: Colors.white,
//                 body: GestureDetector(
//                   onTap: () {
//                     FocusScope.of(context).requestFocus(
//                       new FocusNode(),
//                     );
//                   },
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               height: 400,
//                               constraints: BoxConstraints(
//                                 maxHeight: MediaQuery.of(context).size.height,
//                                 maxWidth: MediaQuery.of(context).size.width,
//                               ),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(50),
//                                   bottomRight: Radius.circular(50),
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                     top: 60, left: 22, right: 20),
//                                 child: Wrap(
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Align(
//                                               alignment: Alignment.topLeft,
//                                               child: GestureDetector(
//                                                 onTap: () =>
//                                                     Navigator.pop(context),
//                                                 child: const Icon(
//                                                   Icons.arrow_back,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                             ),
//                                             Text(
//                                               title,
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12,
//                                                   fontFamily: 'NRT'),
//                                             )
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           height: 15,
//                                           width: double.infinity,
//                                         ),
//                                         const Center(
//                                           child: Icon(
//                                             Icons.message,
//                                             color: Colors.white,
//                                             size: 22,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 15,
//                                           width: double.infinity,
//                                         ),
//                                         Center(
//                                           child: Text(
//                                             questionitself,
//                                             softWrap: true,
//                                             overflow: TextOverflow.clip,
//                                             maxLines: 15,
//                                             textAlign: TextAlign.justify,
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 14,
//                                               fontFamily: 'NRT',
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 15),
//                                         RepaintBoundary(
//                                           key: _globalKey,
//                                           child: PinchZoom(
//                                             maxScale: 10.0,
//                                             child: Container(
//                                               height: 190,
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                                 image: DecorationImage(
//                                                   image:
//                                                       NetworkImage(imageUrl!),
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                             ).paddingSymmetric(vertical: 6),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         // White spot
//                         const SizedBox(height: 20),

//                         // Conditional rendering based on questiontype
//                         if (questiontype == 'MultipleChoice') ...[
//                           // Render buttons for multiple choice
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Column(
//                               children: options.map<Widget>((option) {
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 35, vertical: 8),
//                                   child: SizedBox(
//                                     height: 47,
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: isLoading
//                                           ? null // Disable button if loading
//                                           : () async {
//                                               final answer =
//                                                   answerController.text;
//                                               if (answer.isNotEmpty) {
//                                                 setState(() {
//                                                   isLoading =
//                                                       true; // Start loading
//                                                 });
//                                               }
//                                               await saveAnswer(option);
//                                               final questionData = {
//                                                 'title': title,
//                                                 'createdAt': timestamp,
//                                                 'question': questionitself,
//                                                 'type': questiontype,
//                                                 'options': options,
//                                                 'groupname': groupname,
//                                               };

//                                               Navigator.pushReplacement(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       SeeAnswersUser(
//                                                     questionData: questionData,
//                                                   ),
//                                                 ),
//                                               );
//                                               setState(() {
//                                                 isLoading =
//                                                     false; // Stop loading
//                                               });
//                                             },
//                                       style: ElevatedButton.styleFrom(
//                                         elevation: 45,
//                                         shadowColor: Colors.grey,
//                                         backgroundColor:
//                                             Color.fromARGB(255, 20, 20, 20),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(60.0),
//                                         ),
//                                       ),
//                                       child: isLoading
//                                           ? CircularProgressIndicator(
//                                               color: Colors.white)
//                                           : Text(
//                                               option,
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontFamily: 'NRT',
//                                                   fontSize: 16),
//                                             ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ] else if (questiontype == 'Regular') ...[
//                           // Render text field for regular
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: TextField(
//                               controller: answerController,
//                               textInputAction: TextInputAction.done,
//                               minLines: 1,
//                               maxLines: 8,
//                               maxLength: 280,
//                               cursorColor: Colors.black,
//                               decoration: InputDecoration(
//                                 labelText: 'Message',
//                                 hintText: 'Enter Message Here',
//                                 labelStyle: const TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 14.0,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 hintStyle: const TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 14.0,
//                                 ),
//                                 prefixIcon: const Icon(
//                                   Icons.question_answer,
//                                   color: Colors.black,
//                                   size: 18,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: Color.fromARGB(255, 183, 183, 183),
//                                     width: 2,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: Colors.black,
//                                     width: 1.5,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: SizedBox(
//                               height: 47,
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: isLoading
//                                     ? null
//                                     : () async {
//                                         final answer = answerController.text;
//                                         setState(() {
//                                           isLoading = true;
//                                         });
//                                         if (answer.isNotEmpty) {
//                                           await saveAnswer(answer);
//                                           answerController.clear();
//                                           final questionData = {
//                                             'title': title,
//                                             'createdAt': timestamp,
//                                             'question': questionitself,
//                                             'type': questiontype,
//                                             'options': options,
//                                             'groupname': groupname,
//                                           };
//                                           Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   SeeAnswersUser(
//                                                 questionData: questionData,
//                                               ),
//                                             ),
//                                           );
//                                           setState(() {
//                                             isLoading = false;
//                                           });
//                                         }
//                                       },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.black,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20.0),
//                                   ),
//                                 ),
//                                 child: isLoading
//                                     ? CircularProgressIndicator(
//                                         color: Colors.white)
//                                     : const Text(
//                                         'Send',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ),
//                         ]
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             : Nointernet();
//       }
//       return CircularProgressIndicator(
//         color: Colors.black,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     answerController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchUserData() async {
//     AuthService authService = AuthService(context);
//     MyAppUser? userData = (await authService.getCurrentUser());
//     setState(() {
//       currentUser = userData;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   Future<void> saveAnswer(String answer) async {
//     AuthService authService = AuthService(context);
//     MyAppUser? userData = (await authService.getCurrentUser());

//     if (userData != null) {
//       final Map<String, dynamic> answerData = {
//         'title': widget.questionData['title'],
//         'question': widget.questionData['question'],
//         'type': widget.questionData['type'],
//         'group': widget.questionData['groupname'],
//         'user_name': userData.name,
//         'user_email': userData.email,
//         'answer': answer,
//         'timestamp': FieldValue.serverTimestamp(),
//       };

//       try {
//         await FirebaseFirestore.instance
//             .collection(currentUser!.org)
//             .doc(currentUser!.city)
//             .collection('answers')
//             .add(answerData);
//       } catch (e) {
//         print('Error saving answer: $e');
//       }
//     }
//   }
// }




























































































































































































































































































































































































































































// // ignore_for_file: unnecessary_new, file_names, unused_local_variable, prefer_const_constructors_in_immutables, prefer_const_constructors, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, depend_on_referenced_packages

// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Screen/User_Side/see_users_answers.dart';
// import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/user_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class OpenQPage extends StatefulWidget {
//   final Map<String, dynamic> questionData;

//   OpenQPage({
//     super.key,
//     required this.questionData,
//   });
//   @override
//   State<OpenQPage> createState() => _OpenQPageState();
// }

// class _OpenQPageState extends State<OpenQPage> {
//   TextEditingController answerController =
//       TextEditingController(); // Controller for the answer
//   MyAppUser? currentUser;
//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     final questionData = widget.questionData;

//     final groupname = questionData['groupname'] as String;
//     final title = questionData['title'] as String;
//     final timestamp = questionData['createdAt'] as Timestamp;
//     final questionitself = questionData['question'] as String;
//     final questiontype = questionData['type'] as String;

//     final options =
//         questionData['options'] as List<dynamic>; // Cast options as a List
//     return Consumer<connectivitycheck>(builder: (context, modle, child) {
//       if (modle.isonline != null) {
//         return modle.isonline
//             ? Scaffold(
//                 backgroundColor: Colors.white,
//                 body: GestureDetector(
//                   onTap: () {
//                     FocusScope.of(context).requestFocus(
//                       new FocusNode(),
//                     );
//                   },
//                   child: SingleChildScrollView(
//                     // reverse: true,
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               height: 400,
//                               constraints: BoxConstraints(
//                                 maxHeight: MediaQuery.of(context).size.height,
//                                 maxWidth: MediaQuery.of(context).size.width,
//                               ),
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(50),
//                                   bottomRight: Radius.circular(50),
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.only(
//                                     top: 60, left: 22, right: 20),
//                                 child: Wrap(
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Align(
//                                               alignment: Alignment.topLeft,
//                                               child: GestureDetector(
//                                                 onTap: () =>
//                                                     Navigator.pop(context),
//                                                 child: const Icon(
//                                                   Icons.arrow_back,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                             ),
//                                             Text(
//                                               title,
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 12,
//                                                   fontFamily: 'NRT'),
//                                             )
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           height: 15,
//                                           width: double.infinity,
//                                         ),
//                                         const Center(
//                                           child: Icon(
//                                             Icons.message,
//                                             color: Colors.white,
//                                             size: 22,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 15,
//                                           width: double.infinity,
//                                         ),
//                                         Center(
//                                           child: Text(
//                                             questionitself,
//                                             softWrap: true,
//                                             overflow: TextOverflow.clip,
//                                             maxLines: 15,
//                                             textAlign: TextAlign.justify,
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 14,
//                                               fontFamily: 'NRT',
//                                               letterSpacing: ln2,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 15),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         //white spot
//                         const SizedBox(height: 20),

//                         // Conditional rendering based on questiontype
//                         if (questiontype == 'MultipleChoice') ...[
//                           // Render buttons for multichoose
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Column(
//                               children: options.map<Widget>((option) {
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 35, vertical: 8),
//                                   child: SizedBox(
//                                     height: 47,
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: isLoading
//                                           ? null // Disable button if loading
//                                           : () async {
//                                               final answer =
//                                                   answerController.text;
//                                               if (answer.isNotEmpty) {
//                                                 setState(() {
//                                                   isLoading =
//                                                       true; // Start loading
//                                                 });
//                                               }
//                                               saveAnswer(option);
//                                               // Optionally, you can show a confirmation message here.
//                                               final questionData = {
//                                                 'title':
//                                                     title, // Replace with the actual data you want to pass
//                                                 'createdAt':
//                                                     timestamp, // Replace with the actual data you want to pass
//                                                 // Add more fields as needed
//                                                 'question': questionitself,
//                                                 'type': questiontype,
//                                                 'options': options,
//                                                 'groupname': groupname,
//                                               };

//                                               Navigator.pushReplacement(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       SeeAnswersUser(
//                                                     questionData: questionData,
//                                                     // totalQuestions: widget.totalQuestions,
//                                                     // currentQuestionIndex:
//                                                     //     widget.currentQuestionIndex,
//                                                   ),
//                                                 ),
//                                               );
//                                               setState(() {
//                                                 isLoading =
//                                                     false; // Stop loading
//                                               });
//                                             },
//                                       style: ElevatedButton.styleFrom(
//                                         elevation: 45, // Elevation
//                                         shadowColor:
//                                             Colors.grey, // Shadow Color
//                                         // side:
//                                         //     BorderSide(width: 3.0, color: Colors.white70),
//                                         backgroundColor:
//                                             Color.fromARGB(255, 20, 20, 20),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(60.0),
//                                         ),
//                                       ),
//                                       child: isLoading
//                                           ? CircularProgressIndicator(
//                                               color: Colors
//                                                   .white) // Show loading indicator
//                                           : Text(
//                                               option,
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontFamily: 'NRT',
//                                                   fontSize: 16),
//                                             ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ] else if (questiontype == 'Regular') ...[
//                           // Render text field for regular
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: TextField(
//                               controller: answerController,
//                               textInputAction: TextInputAction
//                                   .done, // Set the appropriate action
//                               minLines: 1,
//                               maxLines: 8,
//                               maxLength: 280,
//                               cursorColor: Colors.black,
//                               decoration: InputDecoration(
//                                 labelText: 'Message',
//                                 hintText: 'Enter Message Here',
//                                 labelStyle: const TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 14.0,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 hintStyle: const TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 14.0,
//                                 ),
//                                 prefixIcon: const Icon(
//                                   Icons.question_answer,
//                                   color: Colors.black,
//                                   size: 18,
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: Color.fromARGB(255, 183, 183, 183),
//                                     width: 2,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderSide: const BorderSide(
//                                     color: Colors.black,
//                                     width: 1.5,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: SizedBox(
//                               height: 47,
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: isLoading
//                                     ? null // Disable button if loading
//                                     : () async {
//                                         final answer = answerController.text;
//                                         setState(() {
//                                           isLoading = true; // Start loading
//                                         });
//                                         if (answer.isNotEmpty) {
//                                           await saveAnswer(answer);
//                                           answerController
//                                               .clear(); // Clear the answer text field
//                                           // Optionally, you can show a confirmation message here.
//                                           final answersData = {
//                                             'title':
//                                                 title, // Replace with the actual data you want to pass
//                                             'createdAt':
//                                                 timestamp, // Replace with the actual data you want to pass
//                                             // Add more fields as needed
//                                             'question': questionitself,
//                                             'type': questiontype,
//                                             'options': options,
//                                             'groupname': groupname,
//                                           };
// // After successfully saving the answer, mark the question as answered

//                                           Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   SeeAnswersUser(
//                                                 questionData: questionData,
//                                                 // totalQuestions: widget.totalQuestions,
//                                                 // currentQuestionIndex:
//                                                 //     widget.currentQuestionIndex,
//                                               ),
//                                             ),
//                                           );
//                                           setState(() {
//                                             isLoading = false; // Stop loading
//                                           });
//                                         }
//                                       },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.black,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20.0),
//                                   ),
//                                 ),
//                                 child: isLoading
//                                     ? CircularProgressIndicator(
//                                         color: Colors
//                                             .white) // Show loading indicator
//                                     : const Text(
//                                         'Send',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                               ),
//                             ),
//                           ),
//                         ]
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             : Nointernet();
//       }
//       return CircularProgressIndicator(
//         color: Colors.black,
//       );
//     });
//   }

//   @override
//   void dispose() {
//     answerController.dispose(); // Dispose of the controller
//     super.dispose();
//   }

//   Future<void> fetchUserData() async {
//     AuthService authService = AuthService(context);
//     MyAppUser? userData = (await authService.getCurrentUser());
//     setState(() {
//       currentUser = userData;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Call the method to get the current user's data from Firestore
//     fetchUserData();
//   }

//   Future<void> saveAnswer(String answer) async {
//     //final User? user = FirebaseAuth.instance.currentUser;
//     AuthService authService = AuthService(context);
//     MyAppUser? userData = (await authService.getCurrentUser());

//     if (userData != null) {
//       final Map<String, dynamic> answerData = {
//         'title': widget.questionData['title'], // Replace with the actual title
//         'question':
//             widget.questionData['question'], // Replace with the actual question
//         'type': widget
//             .questionData['type'], // Replace with the actual question type
//         'group': widget.questionData[
//             'groupname'], //'GroupName', // Replace with the actual group name
//         'user_name': userData.name,
//         'user_email': userData.email,
//         'answer': answer,
//         'timestamp': FieldValue.serverTimestamp(),
//       };

//       try {
//         await FirebaseFirestore.instance
//             .collection(currentUser!.org)
//             .doc(currentUser!.city)
//             .collection('answers')
//             .add(answerData);
//         // Show a success message or perform any other actions as needed.
//       } catch (e) {
//         print('Error saving answer: $e');
//         // Handle the error, e.g., show an error message.
//       }
//     }
//   }
// }
