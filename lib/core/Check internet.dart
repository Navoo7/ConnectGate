// ignore_for_file: camel_case_types, unnecessary_new, prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_print, file_names, unrelated_type_equality_checks

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class connectivitycheck with ChangeNotifier {
  Connectivity _connectivity = new Connectivity();
  bool _isonline = false;
  bool get isonline => _isonline;

  startMonitrin() async {
    await initconnectibity();
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        _isonline = false;
        notifyListeners();
      } else {
        await _updateconnectivity().then((bool isconnected) {
          _isonline = isconnected;
          notifyListeners();
        });
      }
    });
  }

  Future<void> initconnectibity() async {
    try {
      var status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        _isonline = false;
        notifyListeners();
      } else {
        _isonline = true;
        notifyListeners();
      }
    } on PlatformException catch (e) {
      print("platform e " + e.toString());
    }
  }

  Future<bool> _updateconnectivity() async {
    late bool isconnected;
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isconnected = true;
      }
    } on SocketException catch (_) {
      isconnected = false;
    }
    return isconnected;
  }
}
