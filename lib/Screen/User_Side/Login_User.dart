// ignore_for_file: file_names, unnecessary_new, non_constant_identifier_names, unused_local_variable, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, depend_on_referenced_packages, unused_label

import 'package:connectgate/Screen/Admin_Side/Login_Admin.dart';
import 'package:connectgate/Screen/User_Side/User_Main_Screen.dart';
import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/MyImages.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  bool showpass = true;
  bool isLoading = false; // Loading state
  final TextEditingController _emailControler = TextEditingController();
  final TextEditingController _passwordControler = TextEditingController();
  bool pass_error = false;
  bool pass_error_lenght = false;
  bool email_error = false;

  final _formKey = GlobalKey<FormState>();
  MyAppUser? currentUser;

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      if (modle.isonline != null) {
        return modle.isonline
            ? Form(
                key: _formKey,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height,
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                        width: double.infinity,
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 1,
                                            top: 45,
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginAdmin()));
                                            },
                                            icon: Image.asset(
                                              MyImage.headlight,
                                              width: 40,
                                              height: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(1),
                                        topRight: Radius.circular(500),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 125,
                                          width: double.infinity,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 21,
                                          ),
                                          child: Image.asset(
                                            'assets/images/connectGate2.png',
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 22,
                                          width: double.infinity,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Text(
                                            'Unlock valuable insights and connect with\nresearchers and participants worldwide'
                                                .tr,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'NRT',
                                                letterSpacing: 0.5),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 90,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                          ),
                                          child: TextField(
                                            controller: _emailControler,
                                            cursorColor: Colors.black,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.all(0),
                                              labelText: 'email'.tr,
                                              hintText:
                                                  'Enter Your Email here'.tr,
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
                                                Icons.person,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 183, 183, 183),
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              floatingLabelStyle:
                                                  const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                          child: Visibility(
                                              visible: email_error,
                                              child: Text(
                                                "Email is required. Please enter your Email"
                                                    .tr,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 10),
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                          width: double.infinity,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22),
                                          child: TextField(
                                            maxLength: 15,
                                            controller: _passwordControler,
                                            cursorColor: Colors.black,
                                            obscureText: showpass,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.all(0.0),
                                              labelText: 'password'.tr,
                                              hintText:
                                                  "Enter Your Password here".tr,
                                              hintStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0,
                                              ),
                                              labelStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.key,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    showpass = !showpass;
                                                  });
                                                },
                                                icon: showpass
                                                    ? const Icon(
                                                        Icons.visibility)
                                                    : const Icon(
                                                        Icons.visibility_off),
                                                color: Colors.black,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 183, 183, 183),
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              floatingLabelStyle:
                                                  const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18.0,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Center(
                                          child: Visibility(
                                              visible: pass_error,
                                              child: Text(
                                                "Password is required. Please enter your password"
                                                    .tr,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 10),
                                              )),
                                        ),
                                        Center(
                                          child: Visibility(
                                              visible: pass_error_lenght,
                                              child: Text(
                                                "Minimum password length is 8 characters. Please enter a valid password"
                                                    .tr,
                                                style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 10),
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                          width: double.infinity,
                                        ),
                                        Center(
                                          child: SizedBox(
                                            height: 47,
                                            width: 260,
                                            child: ElevatedButton(
                                              // onPressed: isLoading
                                              //     ? null // Disable button when loading
                                              //     : () async {
                                              //         setState(() {
                                              //           email_error =
                                              //               _emailControler
                                              //                   .text.isEmpty;
                                              //           pass_error =
                                              //               _passwordControler
                                              //                   .text.isEmpty;
                                              //           pass_error_lenght =
                                              //               _passwordControler
                                              //                       .text
                                              //                       .length <
                                              //                   8;
                                              //         });

                                              //         if (_emailControler
                                              //                 .text.isEmpty ||
                                              //             _passwordControler
                                              //                 .text.isEmpty) {
                                              //           _showAlertDialog();
                                              //         } else if (_passwordControler
                                              //                 .text.length <
                                              //             8) {
                                              //           pass_error_lenght =
                                              //               true;
                                              //         } else {
                                              //           setState(() {
                                              //             isLoading =
                                              //                 true; // Start loading
                                              //           });

                                              //           try {
                                              //             AuthService
                                              //                 authService =
                                              //                 AuthService(
                                              //                     context);
                                              //             MyAppUser? user =
                                              //                 await authService
                                              //                     .signInUser(
                                              //               email:
                                              //                   _emailControler
                                              //                       .text
                                              //                       .trim(),
                                              //               password:
                                              //                   _passwordControler
                                              //                       .text
                                              //                       .trim(),
                                              //             );

                                              //             if (user != null) {
                                              //               setState(() {
                                              //                 currentUser =
                                              //                     user;
                                              //               });

                                              //               Navigator
                                              //                   .pushAndRemoveUntil(
                                              //                 context,
                                              //                 MaterialPageRoute(
                                              //                   builder:
                                              //                       (context) =>
                                              //                           const UserMainScreen(),
                                              //                 ),
                                              //                 (route) => false,
                                              //               );
                                              //             } else {
                                              //               _showSnackBar(
                                              //                   "Login failed. Please check your credentials.");
                                              //             }
                                              //           } catch (e) {
                                              //             print(
                                              //                 "Error during login: $e");
                                              //             _showSnackBar(
                                              //                 "An error occurred. Please try again.");
                                              //           } finally {
                                              //             setState(() {
                                              //               isLoading =
                                              //                   false; // Stop loading
                                              //             });
                                              //           }
                                              //         }
                                              //       },
                                              onPressed: isLoading
                                                  ? null
                                                  : () async {
                                                      setState(() {
                                                        email_error =
                                                            _emailControler
                                                                .text.isEmpty;
                                                        pass_error =
                                                            _passwordControler
                                                                .text.isEmpty;
                                                        pass_error_lenght =
                                                            _passwordControler
                                                                    .text
                                                                    .length <
                                                                8;
                                                      });

                                                      if (_emailControler
                                                              .text.isEmpty ||
                                                          _passwordControler
                                                              .text.isEmpty) {
                                                        _showAlertDialog();
                                                      } else if (_passwordControler
                                                              .text.length <
                                                          8) {
                                                        pass_error_lenght =
                                                            true;
                                                      } else {
                                                        setState(() {
                                                          isLoading = true;
                                                        });

                                                        try {
                                                          AuthService
                                                              authService =
                                                              AuthService(
                                                                  context);
                                                          MyAppUser? user =
                                                              await authService
                                                                  .signInUser(
                                                            email:
                                                                _emailControler
                                                                    .text
                                                                    .trim(),
                                                            password:
                                                                _passwordControler
                                                                    .text
                                                                    .trim(),
                                                          );

                                                          if (user != null &&
                                                              mounted) {
                                                            // Check if widget is still mounted
                                                            Navigator
                                                                .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const UserMainScreen(),
                                                              ),
                                                              (route) => false,
                                                            );
                                                          } else {
                                                            _showSnackBar(
                                                                "Login failed. Please check your credentials.");
                                                          }
                                                        } catch (e) {
                                                          print(
                                                              "Error during login: $e");
                                                          _showSnackBar(
                                                              "An error occurred. Please try again.");
                                                        } finally {
                                                          if (mounted) {
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          }
                                                        }
                                                      }
                                                    },

                                              style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 0, 0, 0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  )),
                                              child: isLoading
                                                  ? SizedBox(
                                                      height: 22,
                                                      width: 22,
                                                      child:
                                                          const CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 1.5,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Login".tr,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "By continuing, you agree to our "
                                                      .tr,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    launch(
                                                        "https://sites.google.com/view/connectgate-termsandconditions/home");
                                                  },
                                                  child: Text(
                                                    "Terms and Conditions".tr,
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                Text(
                                                  " and ".tr,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    launch(
                                                        "https://sites.google.com/view/privacy-policy-connectgate/home");
                                                  },
                                                  child: Text(
                                                    "Privacy Policy".tr,
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 10),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Nointernet();
      }
      return Container(
        width: 100,
        height: 100,
        color: Colors.red,
      );
    });
  }

  @override
  void dispose() {
    _emailControler.dispose();
    _passwordControler.dispose();
    super.dispose();
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
        builder: (context) => CupertinoAlertDialog(
              title: Text("Error".tr),
              content: Text("Please fill in the required fields".tr),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
        context: context);
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}









































































































































































































































































































































































































