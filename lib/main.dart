// main.dart

// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages, unnecessary_import

import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/firebase_options.dart';
import 'package:connectgate/language/MyControler.dart';
import 'package:connectgate/language/text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screen/Splash_Screen.dart';
import 'providers/question_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  shared_pref = await SharedPreferences.getInstance();

  runApp(ConnectGate());
}

SharedPreferences? shared_pref;

class ConnectGate extends StatelessWidget {
  final MyLangControler _controller = Get.put(MyLangControler());
  ConnectGate({super.key});
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
