class User {
  late String? key;
  late String name;
  late String? photoUrl;

  User({
    required this.name,
    this.key,
    this.photoUrl,
  });

  factory User.from(dynamic data) {
    return User(
      key: data?['key'],
      name: data?['name'],
      photoUrl: data?['photoUrl'],
    );
  }

  Map<String, String?> toMap() {
    return {
      "key": key,
      "name": name,
      "photoUrl": photoUrl
    };
  }
}