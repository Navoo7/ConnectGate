// ignore_for_file: unused_import, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, duplicate_ignore, unused_local_variable, prefer_const_declarations, deprecated_member_use, non_constant_identifier_names, avoid_print, must_be_immutable, depend_on_referenced_packages

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Screen/User_Side/User_Main_Screen.dart';
import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/MyImages.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAdmin extends StatefulWidget {
  const AboutAdmin({super.key});

  @override
  State<AboutAdmin> createState() => _AboutAdminState();
}

class _AboutAdminState extends State<AboutAdmin> {
  var navid = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      return modle.isonline
          ? GestureDetector(
              child: Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserMainScreen(),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      right: 10,
                                      left: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          MyImage.connectGate2,
                                          scale: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 30, right: 15),
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // launch(
                                            //     'https://www.linkedin.com/in/navid-h-a2775b20a');
                                          },
                                          child: Container(
                                            width: 75.0,
                                            height: 75.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.black87,
                                                width: 3.0,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.white,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  50)),
                                                      image: navid != ''
                                                          ? DecorationImage(
                                                              image:
                                                                  NetworkImage(
                                                                      navid),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : null),
                                                )),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 11,
                                        ),
                                        Text(
                                          'Farhad H. Ali'.tr,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontFamily: 'NRT',
                                              letterSpacing: ln2,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          'Founder',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(
                                          height: 1,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            // launch(
                                            //     'https://www.linkedin.com/in/navid-h-a2775b20a');
                                          },
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            child:
                                                Image.asset(MyImage.linkedin),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 125, left: 5),
                                child: Divider(
                                  color: Colors.black,
                                  thickness: 1.4,
                                ),
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 15, top: 25),
                                child: Text(
                                  "At ConnectGate, we're on a mission to connect the world through the power of knowledge. Our platform serves as the meeting point for both qualitative and quantitative researchers, fostering a community of curious minds and insightful thinkers.We believe in the transformative potential of questions and answers. Through our app, researchers, experts, and enthusiasts from various fields come together to explore, exchange, and uncover new perspectives.Whether you're delving into the depths of qualitative research or diving into the numbers of quantitative analysis, ConnectGate is your trusted companion. Join us in the pursuit of understanding, where every question has the potential to spark a connection, and every answer can illuminate the path forward.Together, we're shaping a world of knowledge, one query at a time.",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      height: 1.4,
                                      fontFamily: 'ageo',
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              ////////////////////////////////
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 45, left: 20, bottom: 30),
                            child: Stack(
                              children: [
                                Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 11, left: 220),
                                  child: Text(
                                    'Our social media:'.tr,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 12, left: 28),
                                  child: InkWell(
                                      // onTap: () {
                                      //   launch(
                                      //       'https://www.instagram.com/navoo_7/');
                                      // },
                                      child: Container(
                                          width: 18,
                                          height: 18,
                                          child:
                                              Image.asset(MyImage.instagram))),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 12, left: 5),
                                  child: InkWell(
                                      // onTap: () {
                                      //   launch(
                                      //       'https://web.facebook.com/navedbarwary');
                                      // },
                                      child: Container(
                                          width: 16,
                                          height: 16,
                                          child:
                                              Image.asset(MyImage.facebook))),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 12, left: 49),
                                  child: InkWell(
                                      // onTap: () {
                                      //   launch(
                                      //       'https://www.snapchat.com/add/navoo-hushyar');
                                      // },
                                      child: Container(
                                          width: 18,
                                          height: 18,
                                          child:
                                              Image.asset(MyImage.snapchat))),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Nointernet();
    });
  }

  getdata() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('About')
          .doc('Developer')
          .get();
      if (doc.exists) {
        setState(() {
          navid = doc.data()?['navid'] ??
              ''; // Default to empty string if 'navid' is not found
          print("Navid URL: $navid"); // Debugging line
        });
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1400));

    getdata();
    // SeendUpdate(context);
    super.initState();
  }
}

// // ignore_for_file: unused_import, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, duplicate_ignore, unused_local_variable, prefer_const_declarations, deprecated_member_use, non_constant_identifier_names, avoid_print, must_be_immutable, depend_on_referenced_packages

// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/Screen/Admin_Side/Admin_Main_Screen.dart';
// import 'package:connectgate/core/CeckForUpdate.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/MyImages.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class AboutAdminAdmin extends StatefulWidget {
//   const AboutAdminAdmin({super.key});

//   @override
//   State<AboutAdminAdmin> createState() => _AboutAdminAdminState();
// }

