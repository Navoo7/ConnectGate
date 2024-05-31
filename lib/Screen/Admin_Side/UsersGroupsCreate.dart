// Group and User Creation Page
// ignore_for_file: library_private_types_in_public_api, file_names, unused_field, unused_local_variable, unused_element, unused_import, use_build_context_synchronously, unnecessary_null_comparison, depend_on_referenced_packages, non_constant_identifier_names

import 'dart:math';

import 'package:connectgate/Screen/Admin_Side/Admin_Main_Screen.dart';
import 'package:connectgate/Services/auth_services.dart';
import 'package:connectgate/Services/group_services.dart';
import 'package:connectgate/core/CeckForUpdate.dart';
import 'package:connectgate/core/Check%20internet.dart';
import 'package:connectgate/core/NoInternet.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:connectgate/models/group_model.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UsersGroupsCreate extends StatefulWidget {
  const UsersGroupsCreate({super.key});

  // ... constructor and other attributes ...

  @override
  _UsersGroupsCreateState createState() => _UsersGroupsCreateState();
}

class _UsersGroupsCreateState extends State<UsersGroupsCreate> {
  bool _iscreatingGroups = false;
  bool _isDisposed = false; // Add this flag
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool pass_error = false;
  bool pass_error_lenght = false;
  late AuthService _authService; // Declare AuthService variable here
  final GroupService _groupService = GroupService();
  TextEditingController groupNameController = TextEditingController();
  List<String> groupNames = [];
  List<MyAppUser> allUsersList = []; //eplace with real users

  @override
  void initState() {
    super.initState();
    _authService = AuthService(context);
    _authService.getUsers().listen((users) {
      get();
      if (!_isDisposed) {
        setState(() {
          allUsersList = users;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // Update _isDisposed when the widget is disposed
    passwordController.dispose();
    // SeendUpdate(context);
    super.dispose();
  }

  // @override
  // void dispose() {
  //   _isDisposed = true;
  //   passwordController.dispose();
  //   nameController.dispose();
  //   emailController.dispose();
  //   groupNameController.dispose();
  //   // Dispose any other controllers or streams if used
  //   super.dispose();
  // }

  MyAppAdmins? adminData;
  void get() async {
    adminData = await AuthService(context).getCurrentAdmin();
  }

  void addGroup() async {
    if (groupNameController.text.isNotEmpty) {
      final newGroup = MyAppGroup(
        id: Random().nextInt(100000).toString(),
        name: groupNameController.text,
        users: [],
        org: adminData!.org,
        city: adminData!.city,
      );
      await _groupService.createGroup(newGroup);

      setState(() {
        groupNames.add(newGroup.name);
        groupNameController.text = '';
      });
    }
  }

  Future<void> signUpUser() async {
    if (_isDisposed) return;

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar(context, 'Please fill in all fields'.tr, Colors.red);
      return;
    }

    try {
      MyAppUser? newUser = await _authService.signUpUser(
        name: name,
        email: email,
        password: password,
      );
      if (newUser != null) {
        // Clear the text fields after successful sign-up
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        _showSnackbar(context, 'User created successfully'.tr, Colors.green);
      } else {
        _showSnackbar(context, 'User creation failed'.tr, Colors.red);
      }
    } catch (e) {
      _showSnackbar(context, 'Error creating user: $e'.tr, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<connectivitycheck>(builder: (context, modle, child) {
      if (modle.isonline != null) {
        return modle.isonline
            ? Scaffold(
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: CustomScrollView(
                    slivers: [
                      //sliver appbar

                      SliverAppBar(
                        leading: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            // Navigator.pushAndRemoveUntil(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           const AdminMainScreen()),
                            //   (route) => false, // Remove all previous routes
                            // );
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
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
                              color: Colors
                                  .transparent //Color.fromARGB(255, 31, 0, 0),
                              ),
                          centerTitle: true,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 50),
                                child: Text(
                                  'Creating Users And Groups'.tr,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'ageo-bold',
                                    // letterSpacing: ln2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      //sliver Items
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            //buildingOptionSelectors(),
                            const SizedBox(
                              height: 40,
                            ),

                            ///
                            _iscreatingGroups
                                ? creatingGroupsFiled()
                                : creatingUsersFiled(),

                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 15),
                              child: Container(
                                height: 1.2,
                                color: Colors.black,
                              ),
                            ),
                            buildingOptionSelectors(),
                          ],
                        ),
                      ),

                      /////////////////////
                    ],
                  ),
                ),
              )
            : Nointernet();
      }
      return const CircularProgressIndicator();
    });
  }

  ///.For RadioListTitle

