// ignore_for_file: file_names, avoid_print, depend_on_referenced_packages

import 'package:connectgate/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class MyLangControler extends GetxController {
  late Locale initiallanguage;

  MyLangControler() {
    // Initialize with a default value if none of the conditions are met
    initiallanguage = const Locale("en");

    if (shared_pref!.getString("lang") == "es") {
      initiallanguage = const Locale("es");
    } else if (shared_pref!.getString("lang") == "fr") {
      initiallanguage = const Locale("fr");
    } else if (shared_pref!.getString("lang") == "en") {
      initiallanguage = const Locale("en");
    } else if (shared_pref!.getString("lang") == "it") {
      initiallanguage = const Locale("it");
    }
  }

  // void changeLang(String codelang) {
  //   Locale locale = Locale(codelang);
  //   shared_pref!.setString('lang', codelang);
  //   Get.updateLocale(locale);
  // }
  void changeLang(String codelang) {
    print('Changing language to $codelang');
    Locale locale = Locale(codelang);
    shared_pref!.setString('lang', codelang);
    Get.updateLocale(locale);
  }

  init() {}
}