// class _AboutAdminAdminState extends State<AboutAdminAdmin> {
//   var navid = "";

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<connectivitycheck>(builder: (context, modle, child) {
//       return modle.isonline
//           ? GestureDetector(
//               child: Scaffold(
//                 body: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       top: 10,
//                       left: 20,
//                     ),
//                     child: Stack(
//                       children: [
//                         SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 15),
//                                 child: Align(
//                                   alignment: Alignment.topLeft,
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               AdminMainScreen(),
//                                         ),
//                                       );
//                                     },
//                                     child: const Icon(
//                                       Icons.arrow_back,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                       top: 5,
//                                       right: 10,
//                                       left: 75,
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Image.asset(
//                                           MyImage.connectGate2,
//                                           scale: 1.2,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.only(top: 100, right: 20),
//                                     child: Column(
//                                       children: [
//                                         // GestureDetector(
//                                         //   onTap: () {
//                                         //     launch(
//                                         //         'https://www.linkedin.com/in/navid-h-a2775b20a');
//                                         //   },
//                                         //   child: Container(
//                                         //     width: 95.0,
//                                         //     height: 95.0,
//                                         //     decoration: BoxDecoration(
//                                         //       shape: BoxShape.circle,
//                                         //       border: Border.all(
//                                         //         color: Colors.black87,
//                                         //         width: 3.0,
//                                         //       ),
//                                         //     ),
//                                         //     child: CircleAvatar(
//                                         //         radius: 50,
//                                         //         backgroundColor: Colors.white,
//                                         //         child: Container(
//                                         //           decoration: BoxDecoration(
//                                         //             borderRadius:
//                                         //                 const BorderRadius.all(
//                                         //                     Radius.circular(
//                                         //                         50)),
//                                         //             image: DecorationImage(
//                                         //               image:
//                                         //                   NetworkImage(navid),
//                                         //               fit: BoxFit.cover,
//                                         //             ),
//                                         //           ),
//                                         //         )),
//                                         //   ),
//                                         // ),
//                                         // SizedBox(
//                                         //   height: 4,
//                                         // ),
//                                         // Text(
//                                         //   'Navid Hishyar Hassan'.tr,
//                                         //   style: TextStyle(
//                                         //       color: Colors.black,
//                                         //       fontSize: 10,
//                                         //       fontFamily: 'NRT',
//                                         //       letterSpacing: ln2,
//                                         //       fontWeight: FontWeight.w600),
//                                         // ),
//                                         // // Text(
//                                         // //   'Developer',
//                                         // //   style: TextStyle(
//                                         // //       color: Colors.black,
//                                         // //       fontSize: 14,
//                                         // //       fontWeight: FontWeight.w400),
//                                         // // ),
//                                         // SizedBox(
//                                         //   height: 4,
//                                         // ),
//                                         // InkWell(
//                                         //     onTap: () {
//                                         //       launch(
//                                         //           'https://www.linkedin.com/in/navid-h-a2775b20a');
//                                         //     },
//                                         //     child: Container(
//                                         //         width: 12,
//                                         //         height: 12,
//                                         //         child: Image.asset(
//                                         //             MyImage.linkedin))),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const Padding(
//                                 padding: EdgeInsets.only(right: 90, left: 75),
//                                 child: Divider(
//                                   color: Colors.black,
//                                   thickness: 1.4,
//                                 ),
//                               ),

//                               Padding(
//                                 padding:
//                                     const EdgeInsets.only(right: 15, top: 25),
//                                 child: Text(
//                                   "At ConnectGate, we're on a mission to connect the world through the power of knowledge. Our platform serves as the meeting point for both qualitative and quantitative researchers, fostering a community of curious minds and insightful thinkers.We believe in the transformative potential of questions and answers. Through our app, researchers, experts, and enthusiasts from various fields come together to explore, exchange, and uncover new perspectives.Whether you're delving into the depths of qualitative research or diving into the numbers of quantitative analysis, ConnectGate is your trusted companion. Join us in the pursuit of understanding, where every question has the potential to spark a connection, and every answer can illuminate the path forward.Together, we're shaping a world of knowledge, one query at a time.",
//                                   textAlign: TextAlign.justify,
//                                   style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 15,
//                                       height: 1.4,
//                                       fontFamily: 'ageo',
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),

//                               ////////////////////////////////
//                             ],
//                           ),
//                         ),
//                         Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                                 right: 45, left: 20, bottom: 30),
//                             child: Stack(
//                               children: [
//                                 Divider(
//                                   color: Colors.black,
//                                   thickness: 1,
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(top: 14, left: 240),
//                                   child: Text(
//                                     'Our social media:'.tr,
//                                     style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 10,
//                                         fontFamily: 'NRT',
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(top: 12, left: 28),
//                                   child: InkWell(
//                                       // onTap: () {
//                                       //   launch(
//                                       //       'https://www.instagram.com/navoo_7/');
//                                       // },
//                                       child: Container(
//                                           width: 18,
//                                           height: 18,
//                                           child:
//                                               Image.asset(MyImage.instagram))),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(top: 12, left: 5),
//                                   child: InkWell(
//                                       // onTap: () {
//                                       //   launch(
//                                       //       'https://web.facebook.com/navedbarwary');
//                                       // },
//                                       child: Container(
//                                           width: 16,
//                                           height: 16,
//                                           child:
//                                               Image.asset(MyImage.facebook))),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(top: 12, left: 49),
//                                   child: InkWell(
//                                       // onTap: () {
//                                       //   launch(
//                                       //       'https://www.snapchat.com/add/navoo-hushyar');
//                                       // },
//                                       child: Container(
//                                           width: 18,
//                                           height: 18,
//                                           child:
//                                               Image.asset(MyImage.snapchat))),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           : Nointernet();
//     });
//   }

//   getdata() {
//     FirebaseFirestore.instance
//         .collection('AboutAdmin')
//         .doc('Developer')
//         .get()
//         .then((value) {
//       setState(() {
//         navid = value.data()!['navid'];
//       });
//     });
//   }

//   @override
//   void initState() {
//     // SeendUpdate(context);
//     Future.delayed(const Duration(seconds: 1));
//     getdata();
//     super.initState();
//   }
// }
