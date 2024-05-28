// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages, unnecessary_import

import 'package:connectgate/firebase_options.dart';
import 'package:flutter/cupertino.dart';

import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/language/MyControler.dart';
import 'package:connectgate/language/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'Screen/Splash_Screen.dart';
import 'providers/question_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

SharedPreferences? shared_pref;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  shared_pref = await SharedPreferences.getInstance();
  runApp(ConnectGateApp());
}

class ConnectGateApp extends StatelessWidget {
  ConnectGateApp({super.key});
  final MyLangControler _controller = Get.put(MyLangControler());
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => QuestionProvider()),
        ChangeNotifierProvider(
          create: (context) => connectivitycheck(),
          child: const SplashScreen(),
        ),
        // ChangeNotifierProvider(create: (context) => AuthProvider(context)),
      ],
      child: GetMaterialApp(
        translations: MyLocal(),
        locale: _controller.initiallanguage,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