// // ignore_for_file: file_names, unnecessary_new, non_constant_identifier_names, unused_local_variable, avoid_print, use_build_context_synchronously, unnecessary_null_comparison, depend_on_referenced_packages, unused_label

// import 'dart:math';

// import 'package:connectgate/Screen/Admin_Side/Login_Admin.dart';
// import 'package:connectgate/Screen/User_Side/User_Main_Screen.dart';
// import 'package:connectgate/Services/auth_services.dart';
// // import 'package:connectgate/core/CeckForUpdate.dart';
// import 'package:connectgate/core/Check%20internet.dart';
// import 'package:connectgate/core/MyImages.dart';
// import 'package:connectgate/core/NoInternet.dart';
// import 'package:connectgate/models/user_model.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LoginUser extends StatefulWidget {
//   const LoginUser({super.key});

//   @override
//   State<LoginUser> createState() => _LoginUserState();
// }

// class _LoginUserState extends State<LoginUser> {
//   bool showpass = true;
  
//   final TextEditingController _emailControler = TextEditingController();
//   final TextEditingController _passwordControler = TextEditingController();
//   bool pass_error = false;
//   bool pass_error_lenght = false;
//   bool email_error = false;

//   final _formKey = GlobalKey<FormState>();
//   MyAppUser? currentUser;
//   // @override
//   // void initState() {
//   //   SeendUpdate(context);
//   //   super.initState();
//   // }

