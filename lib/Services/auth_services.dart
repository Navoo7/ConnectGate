// ignore_for_file: unnecessary_cast, use_build_context_synchronously, unnecessary_null_comparison, avoid_print, unused_field, no_leading_underscores_for_local_identifiers, unused_local_variable, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/Screen/Admin_Side/Admin_Main_Screen.dart';
import 'package:connectgate/Screen/User_Side/User_Main_Screen.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:connectgate/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared_pref/shared_pref.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final BuildContext context;

  AuthService(this.context);

  // Get user by ID from Firestore
  Future<MyAppAdmins?> getAdminById(String adminId) async {
    try {
      AuthService authService = AuthService(context);
      MyAppAdmins? adminData = (await authService.getCurrentAdmin());
      DocumentSnapshot doc =
          await _firestore.collection('admins').doc(adminId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return MyAppAdmins(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          password: '', // Password is not stored in Firestore
          role: AdminRole.values.firstWhere(
            (role) => role.toString() == data['role'],
            orElse: () => AdminRole.admin,
          ),
          city: data['city'] ?? '',
          org: data['org'] ?? '',
        );
      } else {
        return null;
      }
    } catch (e) {
      _showSnackBar('Error getting Admin data: $e', Colors.red);
      return null;
    }
  }

  // Get the currently logged-in user from Firestore
  Future<MyAppAdmins?> getCurrentAdmin() async {
    try {
      String _adminid = "";
      await Pref_Services().GetAdmin_uid().then((value) {
        _adminid = value.toString();
      });

      User? currentAdmin = _auth.currentUser;
      if (currentAdmin != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('admins').doc(_adminid).get();
        if (userSnapshot.exists) {
          Map<String, dynamic>? adminData =
              userSnapshot.data() as Map<String, dynamic>?;

          if (adminData != null) {
            return MyAppAdmins(
              id: currentAdmin.uid,
              name: adminData['name'] ?? '',
              email: adminData['email'] ?? '',
              password: '', // Password is not stored in Firestore
              role: AdminRole.values.firstWhere(
                (role) => role.toString() == adminData['role'],
                orElse: () => AdminRole.admin,
              ),
              city: adminData['city'] ?? '',
              org: adminData['org'] ?? '',
            );
          }
        }
      }
    } catch (e) {
      _showSnackBar('Error getting admins data: $e', Colors.red);
    }

    return null;
  }

  // Get the currently logged-in user from Firestore
  Future<MyAppUser?> getCurrentUser() async {
    try {
      String _uid = "";
      await Pref_Services().GetUser_uid().then((value) {
        _uid = value.toString();
      });

      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(_uid).get();
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        return MyAppUser(
          id: currentUser.uid,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          password: '', // Password is not stored in Firestore
          role: UserRole.values.firstWhere(
            (role) => role.toString() == userData['role'],
            orElse: () => UserRole.user,
          ),
          city: userData['city'] ?? '',
          org: userData['org'] ?? '',
        );
      }
    } catch (e) {
      _showSnackBar('Error getting user data: $e', Colors.red);
    }

    return null;
  }

  // ... Existing code ...
