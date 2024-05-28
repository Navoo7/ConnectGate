// ignore_for_file: unused_import, file_names, camel_case_types, non_constant_identifier_names, depend_on_referenced_packages

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Pref_Services {
  late SharedPreferences prefs;

  Future<void> loadsharedprefences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> SaveUserData(String uid) async {
    await loadsharedprefences();
    prefs.setString("uid", uid);
  }

  GetUser_uid() async {
    await loadsharedprefences();
    return prefs.get('uid');
  }

  Future<void> RemoveUserData() async {
    await loadsharedprefences();
    prefs.remove('uid');
  }

  ////////////admin

  Future<void> SaveAdminData(String adminid) async {
    await loadsharedprefences();
    prefs.setString("adminid", adminid);
  }

  GetAdmin_uid() async {
    await loadsharedprefences();
    return prefs.get('adminid');
  }

  Future<void> RemoveAdminData() async {
    await loadsharedprefences();
    prefs.remove('adminid');
  }
}
