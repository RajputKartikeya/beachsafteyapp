class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<String> favoriteBeaches;
  final List<String> reportedUpdates;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.favoriteBeaches = const [],
    this.reportedUpdates = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      favoriteBeaches: List<String>.from(json['favoriteBeaches'] ?? []),
      reportedUpdates: List<String>.from(json['reportedUpdates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'favoriteBeaches': favoriteBeaches,
      'reportedUpdates': reportedUpdates,
    };
  }
}
