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
  final String? created_at;
  final String? updated_at;
  final String? avatar;
  final String? token;
  final String? emergency_numbers;

  String get displayName => full_name.isNotEmpty ? full_name : name;

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
    this.created_at,
    this.updated_at,
    this.avatar,
    this.token,
    this.emergency_numbers
  });

  factory UserNormal.fromJson(Map<String, dynamic> json) {
    return UserNormal(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      full_name: json['full_name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      created_at: json['created_at']?.toString(),
      updated_at: json['updated_at']?.toString(),
      avatar: json['avatar']?.toString(),
      token: json['token']?.toString(),
      emergency_numbers: json['emergency_numbers']?.toString(),
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
      'created_at':created_at,
      'updated_at':updated_at,
      'avatar': avatar,
      'emergency_numbers':emergency_numbers
    };
  }

  UserNormal copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? full_name,
    String? address,
    String? phone,
    String? gender,
    String? dob,
    String? created_at,
    String? updated_at,
    String? avatar,
    String? token,
    String? emergency_numbers
  }) {
    return UserNormal(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      full_name: full_name ?? this.full_name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
        emergency_numbers: emergency_numbers ?? this.emergency_numbers
    );
  }
}