//   @override
//   void dispose() {
//     _emailControler.dispose();
//     _passwordControler.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<connectivitycheck>(builder: (context, modle, child) {
//       if (modle.isonline != null) {
//         return modle.isonline
//             ? Form(
//                 key: _formKey,
//                 child: Scaffold(
//                   backgroundColor: Colors.white,
//                   body: GestureDetector(
//                     onTap: () {
//                       FocusScope.of(context).requestFocus(new FocusNode());
//                     },
//                     child: SingleChildScrollView(
//                       // reverse: true,
//                       child: Column(
//                         children: [
//                           Container(
//                             constraints: BoxConstraints(
//                               maxHeight: MediaQuery.of(context).size.height,
//                               maxWidth: MediaQuery.of(context).size.width,
//                             ),
//                             decoration: const BoxDecoration(
//                               color: Colors.black,
//                             ),
//                             child: Column(
//                               children: [
//                                 Expanded(
//                                   flex: 1,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const SizedBox(
//                                         height: 10,
//                                         width: double.infinity,
//                                       ),
//                                       Align(
//                                         alignment: Alignment.topRight,
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                             left: 1,
//                                             top: 45,
//                                           ),
//                                           child: IconButton(
//                                             onPressed: () {
//                                               Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           const LoginAdmin()));
//                                             },
//                                             icon: Image.asset(
//                                               MyImage.headlight,
//                                               width: 40,
//                                               height: 40,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 5,
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(1),
//                                         topRight: Radius.circular(500),
//                                       ),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const SizedBox(
//                                           height: 125,
//                                           width: double.infinity,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                             left: 21,
//                                           ),
//                                           child: Image.asset(
//                                             'assets/images/connectGate2.png',
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 22,
//                                           width: double.infinity,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 24),
//                                           child: Text(
//                                             'Unlock valuable insights and connect with\nresearchers and participants worldwide'
//                                                 .tr,
//                                             style: const TextStyle(
//                                                 fontSize: 13,
//                                                 fontFamily: 'NRT',
//                                                 letterSpacing: ln2),
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 90,
//                                         ),
//                                         ////////////////// TextFormField
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 22,
//                                           ),
//                                           child: TextField(
//                                             controller: _emailControler,
//                                             cursorColor: Colors.black,
//                                             decoration: InputDecoration(
//                                               contentPadding:
//                                                   const EdgeInsets.all(0),
//                                               labelText: 'email'.tr,
//                                               hintText:
//                                                   'Enter Your Email here'.tr,
//                                               labelStyle: const TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 14.0,
//                                                 fontWeight: FontWeight.w400,
//                                               ),
//                                               hintStyle: const TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 14.0,
//                                               ),
//                                               prefixIcon: const Icon(
//                                                 Icons.person,
//                                                 color: Colors.black,
//                                                 size: 18,
//                                               ),
//                                               enabledBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                     color: Color.fromARGB(
//                                                         255, 183, 183, 183),
//                                                     width: 2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(10.0),
//                                               ),
//                                               floatingLabelStyle:
//                                                   const TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 18.0,
//                                               ),
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                     color: Colors.black,
//                                                     width: 1.5),
//                                                 borderRadius:
//                                                     BorderRadius.circular(10.0),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 10,
//                                         ),
//                                         Center(
//                                           child: Visibility(
//                                               visible: email_error,
//                                               child: Text(
//                                                 "Email is required Please enter your Email"
//                                                     .tr,
//                                                 style: const TextStyle(
//                                                     color: Colors.red,
//                                                     fontSize: 10),
//                                               )),
//                                         ),
//                                         const SizedBox(
//                                           height: 20,
//                                           width: double.infinity,
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 22),
//                                           child: TextField(
//                                             maxLength: 15,
//                                             controller: _passwordControler,
//                                             cursorColor: Colors.black,
//                                             obscureText: showpass,
//                                             decoration: InputDecoration(
//                                               contentPadding:
//                                                   const EdgeInsets.all(0.0),
//                                               labelText: 'password'.tr,
//                                               hintText:
//                                                   "Enter Your Password here".tr,
//                                               hintStyle: const TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 14.0,
//                                               ),
//                                               labelStyle: const TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 14.0,
//                                                 fontWeight: FontWeight.w400,
//                                               ),
//                                               prefixIcon: const Icon(
//                                                 Icons.key,
//                                                 color: Colors.black,
//                                                 size: 18,
//                                               ),
//                                               suffixIcon: IconButton(
//                                                 onPressed: () {
//                                                   setState(() {
//                                                     showpass = !showpass;
//                                                   });
//                                                 },
//                                                 icon: showpass
//                                                     ? const Icon(
//                                                         Icons.visibility)
//                                                     : const Icon(
//                                                         Icons.visibility_off),
//                                                 color: showpass
//                                                     ? Colors.black
//                                                     : Colors.black,
//                                               ),
//                                               enabledBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                     color: Color.fromARGB(
//                                                         255, 183, 183, 183),
//                                                     width: 2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(10.0),
//                                               ),
//                                               floatingLabelStyle:
//                                                   const TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 18.0,
//                                               ),
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                     color: Colors.black,
//                                                     width: 1.5),
//                                                 borderRadius:
//                                                     BorderRadius.circular(10.0),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 5,
//                                         ),
//                                         Center(
//                                           child: Visibility(
//                                               visible: pass_error,
//                                               child: Text(
//                                                 "password  is required Please enter your password"
//                                                     .tr,
//                                                 style: const TextStyle(
//                                                     color: Colors.red,
//                                                     fontSize: 10),
//                                               )),
//                                         ),
//                                         Center(
//                                           child: Visibility(
//                                               visible: pass_error_lenght,
//                                               child: Text(
//                                                 "Minimum password length is 8 characters. Please enter a valid password"
//                                                     .tr,
//                                                 style: const TextStyle(
//                                                     color: Colors.red,
//                                                     fontSize: 10),
//                                               )),
//                                         ),
//                                         const SizedBox(
//                                           height: 20,
//                                           width: double.infinity,
//                                         ),

