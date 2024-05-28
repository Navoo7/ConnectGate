enum AdminRole {
  user,
  admin,
}

class MyAppAdmins {
  final String id;
  final String name;
  final String email;
  final String password;
  final AdminRole role; // Change the 'role' parameter type to UserRole
  final String org;
  final String city;

  MyAppAdmins(
      {required this.id,
      required this.name,
      required this.email,
      required this.password,
      required this.role,
      required this.org,
      required this.city});
}
