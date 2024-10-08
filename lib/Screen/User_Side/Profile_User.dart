// ignore_for_file: file_names, use_build_context_synchronously, depend_on_referenced_packages, avoid_print

import 'dart:math';

import 'package:connectgate/Screen/User_Side/Login_User.dart';
import 'package:connectgate/Screen/User_Side/about.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/language/MyControler.dart';
import 'package:connectgate/main.dart';
import 'package:connectgate/models/static_value.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  String _selectedLanguage = '';
  // MyLangControler myLangControler = Get.put(MyLangControler());
  MyLangControler myLangControler = Get.find();
  // Add a variable to hold the current user's data
  MyAppUser? currentUser;
  String appVersion = 'Unknown'; // Initialize appVersion with a default value
  @override
  Widget build(BuildContext context) {
    // If the user data is not yet fetched, show a loading indicator or return an empty Container
    if (currentUser == null) {
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.black,
      ));
    }

    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      return modle.isonline
          ? Scaffold(
              body: CustomScrollView(
                slivers: [
                  //sliver appbar
                  SliverAppBar(
                    // /leading: const Icon(Icons.menu),
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
                          color: Colors.white //Color.fromARGB(255, 31, 0, 0),
                          ),
                      centerTitle: true,
                      title: Text(
                        'P R O F I L E'.tr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'ageo-bold',
                          letterSpacing: ln2,
                        ),
                      ),
                    ),
                  ),

                  //sliver Items

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                            width: double.infinity,
                          ),
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(400)),
                            child: const Icon(
                              Icons.person_4,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                            width: double.infinity,
                          ),
                          Text(
                            USER_DATA.name
                                .toUpperCase(), // Display the user's name
                            style: const TextStyle(
                                letterSpacing: 5.5,
                                color: Colors.black,
                                fontFamily: 'ageo-boldd'),
                          ),
                          const SizedBox(
                            height: 4,
                            width: double.infinity,
                          ),
                          Text(
                            USER_DATA.email
                                .toUpperCase(), // Display the user's name
                            style: const TextStyle(
                                fontSize: 9,
                                letterSpacing: 1.2,
                                color: Colors.black,
                                fontFamily: 'ageo'),
                          ),
                          const SizedBox(
                            height: 20,
                            width: double.infinity,
                          ),
                          Container(
                            height: 1.5,
                            width: 330,
                            color: Colors.black,
                          ),
                          ////////////////////////////////////////////////////////////
                          ///

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 25),
                            child: Column(
                              children: [
                                ExpansionTile(
                                  trailing: const SizedBox.shrink(),
                                  leading: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Icon(
                                      Icons.settings_applications,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    'Settings'.tr,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontFamily: 'ageo-medium',
                                        letterSpacing: ln2),
                                  ),

                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: <Widget>[
                                    ExpansionTile(
                                      trailing: const SizedBox.shrink(),
                                      leading: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Icon(
                                          Icons.translate,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ),
                                      title: Text(
                                        'Language'.tr,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontFamily: 'ageo-medium',
                                            letterSpacing: ln2),
                                      ),
                                      children: <Widget>[
                                        ListTile(
                                          title: InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  _selectedLanguage = 'en';
                                                  myLangControler
                                                      .changeLang("en");
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'English'.tr,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontFamily: 'ageo-medium',
                                                      letterSpacing: ln2),
                                                ),
                                                Radio(
                                                  fillColor: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          Colors.black),
                                                  value: 'en',
                                                  groupValue: _selectedLanguage,
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        _selectedLanguage =
                                                            'en';
                                                        myLangControler
                                                            .changeLang("en");
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  _selectedLanguage = 'es';
                                                  myLangControler
                                                      .changeLang("es");
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Arabic'.tr,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontFamily: 'ageo-medium',
                                                      letterSpacing: ln2),
                                                ),
                                                Radio(
                                                  fillColor: WidgetStateColor
                                                      .resolveWith((states) =>
                                                          Colors.black),
                                                  value: 'es',
                                                  groupValue: _selectedLanguage,
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        _selectedLanguage =
                                                            'es';
                                                        myLangControler
                                                            .changeLang("es");
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  _selectedLanguage = 'it';
                                                  myLangControler
                                                      .changeLang("it");
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Kurdish(Badini)'.tr,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontFamily: 'ageo-medium',
                                                      letterSpacing: ln2),
                                                ),
                                                Radio(
                                                  fillColor: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          Colors.black),
                                                  value: 'it',
                                                  groupValue: _selectedLanguage,
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        _selectedLanguage =
                                                            'it';
                                                        myLangControler
                                                            .changeLang("it");
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  _selectedLanguage = 'fr';
                                                  myLangControler
                                                      .changeLang("fr");
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Kurdish(Sorani)'.tr,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontFamily: 'ageo-medium',
                                                      letterSpacing: ln2),
                                                ),
                                                Radio(
                                                  fillColor: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          Colors.black),
                                                  value: 'fr',
                                                  groupValue: _selectedLanguage,
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        _selectedLanguage =
                                                            'fr';
                                                        myLangControler
                                                            .changeLang("fr");
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ///////////////////////////////////
                                    ExpansionTile(
                                      trailing: const SizedBox.shrink(),
                                      leading: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Icon(
                                          Icons.mode_night,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ),
                                      title: Text(
                                        'Light & Dark Mode'.tr,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontFamily: 'ageo-medium',
                                            letterSpacing: ln2),
                                      ),
                                      children: <Widget>[
                                        ListTile(
                                          title: InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  //   _selectedLanguage = 'بادینی';
                                                  //  controllerlang.changelan("fr");
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Light Mode'.tr,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontFamily: 'ageo-medium',
                                                      letterSpacing: ln2),
                                                ),
                                                Radio(
                                                  fillColor: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          Colors.black),
                                                  value: 'بادینی',
                                                  groupValue: _selectedLanguage,
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        // controllerlang.changelan("fr");
                                                        //_selectedLanguage = 'بادینی';
                                                        //_selectedLanguage = value.toString();
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  //  _selectedLanguage = 'سۆرانی';
                                                  // controllerlang.changelan("en");
                                                },
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Dark Mode'.tr,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontFamily: 'ageo-medium',
                                                      letterSpacing: ln2),
                                                ),
                                                Radio(
                                                  fillColor: MaterialStateColor
                                                      .resolveWith((states) =>
                                                          Colors.black),
                                                  value: 'سۆرانی',
                                                  groupValue: _selectedLanguage,
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        //_selectedlang = value;
                                                        // controllerlang.changelan("en");
                                                        // _selectedLanguage = 'سۆرانی';
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //////////////////////////////////
                                  ],
                                ),
                                /////////////////////////////////
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const About(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.code_sharp,
                                          color: Colors.black,
                                          size: 28,
                                        ),
                                        const SizedBox(
                                          width: 28,
                                        ),
                                        Text(
                                          'Developer '.tr,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontFamily: 'ageo-medium',
                                              letterSpacing: ln2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                /////////////////////////////////
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: InkWell(
                                    onTap: () async {
                                      AuthService(context).signOutUser();
                                      // AuthService authService = AuthService(context);
                                      // await authService.signOutUser();
                                      // Redirect to the login screen after logout
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginUser(),
                                        ),
                                        (route) => true,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.logout,
                                          color: Colors.black,
                                          size: 28,
                                        ),
                                        const SizedBox(
                                          width: 28,
                                        ),
                                        Text(
                                          'LogOut'.tr,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontFamily: 'ageo-medium',
                                              letterSpacing: ln2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 110,
                                ),
                                //////////////////////////////
                                Text(
                                  'ConnectGate V$appVersion',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //////////////////////////////////////////
                  ///
                ],
              ),
            )
          : Nointernet();
    });
  }

  Future<void> fetchUserData() async {
    AuthService authService = AuthService(context);
    MyAppUser? userData = (await authService.getCurrentUser());
    setState(() {
      currentUser = userData;
    });
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

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1));
    SeendUpdate(context);
    // Call the method to get the current user's data from Firestore
    fetchUserData();
    getAppVersion();
    String? lang = shared_pref!.getString("lang");
    if (lang == "es") {
      _selectedLanguage = 'es';
    } else if (lang == "fr") {
      _selectedLanguage = 'fr';
    } else if (lang == "en") {
      _selectedLanguage = 'en';
    } else if (lang == "it") {
      _selectedLanguage = 'it';
    } else {
      _selectedLanguage = 'en'; // Default to 'en' if no language is set
    }
  }
}
