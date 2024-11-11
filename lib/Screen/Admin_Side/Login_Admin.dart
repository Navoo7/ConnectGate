// ignore_for_file: dead_code, file_names, unused_field, non_constant_identifier_names, unnecessary_new, duplicate_ignore, use_build_context_synchronously, prefer_is_not_empty, unused_element, unnecessary_null_comparison, depend_on_referenced_packages, unused_label

import 'package:connectgate/Screen/Admin_Side/Admin_Main_Screen.dart';
import 'package:connectgate/Screen/User_Side/Login_User.dart';
import 'package:connectgate/Services/auth_services.dart';
// import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/MyImages.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  bool showpass = true;
  bool isLoading = false; // Add loading state
  final TextEditingController _emailControler = TextEditingController();
  final TextEditingController _passwordControler = TextEditingController();
  bool pass_error = false;
  bool pass_error_lenght = false;
  bool email_error = false;

  final _formKey = GlobalKey<FormState>();
  MyAppAdmins? currentAdmin;
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
                      // ignore: unnecessary_new
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: SingleChildScrollView(
                      // reverse: true,
                      child: Column(
                        children: [
                          //dark spot
                          Row(
                            children: [
                              Container(
                                height: 400,
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width,
                                    maxHeight:
                                        MediaQuery.of(context).size.height),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(500),
                                    bottomRight: Radius.circular(0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 60, left: 22, right: 20),
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
                                                  Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  // ignore: prefer_const_constructors
                                                  builder: (context) =>
                                                      const LoginUser(),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 95),
                                        child: Image.asset(
                                          MyImage.managerlight,
                                          scale: 2,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                        width: double.infinity,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 144),
                                        child: Text(
                                          'Welcome to \n ConnectGate admin'.tr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'ageo-boldd',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //white spot
                          const SizedBox(
                            width: double.infinity,
                            height: 30,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'please sign in to access the'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'ageo',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                            width: double.infinity,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Admin Functionalities'.tr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'ageo-bold',
                                  //  letterSpacing: ln10
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                            width: double.infinity,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: TextField(
                              controller: _emailControler,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0),
                                labelText: 'email'.tr,
                                hintText: 'Enter Your Email here'.tr,
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
                                      color: Color.fromARGB(255, 183, 183, 183),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(10.0),
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
                                  "Email is required Please enter your Email"
                                      .tr,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                )),
                          ),
                          const SizedBox(
                            height: 20,
                            width: double.infinity,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: TextField(
                              maxLength: 15,
                              controller: _passwordControler,
                              cursorColor: Colors.black,
                              obscureText: showpass,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0.0),
                                labelText: 'password'.tr,
                                hintText: "Enter Your Password here".tr,
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
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off),
                                  color: showpass ? Colors.black : Colors.black,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 183, 183, 183),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Visibility(
                                visible: pass_error,
                                child: Text(
                                  "password  is required Please enter your password"
                                      .tr,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                )),
                          ),
                          Center(
                            child: Visibility(
                                visible: pass_error_lenght,
                                child: Text(
                                  "Minimum password length is 8 characters. Please enter a valid password"
                                      .tr,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                )),
                          ),
                          const SizedBox(
                            height: 25,
                            width: double.infinity,
                          ),

                          SizedBox(
                            height: 47,
                            width: 260,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null // Disable button when loading
                                  : () async {
                                      setState(() {
                                        email_error =
                                            _emailControler.text.isEmpty;
                                        pass_error =
                                            _passwordControler.text.isEmpty;
                                        pass_error_lenght =
                                            _passwordControler.text.length < 8;
                                      });

                                      if (_emailControler.text.isEmpty ||
                                          _passwordControler.text.isEmpty) {
                                        _showAlertDialog();
                                      } else if (_passwordControler
                                              .text.length <
                                          8) {
                                        pass_error_lenght = true;
                                      } else {
                                        setState(() {
                                          isLoading = true; // Start loading
                                        });

                                        try {
                                          AuthService authService =
                                              AuthService(context);
                                          MyAppAdmins? admin =
                                              await authService.signInAdmin(
                                            email: _emailControler.text.trim(),
                                            password:
                                                _passwordControler.text.trim(),
                                          );

                                          if (admin != null) {
                                            setState(() {
                                              currentAdmin = admin;
                                            });

                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AdminMainScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          } else {
                                            _showSnackBar(
                                                "Login failed. Please check your credentials.");
                                          }
                                        } catch (e) {
                                          print("Error during login: $e");
                                          _showSnackBar(
                                              "An error occurred. Please try again.");
                                        } finally {
                                          setState(() {
                                            isLoading = false; // Stop loading
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 0, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 1.5,
                                      ),
                                    )
                                  : Text(
                                      "Login".tr,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),

                          // SizedBox(
                          //   height: 47,
                          //   width: 260,
                          //   child: ElevatedButton(
                          //     onPressed: isLoading
                          //         ? null // Disable button when loading
                          //         : () async {
                          //             setState(() {
                          //               email_error =
                          //                   _emailControler.text.isEmpty;
                          //               pass_error =
                          //                   _passwordControler.text.isEmpty;
                          //               pass_error_lenght =
                          //                   _passwordControler.text.length < 8;
                          //             });

                          //             if (_emailControler.text.isEmpty ||
                          //                 _passwordControler.text.isEmpty) {
                          //               _showAlertDialog();
                          //             } else if (_passwordControler
                          //                     .text.length <
                          //                 8) {
                          //               pass_error_lenght = true;
                          //             } else {
                          //               setState(() {
                          //                 isLoading = true; // Start loading
                          //               });

                          //               try {
                          //                 AuthService authService =
                          //                     AuthService(context);
                          //                 MyAppAdmins? admin =
                          //                     await authService.signInAdmin(
                          //                   email: _emailControler.text.trim(),
                          //                   password:
                          //                       _passwordControler.text.trim(),
                          //                 );

                          //                 if (admin != null) {
                          //                   setState(() {
                          //                     currentAdmin = admin;
                          //                   });

                          //                   Navigator.pushAndRemoveUntil(
                          //                     context,
                          //                     MaterialPageRoute(
                          //                       builder: (context) =>
                          //                           const AdminMainScreen(),
                          //                     ),
                          //                     (route) => false,
                          //                   );
                          //                 } else {
                          //                   _showSnackBar(
                          //                       "Login failed. Please check your credentials.");
                          //                 }
                          //               } catch (e) {
                          //                 print("Error during login: $e");
                          //                 _showSnackBar(
                          //                     "An error occurred. Please try again.");
                          //               } finally {
                          //                 setState(() {
                          //                   isLoading = false; // Stop loading
                          //                 });
                          //               }
                          //             }
                          //           },

                          //     // onPressed: () async {
                          //     //   setState(() {
                          //     //     email_error = _emailControler.text.isEmpty;
                          //     //     pass_error = _passwordControler.text.isEmpty;
                          //     //     pass_error_lenght =
                          //     //         _passwordControler.text.length < 8;
                          //     //   });

                          //     //   if (_emailControler.text.isEmpty ||
                          //     //       _passwordControler.text.isEmpty) {
                          //     //     _showAlertDialog();
                          //     //   } else if (_passwordControler.text.length < 8) {
                          //     //     pass_error_lenght = true;
                          //     //   } else {
                          //     //     // Perform the admin login
                          //     //     AuthService authService =
                          //     //         AuthService(context);
                          //     //     MyAppAdmins? admin =
                          //     //         await authService.signInAdmin(
                          //     //       email: _emailControler.text.trim(),
                          //     //       password: _passwordControler.text.trim(),
                          //     //     );

                          //     //     if (admin != null) {
                          //     //       setState(() {
                          //     //         currentAdmin = admin;
                          //     //       });

                          //     //       // Redirect to admin main screen if login is successful
                          //     //       Navigator.pushAndRemoveUntil(
                          //     //         context,
                          //     //         MaterialPageRoute(
                          //     //           builder: (context) =>
                          //     //               const AdminMainScreen(),
                          //     //         ),
                          //     //         (route) => true,
                          //     //       );
                          //     //     }
                          //     //   }
                          //     // },
                          //     // ... The rest of the code for the ElevatedButton ...

                          //     style: ElevatedButton.styleFrom(
                          //         foregroundColor: Colors.white,
                          //         backgroundColor:
                          //             const Color.fromARGB(255, 0, 0, 0),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(10.0),
                          //         )),
                          //     child: isLoading
                          //         ? SizedBox(
                          //             height: 22,
                          //             width: 22,
                          //             child: const CircularProgressIndicator(
                          //               color: Colors
                          //                   .white, // Customize color if needed
                          //               strokeWidth: 1.5,
                          //             ),
                          //           )
                          //         : Text(
                          //             "Login".tr,
                          //             style:
                          //                 const TextStyle(color: Colors.white),
                          //           ),
                          //   ),
                          // ),
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

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(const Duration(seconds: 1));

  //   SeendUpdate(context);
  // }

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
              // ignore: prefer_const_constructors
              content: new Text("Please fill in the required fields".tr),
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
      backgroundColor: Colors.red, // Customize the color as needed
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
