// group_model.dart
class GroupUser {
  final String id;
  final String name;

  GroupUser({
    required this.id,
    required this.name,
  });
}

class MyAppGroup {
  final String id;
  final String name;
  final List<GroupUser> users;
  final String org;
  final String city;

  MyAppGroup({
    required this.id,
    required this.name,
    required this.users,
    required this.org,
    required this.city,
  });
}







// class MyAppGroup {
//   final String id;
//   final String name;
//   final List<GroupUser> users;
//   final String org;
//   final String city;

//   MyAppGroup({
//     required this.id,
//     required this.name,
//     required this.users,
//     required this.org,
//     required this.city,
//   });
// }

// class GroupUser {
//   final String id;
//   final String name;

//   GroupUser({
//     required this.id,
//     required this.name,
//   });
// }
