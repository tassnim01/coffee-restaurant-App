class AppUser {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String? tableNumber;

  const AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.tableNumber,
  });

  AppUser copyWith({String? tableNumber}) => AppUser(
    uid: uid,
    name: name,
    phone: phone,
    email: email,
    tableNumber: tableNumber ?? this.tableNumber,
  );
}