//                                         Center(
//                                           child: SizedBox(
//                                             height: 47,
//                                             width: 260,
//                                             child: ElevatedButton(
//                                               onPressed: () async {
//                                                 setState(() {
//                                                   email_error = _emailControler
//                                                       .text.isEmpty;
//                                                   pass_error =
//                                                       _passwordControler
//                                                           .text.isEmpty;
//                                                   pass_error_lenght =
//                                                       _passwordControler
//                                                               .text.length <
//                                                           8;
//                                                 });

//                                                 if (_emailControler
//                                                         .text.isEmpty ||
//                                                     _passwordControler
//                                                         .text.isEmpty) {
//                                                   _showAlertDialog();
//                                                 } else if (_passwordControler
//                                                         .text.length <
//                                                     8) {
//                                                   pass_error_lenght = true;
//                                                 } else {
//                                                   // Perform the admin login
//                                                   AuthService authService =
//                                                       AuthService(context);
//                                                   MyAppUser? user =
//                                                       await authService
//                                                           .signInUser(
//                                                     email: _emailControler.text
//                                                         .trim(),
//                                                     password: _passwordControler
//                                                         .text
//                                                         .trim(),
//                                                   );

//                                                   if (user != null) {
//                                                     setState(() {
//                                                       currentUser = user;
//                                                     });