// Get user by ID from Firestore
  Future<MyAppUser?> getUserById(String userId) async {
    try {
      AuthService authService = AuthService(context);
      MyAppAdmins? adminData = (await authService.getCurrentAdmin());
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return MyAppUser(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          password: '', // Password is not stored in Firestore
          role: UserRole.values.firstWhere(
            (role) => role.toString() == data['role'],
            orElse: () => UserRole.user,
          ),
          city: data['city'] ?? '',
          org: data['org'] ?? '',
        );
      } else {
        return null;
      }
    } catch (e) {
      _showSnackBar('Error getting user data: $e', Colors.red);
      return null;
    }
  }

  Stream<List<MyAppUser>> getUsers() async* {
    AuthService authService = AuthService(context);
    MyAppAdmins? adminData = (await authService.getCurrentAdmin());
    yield* _firestore
        .collection('users')
        .where('org', isEqualTo: adminData!.org)
        .where('city', isEqualTo: adminData.city)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MyAppUser(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          password: '', // Password is not stored in Firestore
          role: UserRole.values.firstWhere(
            (role) => role.toString() == data['role'],
            orElse: () => UserRole.user,
          ),
          city: data['city'] ?? '',
          org: data['org'] ?? '',
        );
      }).toList();
    });
  }

  // Save user data to Firestore
  Future<void> saveUserDataToFirestore(MyAppUser user) async {
    try {
      AuthService authService = AuthService(context);
      MyAppAdmins? adminData = (await authService.getCurrentAdmin());
      String userRole = user.role == UserRole.admin ? 'admin' : 'user';
      await FirebaseFirestore.instance
          // .collection(adminData!.org)
          // .doc(adminData.city)
          .collection("users")
          .doc(user.id)
          .set({
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'role': userRole,
        'org': adminData!.org,
        'city': adminData.city
      });
    } catch (e) {
      _showSnackBar('Error saving user data to Firestore: $e', Colors.red);
    }
  }

  //////////////////////////                  ADMIN      ADMIN       ADMIN  ADMIN

  // Sign in user with email and password
  Future<MyAppAdmins?> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseAdmin = result.user;
      if (firebaseAdmin != null) {
        MyAppAdmins? admin = await getAdminById(firebaseAdmin.uid);
        if (admin?.role == AdminRole.admin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminMainScreen(),
            ),
            (route) => true,
          );
          _showSnackBar('Login successful!'.tr, Colors.green);
          Pref_Services().SaveAdminData(firebaseAdmin.uid);
          return admin;
        } else {
          _showSnackBar('Only Admin can access this page.'.tr, Colors.red);
          _auth.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _showSnackBar('Invalid email or password.'.tr, Colors.red);
      } else {
        // _showSnackBar('Error signing in: ${e.message}', Colors.red);
        _showSnackBar('Invalid email or password.'.tr, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error signing in: $e', Colors.red);
    }

    return null;
  }

  // Sign in user with email and password
  Future<MyAppUser?> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        MyAppUser? user = await getUserById(firebaseUser.uid);
        if (user?.role == UserRole.user) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const UserMainScreen(),
            ),
            (route) => true,
          );
          Pref_Services().SaveUserData(firebaseUser.uid);
          _showSnackBar('Login successful!'.tr, Colors.green);
          return user;
        } else {
          _showSnackBar('Only users can access this page.'.tr, Colors.red);
          _auth.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _showSnackBar('Invalid email or password.'.tr, Colors.red);
      } else {
        // _showSnackBar('Error signing in: ${e.message}', Colors.red);
        _showSnackBar('Invalid email or password.'.tr, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error signing in: $e', Colors.red);
    }

    return null;
  }

  // Sign out the Admin
  Future<void> signOutAdmin() async {
    try {
      await _auth.signOut();
      Pref_Services().RemoveAdminData();
    } catch (e) {
      _showSnackBar('Error signing out: $e', Colors.red);
    }
  }

// Sign out the user
  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      Pref_Services().RemoveUserData();
    } catch (e) {
      _showSnackBar('Error signing out: $e', Colors.red);
    }
  }

  // Sign up user with email and password
  Future<MyAppUser?> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      AuthService authService = AuthService(context);
      MyAppAdmins? adminData = (await authService.getCurrentAdmin());
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        MyAppUser newUser = MyAppUser(
          id: firebaseUser.uid,
          name: name,
          email: email,
          password: password,
          role: UserRole.user,
          org: adminData!.org,
          city: adminData.city,
        );

        // Save user data to Firestore
        await saveUserDataToFirestore(newUser);

        // Show success message using green SnackBar
        _showSnackBar('Sign-up successful!', Colors.green);

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showSnackBar('The password is too weak.'.tr, Colors.red);
      } else if (e.code == 'email-already-in-use') {
        _showSnackBar('The account already exists.'..tr, Colors.red);
      } else {
        _showSnackBar('Error signing up user: ${e.message}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error signing up user: $e', Colors.red);
    }

    return null;
  }

////////////////////////////// SHOW SNAKBAR
  void _showSnackBar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
