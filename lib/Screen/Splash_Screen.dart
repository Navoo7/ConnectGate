// ignore_for_file: file_names, avoid_print, use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';

import 'package:connectgate/Screen/Admin_Side/Admin_Main_Screen.dart';
import 'package:connectgate/Screen/User_Side/Login_User.dart';
import 'package:connectgate/Screen/User_Side/User_Main_Screen.dart';

import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/MyImages.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/shared_pref/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

//
class _SplashScreenState extends State<SplashScreen> {
  final Pref_Services prefServices =
      Pref_Services(); // Initialize Pref_Services
  String appVersion = 'Unknown'; // Initialize appVersion with a default value
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    // SeendUpdate(context);
    Provider.of<connectivitycheck>(context, listen: false).startMonitrin();
    getAppVersion();
  }

  Future<void> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion =
            packageInfo.version; // Update appVersion with the fetched value
      });
    } catch (e) {
      print('Error getting app version: $e');
    }
  }

  void checkLoginStatus() async {
    await prefServices.loadsharedprefences(); // Load shared preferences

    // Check if a user is logged in (you can modify this condition as needed)
    final userUid = await prefServices.GetUser_uid();
    final adminUid = await prefServices.GetAdmin_uid();

    if (userUid != null) {
      // User is logged in, navigate to User Main Screen
      // Timer(
      //   const Duration(seconds: 2),
      //   () => Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const UserMainScreen(),
      //     ),
      //     (route) => true,
      //   ),
      // );
      Timer(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const UserMainScreen())));
    } else if (adminUid != null) {
      // Admin is logged in, navigate to Admin Screen (you can implement this)
      // Timer(
      //   const Duration(seconds: 2),
      //   () => Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const AdminMainScreen(),
      //     ),
      //     (route) => true,
      //   ),
      // );
      Timer(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminMainScreen())));
    } else {
      // No user or admin is logged in, navigate to Login Screen
      // Timer(
      //   const Duration(seconds: 2),
      //   () => Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const LoginUser(),
      //     ),
      //     (route) => true,
      //   ),
      // );
      Timer(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginUser())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      return modle.isonline
          ? Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 250),
                    Image.asset(
                      MyImage.connectGate2,
                      scale: 1.1,
                    ),
                    const SizedBox(height: 250),
                    const CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 1.4,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'ConnectGate V$appVersion',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          : Nointernet();
    });
  }
}
