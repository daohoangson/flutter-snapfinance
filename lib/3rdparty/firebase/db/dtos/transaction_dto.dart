import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapfinance/3rdparty/firebase/db/dtos/user_dto.dart';

class TransactionDto {
  final DateTime? createdAt;
  final String? transactionId;
  final int? vnd;

  const TransactionDto({
    required this.createdAt,
    required this.transactionId,
    required this.vnd,
  });

  factory TransactionDto._fromFirebase(String id, Map<String, dynamic>? data) {
    return TransactionDto(
      createdAt: (data?["createdAt"] as Timestamp?)?.toDate(),
      transactionId: id,
      vnd: data?["vnd"],
    );
  }

  Map<String, Object?> _toFirebase() {
    return {
      if (createdAt != null) "createdAt": Timestamp.fromDate(createdAt!),
      if (vnd != null) "vnd": vnd,
    };
  }
}

extension RefTransactions on DocumentReference<UserDto> {
  CollectionReference<TransactionDto> get refTransactions =>
      collection('transactions').withConverter<TransactionDto>(
        fromFirestore: (snapshot, _) =>
            TransactionDto._fromFirebase(snapshot.id, snapshot.data()),
        toFirestore: (transactionDto, _) => transactionDto._toFirebase(),
      );

  DocumentReference<TransactionDto> refTransactionById(
          [String? transactionId]) =>
      refTransactions.doc(transactionId);
}
