// ignore_for_file: file_names, unnecessary_new, unused_import, non_constant_identifier_names, prefer_final_fields, depend_on_referenced_packages

import 'package:connectgate/Screen/User_Side/Answeared_User.dart';
import 'package:connectgate/Screen/User_Side/Profile_User.dart';
import 'package:connectgate/Screen/User_Side/Question_User.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/static_value.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  List Screens = [
    const QuestionUser(),
    const AnswearedUser(),
    const ProfileUser(),
  ];
  final items = const [
    Icon(
      Icons.question_answer_outlined,
      size: 30,
      color: Colors.white,
    ),
    Icon(
      Icons.mail_outline_rounded,
      size: 30,
      color: Colors.white,
    ),
    Icon(
      Icons.person,
      size: 30,
      color: Colors.white,
    )
  ];
  int _selectedindex = 1;
  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      return modle.isonline
          ? Scaffold(
              extendBody: true,
              bottomNavigationBar: CurvedNavigationBar(
                items: items,
                index: _selectedindex,
                color: Colors.black,
                backgroundColor: Colors.transparent,
                //color: Colors.transparent,
                buttonBackgroundColor: Colors.black,

                ///const Color.fromARGB(255, 32, 41, 46),
                height: 75,

                animationDuration: const Duration(milliseconds: 350),
                onTap: (index) {
                  setState(
                    () {
                      _selectedindex = index;
                    },
                  );
                },
              ),
              body: Screens[_selectedindex])
          : Nointernet();
    });
  }

  // @override
  // void initState() {
  //   Future.delayed(const Duration(seconds: 1));

  //   SeendUpdate(context);
  //   super.initState();
  // }

  Future<void> fetchUserData() async {
    AuthService authService = AuthService(context);
    MyAppUser? userData = await authService.getCurrentUser();
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        USER_DATA.email = userData?.email ?? '';
        USER_DATA.name = userData?.name ?? '';
      });
    }
  }

  // Future<void> fetchUserData() async {
  //   try {
  //     AuthService authService = AuthService(context);
  //     MyAppUser? userData = await authService.getCurrentUser();

  //     // Check if userData is null
  //     if (userData != null) {
  //       setState(() {
  //         USER_DATA.email =
  //             userData.email ?? ''; // Provide default value if null
  //         USER_DATA.name = userData.name ?? ''; // Provide default value if null
  //       });
  //     } else {
  //       // Handle the case where userData is null
  //       print("User data is null");
  //     }
  //   } catch (e) {
  //     // Handle any errors that occur during fetching
  //     print("Error fetching user data: $e");
  //   }
  // }

  @override
  void initState() {
    fetchUserData();

    super.initState();
  }
}