//                                                     // Redirect to admin main screen if login is successful
//                                                     Navigator
//                                                         .pushAndRemoveUntil(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             const UserMainScreen(),
//                                                       ),
//                                                       (route) => true,
//                                                     );
//                                                   }
//                                                 }
//                                               },
//                                               // ... The rest of the code for the ElevatedButton ...

//                                               style: ElevatedButton.styleFrom(
//                                                   foregroundColor: Colors.white,
//                                                   backgroundColor:
//                                                       const Color.fromARGB(
//                                                           255, 0, 0, 0),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10.0),
//                                                   )),
//                                               child: Text(
//                                                 "Login".tr,
//                                                 style: const TextStyle(
//                                                     color: Colors.white),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 20),
//                                         Column(
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Text(
//                                                   "By continuing, you agree to our "
//                                                       .tr,
//                                                   style: TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 10),
//                                                 ),
//                                               ],
//                                             ),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 GestureDetector(
//                                                   onTap: () {
//                                                     launch(
//                                                         "https://sites.google.com/view/connectgate-termsandconditions/home");
//                                                   },
//                                                   child: Text(
//                                                     "Terms and Conditions".tr,
//                                                     style: TextStyle(
//                                                         color: Colors.blue,
//                                                         fontSize: 10),
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   " and ".tr,
//                                                   style: TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 10),
//                                                 ),
//                                                 GestureDetector(
//                                                   onTap: () {
//                                                     launch(
//                                                         "https://sites.google.com/view/privacy-policy-connectgate/home");
//                                                   },
//                                                   child: Text(
//                                                     "Privacy Policy".tr,
//                                                     style: TextStyle(
//                                                         color: Colors.blue,
//                                                         fontSize: 10),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             : Nointernet();
//       }
//       return Container(
//         width: 100,
//         height: 100,
//         color: Colors.red,
//       );
//     });
//   }

//   Future<void> _showAlertDialog() async {
//     return showDialog<void>(
//         builder: (context) => CupertinoAlertDialog(
//               title: Text("Error".tr),
//               // ignore: prefer_const_constructors
//               content: new Text("Please fill in the required fields".tr),
//               actions: <Widget>[
//                 CupertinoDialogAction(
//                   child: const Text("OK"),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//         context: context);
//   }
// }
