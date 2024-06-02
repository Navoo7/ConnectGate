// ignore_for_file: prefer_const_constructors, file_names, depend_on_referenced_packages

import 'dart:math';

// import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/MyImages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnswearedUser extends StatefulWidget {
  const AnswearedUser({super.key});

  @override
  State<AnswearedUser> createState() => _AnswearedUserState();
}

class _AnswearedUserState extends State<AnswearedUser> {
  // @override
  // void initState() {
  //   Future.delayed(const Duration(seconds: 1));

  //   SeendUpdate(context);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              background:
                  Container(color: Colors.white //Color.fromARGB(255, 31, 0, 0),
                      ),
              centerTitle: true,
              title: Text(
                'M A I L S'.tr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'ageo-bold',
                  letterSpacing: ln2,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  color: const Color.fromARGB(221, 197, 197, 197),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  MyImage.connectGate2,
                                  scale: 1.5,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Welcome to ConnectGate!'.tr,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'NRT',
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "ConnectGate is your geteway to meaningful\nconnections and insightful research,Explore,\nengage,and discover as your journey through \nour platform."
                                      .tr,
                                  //  "ConnectGate is your geteway to meaningfulconnections and insightful research,Explore, engage,and discover as your journey through our platform.",

                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'NRT',
                                      fontSize: 10),
                                ),
                                SizedBox(
                                  height: 11,
                                ),
                                Text(
                                  'Join us in connecting the World, \nOne Question at a time.'
                                      .tr,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'NRT',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 80,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //sliver Items

          //////////////////////////////////////////
          ///

          /////////////////////
        ],
      ),
    );
  }
}
