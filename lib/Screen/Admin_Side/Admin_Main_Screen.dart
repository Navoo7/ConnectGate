// ignore_for_file: file_names, unnecessary_new, unused_import, non_constant_identifier_names, prefer_final_fields, depend_on_referenced_packages

import 'package:connectgate/Screen/Admin_Side/Answeared.Admin.dart';
import 'package:connectgate/Screen/Admin_Side/Profile_Admin.dart';
import 'package:connectgate/Screen/Admin_Side/Question_Add.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:connectgate/models/static_value.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}
//hello

class _AdminMainScreenState extends State<AdminMainScreen> {
  List Screens = [
    const AnswearedAdmin(),
    const QuestionAdd(),
    const ProfileAdmin(),
  ];
  final items = const [
    Icon(
      Icons.question_answer_outlined,
      size: 30,
      color: Colors.white,
    ),
    Icon(
      Icons.add,
      size: 40,
      color: Colors.white,
    ),
    Icon(
      Icons.person,
      size: 35,
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
                // const Color.fromARGB(255, 32, 41, 46),
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

  // Future<void> fetchUserData() async {
  //   AuthService authService = AuthService(context);
  //   MyAppAdmins? adminData = (await authService.getCurrentAdmin());
  //   setState(() {
  //     ADMIN_DATA.email = adminData!.email;
  //     ADMIN_DATA.name = adminData.name;
  //   });
  // }

  Future<void> fetchUserData() async {
    AuthService authService = AuthService(context);
    MyAppAdmins? adminData = await authService.getCurrentAdmin();
    if (mounted) {
      // Check if the widget is still in the widget tree
      setState(() {
        ADMIN_DATA.email = adminData?.email ?? '';
        ADMIN_DATA.name = adminData?.name ?? '';
      });
    }
  }

  @override
  void initState() {
    fetchUserData();

    super.initState();
  }
}
