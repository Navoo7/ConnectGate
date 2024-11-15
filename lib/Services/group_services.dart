// GroupService.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectgate/models/admin_model.dart';
import 'package:connectgate/models/group_model.dart';
import 'package:connectgate/shared_pref/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new group
  Future<void> createGroup(MyAppGroup group) async {
    try {
      MyAppAdmins? adminData = await getCurrentAdmin();

      await _firestore
          .collection(adminData!.org)
          .doc(adminData.city)
          .collection('groups')
          .doc(group.id)
          .set({
        'name': group.name,
        'org': group.org,
        'city': group.city,
        'users': [],
      });
      print('Group created successfully.');
    } catch (e) {
      print('Error creating group: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      MyAppAdmins? adminData = await getCurrentAdmin();
      if (adminData != null) {
        // Delete the group from the 'groups' collection
        await _firestore
            .collection(adminData.org)
            .doc(adminData.city)
            .collection('groups')
            .doc(groupId)
            .delete();
        print('Group $groupId deleted from groups collection.');

        // Remove the group reference from users who have it
        final usersWithGroup = await _firestore
            .collection('users')
            .where('groups.$groupId', isNull: false)
            .get();

        WriteBatch batch = _firestore.batch();

        for (final userDoc in usersWithGroup.docs) {
          batch.update(userDoc.reference, {
            'groups.$groupId': FieldValue.delete(),
          });
        }

        await batch.commit();
        print('Group references removed from users.');
      }
    } catch (e) {
      print('Error deleting group: $e');
    }
  }

  Future<MyAppAdmins?> getCurrentAdmin() async {
    try {
      String adminId = await Pref_Services().GetAdmin_uid() ?? '';

      User? currentAdmin = _auth.currentUser;
      if (currentAdmin != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('admins').doc(adminId).get();
        Map<String, dynamic> adminData =
            userSnapshot.data() as Map<String, dynamic>;

        return MyAppAdmins(
          id: currentAdmin.uid,
          name: adminData['name'] ?? '',
          email: adminData['email'] ?? '',
          password: '',
          role: AdminRole.values.firstWhere(
            (role) => role.toString() == adminData['role'],
            orElse: () => AdminRole.admin,
          ),
          city: adminData['city'] ?? '',
          org: adminData['org'] ?? '',
        );
      }
    } catch (e) {
      print('Error getting admin data: $e');
    }

    return null;
  }

  Stream<List<MyAppGroup>> getGroups() {
    return Stream.fromFuture(getCurrentAdmin()).asyncMap((adminData) async {
      if (adminData != null) {
        final snapshot = await _firestore
            .collection(adminData.org)
            .doc(adminData.city)
            .collection('groups')
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          final groupId = doc.id;
          final groupName = data['name'] ?? '';
          final users = (data['users'] as List<dynamic>?)
              ?.map((user) => GroupUser(
                    id: user['id'],
                    name: user['name'],
                  ))
              .toList();

          return MyAppGroup(
              id: groupId,
              name: groupName,
              users: users ?? [],
              org: adminData.org,
              city: adminData.city);
        }).toList();
      } else {
        return [];
      }
    });
  }

  Future<void> updateGroup(MyAppGroup group, String org, String city) async {
    try {
      // Fetch the previous group data
      final groupDocRef = _firestore
          .collection(org)
          .doc(city)
          .collection('groups')
          .doc(group.id);
      final groupSnapshot = await groupDocRef.get();
      if (!groupSnapshot.exists) {
        print('Group not found');
        return;
      }
      final data = groupSnapshot.data() as Map<String, dynamic>;
      final previousUsers = (data['users'] as List<dynamic>?)
              ?.map((user) => GroupUser(
                    id: user['id'],
                    name: user['name'],
                  ))
              .toList() ??
          [];

      // Compute users added and removed
      final previousUserIds = previousUsers.map((u) => u.id).toSet();
      final updatedUserIds = group.users.map((u) => u.id).toSet();

      final usersAdded = updatedUserIds.difference(previousUserIds);
      final usersRemoved = previousUserIds.difference(updatedUserIds);

      // Update the group document
      await groupDocRef.update({
        'name': group.name,
        'users': group.users
            .map((user) => {
                  'id': user.id,
                  'name': user.name,
                })
            .toList(),
      });

      // Use WriteBatch to batch the user updates
      final batch = _firestore.batch();

      // For users added, add group info to their documents
      for (final userId in usersAdded) {
        final userDocRef = _firestore.collection('users').doc(userId);
        batch.update(userDocRef, {
          'groups.${group.id}': {
            'name': group.name,
            'id': group.id,
          },
        });
      }

      // For users removed, remove group info from their documents
      for (final userId in usersRemoved) {
        final userDocRef = _firestore.collection('users').doc(userId);
        batch.update(userDocRef, {
          'groups.${group.id}': FieldValue.delete(),
        });
      }

      // Commit the batch
      await batch.commit();
      print("Group updated successfully");
    } catch (e) {
      print('Error updating group: $e');
    }
  }
}



















// // ignore_for_file: avoid_print, unnecessary_cast, duplicate_ignore, depend_on_referenced_packages

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectgate/models/admin_model.dart';
// import 'package:connectgate/models/group_model.dart';
// import 'package:connectgate/shared_pref/shared_pref.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class GroupService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   MyAppAdmins? adminData;

