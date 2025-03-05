class UserNormal {
  final int id;
  final String name;
  final String email;
  final String? password;
  final String full_name;
  final String? address;
  final String? phone;
  final String? gender;
  final String? dob;
  final String? avatar;
  String get displayName => name;
  final String? token;

  UserNormal({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.full_name,
    this.address,
    this.phone,
    this.gender,
    this.dob,
    this.avatar,
    this.token
  });

  factory UserNormal.fromJson(Map<String, dynamic> json) {
    return UserNormal(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      full_name: json['full_name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'full_name': full_name,
      'address': address,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'avatar': avatar,
    };
  }
}
