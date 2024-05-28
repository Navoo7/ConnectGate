// ignore_for_file: unnecessary_import, unused_import, file_names, implementation_imports, prefer_const_constructors_in_immutables, depend_on_referenced_packages

import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/MyImages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Nointernet extends StatefulWidget {
  Nointernet({super.key});

  @override
  State<Nointernet> createState() => _NointernetState();
}

class _NointernetState extends State<Nointernet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //  crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 133,
                height: 133,
                decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage(MyImage.wifi))),
              ),
              const SizedBox(
                height: 60,
              ),
              Text(
                "There is no internet connection.".tr,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                "Please make sure your internet connection is no problem and \n try again"
                    .tr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 24,
              ),
              TextButton(
                onPressed: () {
                  Provider.of<connectivitycheck>(context, listen: false)
                      .startMonitrin();
                },
                child: Text(
                  "try again".tr,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 101, 22),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