  Widget buildingOptionSelectors() {
    return Row(
      children: [
        const SizedBox(width: 35),
        Radio<bool>(
          value: false,
          groupValue: _iscreatingGroups,
          onChanged: (value) {
            setState(() {
              _iscreatingGroups = value!;
            });
          },
          activeColor: Colors.black,
        ),
        Text(
          'Creating Users'.tr,
          style: const TextStyle(fontFamily: 'NRT', fontSize: 12),
        ),
        const SizedBox(width: 30),
        Radio<bool>(
          value: true,
          groupValue: _iscreatingGroups,
          onChanged: (value) {
            setState(() {
              _iscreatingGroups = value!;
            });
          },
          activeColor: Colors.black,
        ),
        Text(
          'Creating Groups'.tr,
          style: const TextStyle(fontFamily: 'NRT', fontSize: 12),
        ),
      ],
    );
  }

  Widget creatingUsersFiled() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Creating Users'.tr,
                style: const TextStyle(
                    fontSize: 18, fontFamily: 'ageo-boldd', letterSpacing: ln2),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 22,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            minLines: 1,
            maxLines: 8,
            controller: nameController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'Name'.tr,
              hintText: 'Enter User Full Name Here'.tr,
              labelStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              prefixIcon: const Icon(
                Icons.person,
                color: Colors.black,
                size: 20,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 183, 183, 183),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            minLines: 1,
            maxLines: 8,
            controller: emailController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'Email'.tr,
              hintText: 'Enter Email Here'.tr,
              labelStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              prefixIcon: const Icon(
                Icons.email_sharp,
                color: Colors.black,
                size: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 183, 183, 183),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            maxLength: 15,
            controller: passwordController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'password'.tr,
              hintText: 'Enter Password Here'.tr,
              labelStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              prefixIcon: const Icon(
                Icons.key,
                color: Colors.black,
                size: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 183, 183, 183),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Center(
          child: Visibility(
              visible: pass_error,
              child: Text(
                "password  is required Please enter your password".tr,
                style: const TextStyle(color: Colors.red, fontSize: 10),
              )),
        ),
        Center(
          child: Visibility(
              visible: pass_error_lenght,
              child: Text(
                "Minimum password length is 8 characters. Please enter a valid password"
                    .tr
                    .tr,
                style: const TextStyle(color: Colors.red, fontSize: 10),
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: SizedBox(
            height: 47,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  pass_error = passwordController.text.isEmpty;
                  pass_error_lenght = passwordController.text.length < 8;
                });
                if (passwordController.text.isEmpty) {
                  pass_error = true;
                } else if (passwordController.text.length < 8) {
                  pass_error_lenght = true;
                } else {
                  signUpUser();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                'Save'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Widget creatingGroupsFiled() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Creating Groups:'.tr,
                style: const TextStyle(
                    fontSize: 18, fontFamily: 'ageo-boldd', letterSpacing: ln2),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 22,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            minLines: 1,
            maxLines: 8,
            controller: groupNameController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'Group Name'.tr,
              hintText: 'Enter GroupName Here'.tr,
              labelStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              prefixIcon: const Icon(
                Icons.group,
                color: Colors.black,
                size: 20,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 183, 183, 183),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: SizedBox(
            height: 47,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                addGroup();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Text(
                'Save'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        // Assign User to Group Section
        // Display created groups
        StreamBuilder<List<MyAppGroup>>(
          stream: _groupService.getGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final groups = snapshot.data ?? [];

              return ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index]; // Get the group at index
                  return ListTile(
                    title: Text(
                      group.name,
                      style: const TextStyle(
                          fontFamily: 'ageo-bold', fontSize: 18),
                    ),
                    subtitle: Text(
                      'Users: ${group.users.map((user) => user.name).join(', ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _showAddUsersDialog(group, allUsersList),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      child: Text(
                        'Add Users'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'NRT',
                            fontSize: 12),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _showAddUsersDialog(
      MyAppGroup group, List<MyAppUser> allUsers) async {
    if (_isDisposed) return;

    List<GroupUser> selectedUsers = group.users; // Copy existing users
    MyAppAdmins? adminData = await AuthService(context).getCurrentAdmin();

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            iconColor: Colors.black,
            title: Text('Select Users for ${group.name}'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var user in allUsers)
                      CheckboxListTile(
                        activeColor: Colors.black,
                        selectedTileColor: Colors.black,
                        value: selectedUsers
                            .any((selectedUser) => selectedUser.id == user.id),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              selectedUsers.add(GroupUser(
                                id: user.id,
                                name: user.name,
                              ));
                            } else {
                              selectedUsers.removeWhere(
                                  (selectedUser) => selectedUser.id == user.id);
                            }
                          });
                        },
                        title: Text(user.name),
                      ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel'.tr,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (_isDisposed) return;

                  // Save selectedUsers to the corresponding group
                  final updatedGroup = MyAppGroup(
                      id: group.id,
                      name: group.name,
                      users: selectedUsers,
                      org: adminData!.org,
                      city: adminData.city);

                  // Update the group using the service
                  await _groupService.updateGroup(
                      updatedGroup, adminData.org, adminData.city);

                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: Text(
                  'Save'.tr,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      action: SnackBarAction(
        label: 'Dismiss'.tr,
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
