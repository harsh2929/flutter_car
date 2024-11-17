 

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

   factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

   Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
