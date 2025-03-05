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
  });

  factory UserNormal.fromJson(Map<String, dynamic> json) {
    return UserNormal(
      id: json['id'] ?? 0, // Default to 0 if 'id' is missing
      name: json['name'] ?? 'Unknown', // Default to 'Unknown' if 'name' is missing
      email: json['email'] ?? '', // Default to empty string if 'email' is missing
      password: json['password'], // No default for password, it's optional
      full_name: json['full_name'] ?? '', // Default to empty string if 'full_name' is missing
      address: json['address'] ?? '', // Default to empty string if 'address' is missing
      phone: json['phone'] ?? '', // Default to empty string if 'phone' is missing
      gender: json['gender'] ?? '', // Default to empty string if 'gender' is missing
      dob: json['dob'] ?? '', // Default to empty string if 'dob' is missing
      avatar: json['avatar'], // No default for avatar, it's optional
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