//   // Create a new group
//   Future<void> createGroup(MyAppGroup group) async {
//     try {
//       MyAppAdmins? adminData = await getCurrentAdmin();

//       await _firestore
//           .collection(adminData!.org)
//           .doc(adminData.city)
//           .collection('groups')
//           .doc(group.id)
//           .set({
//         'name': group.name,
//         'org': group.org,
//         'city': group.city,
//         'users': [],
//       });
//       print(adminData.email);
//     } catch (e) {
//       // ignore: avoid_print
//       print('Error creating group: $e');
//     }
//   }

//   Future<void> deleteGroup(String groupId) async {
//     try {
//       MyAppAdmins? adminData = await getCurrentAdmin();
//       if (adminData != null) {
//         // 1. Delete the group from the 'groups' collection
//         await _firestore
//             .collection(adminData.org)
//             .doc(adminData.city)
//             .collection('groups')
//             .doc(groupId)
//             .delete();
//         print('Group $groupId deleted from groups collection.');

//         // 2. Remove the group reference from users
//         final usersSnapshot = await _firestore.collection('users').get();
//         for (final userDoc in usersSnapshot.docs) {
//           final userData = userDoc.data() as Map<String, dynamic>;
//           final userId = userDoc.id;

//           // Debugging statement to check user data
//           print('User $userId data: ${userData['groups']}');

//           // If the user is part of the deleted group, remove it from their data
//           if (userData['groups'] != null) {
//             final groupsMap = userData['groups'] as Map?;
//             if (groupsMap != null && groupsMap.containsKey(groupId)) {
//               await _firestore.collection('users').doc(userId).update({
//                 'groups.$groupId': FieldValue.delete(),
//               });
//               print('Group $groupId removed from user $userId.');
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Error deleting group: $e');
//     }
//   }

//   void get() async {
//     adminData = await getCurrentAdmin();
//   }

//   Future<MyAppAdmins?> getCurrentAdmin() async {
//     try {
//       String adminid = "";
//       await Pref_Services().GetAdmin_uid().then((value) {
//         adminid = value.toString();
//       });

//       User? currentAdmin = _auth.currentUser;
//       if (currentAdmin != null) {
//         DocumentSnapshot userSnapshot =
//             await _firestore.collection('admins').doc(adminid).get();
//         Map<String, dynamic> adminData =
//             userSnapshot.data() as Map<String, dynamic>;

//         return MyAppAdmins(
//           id: currentAdmin.uid,
//           name: adminData['name'] ?? '',
//           email: adminData['email'] ?? '',
//           password: '', // Password is not stored in Firestore
//           role: AdminRole.values.firstWhere(
//             (role) => role.toString() == adminData['role'],
//             orElse: () => AdminRole.admin,
//           ),
//           city: adminData['city'] ?? '',
//           org: adminData['org'] ?? '',
//         );
//       }
//     } catch (e) {
//       //   _showSnackBar('Error getting admins data: $e', Colors.red);
//     }

//     return null;
//   }

//   // Update your getGroups method
//   Stream<List<MyAppGroup>> getGroups() {
//     return Stream.fromFuture(getCurrentAdmin()).asyncMap((adminData) async {
//       if (adminData != null) {
//         final snapshot = await _firestore
//             .collection(adminData.org) // Use admin's org
//             .doc(adminData.city) // Use admin's city
//             .collection('groups')
//             .get();

//         return snapshot.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           final groupId = doc.id;
//           final groupName = data['name'] ?? '';
//           // final org = data['org'];
//           // final city = data['city'];
//           final users = (data['users'] as List<dynamic>?)
//               ?.map((user) => GroupUser(
//                     id: user['id'],
//                     name: user['name'],
//                   ))
//               .toList();

//           return MyAppGroup(
//               id: groupId,
//               name: groupName,
//               users: users ?? [],
//               org: adminData.org,
//               city: adminData.city);
//         }).toList();
//       } else {
//         // Handle the case when adminData is null (e.g., admin not logged in)
//         return [];
//       }
//     });
//   }

//   Future<void> updateGroup(MyAppGroup group, String org, String city) async {
//     try {
//       // Use org and city parameters in Firestore queries
//       await _firestore
//           .collection(org)
//           .doc(city)
//           .collection('groups')
//           .doc(group.id)
//           .update({
//         'name': group.name,
//         'users': group.users
//             .map((user) => {
//                   'id': user.id,
//                   'name': user.name,
//                 })
//             .toList(),
//       });

//       // Iterate over the group's users and update their user documents
//       for (final user in group.users) {
//         await _firestore.collection('users').doc(user.id).update({
//           'groups.${group.id}': {
//             'name': group.name,
//             'id': group.id,
//           },
//         });
//       }
//       // Remove the group from users not in the updated group
//       final allUsers = await _firestore.collection('users').get();
//       for (final user in allUsers.docs) {
//         final userData = user.data() as Map<String, dynamic>;
//         final userId = user.id;

//         // If the user is not in the updated group, remove the group from their data
//         if (!group.users.any((groupUser) => groupUser.id == userId)) {
//           final groupIds = List<String>.from(userData['groupIds'] ?? []);
//           groupIds.remove(group.id);
//           await _firestore.collection('users').doc(userId).update({
//             'groups.${group.id}': FieldValue.delete(),
//             // 'groupIds': groupIds,
//           });
//         }
//       }
//       print("======= done");
//     } catch (e) {
//       print('Error updating group: $e');
//     }
//   }
// }
