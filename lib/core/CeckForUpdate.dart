import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<Map<String, String>?> getUpdateUrls() async {
  try {
    final collection = FirebaseFirestore.instance
        .collection('version'); // Replace with your collection name
    final document = await collection
        .doc('url')
        .get(); // Replace 'url' with your document name

    if (document.exists) {
      return {
        'android': document.data()?['android'] as String? ?? '',
        'ios': document.data()?['ios'] as String? ?? '',
      };
    } else {
      return null;
    }
  } catch (e) {
    print('Error getting update URLs: $e');
    return null;
  }
}

Future<void> SeendUpdate(BuildContext context) async {
  try {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 2),
      minimumFetchInterval: const Duration(seconds: 1),
    ));
    await remoteConfig.fetchAndActivate();
    String appversionf = remoteConfig.getString('appVersion');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersionp = packageInfo.version;

    if (appversionf.compareTo(appVersionp) == 1) {
      // Use Future.microtask to avoid BuildContext issues
      Future.microtask(() {
        _showUpdateDialog(context);
      });
    }
  } catch (e) {
    print('Error in SeendUpdate: $e');
  }
}

void _showUpdateDialog(BuildContext context) async {
  final updateUrls = await getUpdateUrls();

  if (updateUrls == null) {
    return; // No update URLs available
  }

  // Set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      "New Version".tr,
      style: const TextStyle(fontFamily: 'NRT', fontWeight: FontWeight.w600),
    ),
    content: Text("New version available!".tr),
    actions: [
      TextButton(
        child: Text(
          "Update Now".tr,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 71, 182, 75)),
        ),
        onPressed: () {
          String? updateUrl;
          if (Platform.isIOS) {
            updateUrl = updateUrls['ios'];
          } else {
            updateUrl = updateUrls['android'];
          }
          if (updateUrl != null && updateUrl.isNotEmpty) {
            launchUrlString(updateUrl);
          }
        },
      ),
      const SizedBox(width: 15),
      TextButton(
        child: Text(
          "Later".tr,
          style: const TextStyle(color: Colors.black),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}























// // ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously, depend_on_referenced_packages, avoid_print

// import 'dart:io';

// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> SeendUpdate(BuildContext context) async {
//   FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
//   remoteConfig.setConfigSettings(RemoteConfigSettings(
//     fetchTimeout: const Duration(seconds: 2),
//     minimumFetchInterval: const Duration(seconds: 1),
//   ));
//   await remoteConfig.fetchAndActivate();
//   String appversionf = remoteConfig.getString('appVersion');
//   PackageInfo packageInfo = await PackageInfo.fromPlatform();
//   String appVersionp = packageInfo.version;

//   if (appversionf.compareTo(appVersionp) == 1) {
//     // Use Future.microtask to avoid BuildContext issues
//     Future.microtask(() async {
//       final updateUrls = await getUpdateUrls();
//       if (updateUrls != null) {
//         showAlertDialog(context, updateUrls);
//       }
//     });
//   }
// }

// Future<Map<String, String>?> getUpdateUrls() async {
//   try {
//     final collection = FirebaseFirestore.instance
//         .collection('version'); // Replace with your collection name
//     final document = await collection
//         .doc('url')
//         .get(); // Replace 'url' with your document name

//     if (document.exists) {
//       return {
//         'android': document.data()?['android'] as String? ?? '',
//         'ios': document.data()?['ios'] as String? ?? '',
//       };
//     } else {
//       return null;
//     }
//   } catch (e) {
//     print('Error getting update URLs: $e');
//     return null;
//   }
// }

// showAlertDialog(BuildContext parentContext, Map<String, String>? updateUrls) {
//   if (updateUrls == null) {
//     return; // No update URLs available
//   }

//   // set up the AlertDialog
//   AlertDialog alert = AlertDialog(
//     title: Text(
//       "New Version".tr,
//       style: const TextStyle(fontFamily: 'NRT', fontWeight: FontWeight.w600),
//     ),
//     content: Text("New version available!".tr),
//     actions: [
//       TextButton(
//         child: Text(
//           "Update Now".tr,
//           style: const TextStyle(
//               fontWeight: FontWeight.w700,
//               color: Color.fromARGB(255, 71, 182, 75)),
//         ),
//         onPressed: () {
//           String? updateUrl;
//           if (Platform.isIOS) {
//             updateUrl = updateUrls['ios'];
//           } else {
//             updateUrl = updateUrls['android'];
//           }
//           if (updateUrl != null && updateUrl.isNotEmpty) {
//             launchUrlString(updateUrl);
//           }
//         },
//       ),
//       const SizedBox(
//         width: 15,
//       ),
//       TextButton(
//         child: Text(
//           "Later".tr,
//           style: const TextStyle(color: Colors.black),
//         ),
//         onPressed: () {
//           Navigator.pop(parentContext);
//         },
//       ),
//     ],
//   );

//   showDialog(
//     context: parentContext,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return alert;
//     },
//   );
// }
