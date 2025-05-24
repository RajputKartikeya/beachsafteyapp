class BeachUpdate {
  final String id;
  final String beachId;
  final String userId;
  final String userName;
  final String description;
  final String? photoUrl;
  final bool isSafe;
  final DateTime timestamp;
  final Map<String, dynamic> conditions;

  BeachUpdate({
    required this.id,
    required this.beachId,
    required this.userId,
    required this.userName,
    required this.description,
    this.photoUrl,
    required this.isSafe,
    required this.timestamp,
    required this.conditions,
  });

  factory BeachUpdate.fromJson(Map<String, dynamic> json) {
    return BeachUpdate(
      id: json['id'] as String,
      beachId: json['beachId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      description: json['description'] as String,
      photoUrl: json['photoUrl'] as String?,
      isSafe: json['isSafe'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      conditions: json['conditions'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beachId': beachId,
      'userId': userId,
      'userName': userName,
      'description': description,
      'photoUrl': photoUrl,
      'isSafe': isSafe,
      'timestamp': timestamp.toIso8601String(),
      'conditions': conditions,
    };
  }
}
