import 'package:cloud_firestore/cloud_firestore.dart';

class UserDto {
  final String userId;

  const UserDto({
    required this.userId,
  });

  factory UserDto._fromFirebase(String id, Map<String, dynamic>? data) =>
      UserDto(userId: id);

  Map<String, Object?> _toFirebase() {
    return {};
  }
}

extension RefUsers on FirebaseFirestore {
  CollectionReference<UserDto> get refUsers =>
      collection('users').withConverter<UserDto>(
        fromFirestore: (snapshot, _) =>
            UserDto._fromFirebase(snapshot.id, snapshot.data()),
        toFirestore: (userDto, _) => userDto._toFirebase(),
      );

  DocumentReference<UserDto> refUserById([String? userId]) =>
      refUsers.doc(userId);
}
