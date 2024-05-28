enum UserRole {
  user,
  admin,
}

class MyAppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role; // Change the 'role' parameter type to UserRole
  final String org;
  final String city;
  MyAppUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.password,
      required this.role,
      required this.org,
      required this.city});
}
//