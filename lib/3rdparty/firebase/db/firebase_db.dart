import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/firebase/db/add_transaction_command.dart';
import 'package:snapfinance/3rdparty/firebase/db/dtos/transaction_dto.dart';
import 'package:snapfinance/3rdparty/firebase/db/dtos/user_dto.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_logger.dart';

class FirebaseDbApp extends StatefulWidget {
  final Widget child;
  final Stream<AddTransactionCommand> addTransactionCommands;

  const FirebaseDbApp({
    required this.addTransactionCommands,
    required this.child,
    super.key,
  });

  @override
  State<FirebaseDbApp> createState() => _FirebaseDbAppState();
}

class _FirebaseDbAppState extends State<FirebaseDbApp> {
  late final StreamSubscription<AddTransactionCommand> _addTransactionCommands;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firebase => FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _addTransactionCommands =
        widget.addTransactionCommands.listen(_onAddTransaction);
  }

  @override
  void dispose() {
    _addTransactionCommands.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onAddTransaction(AddTransactionCommand cmd) async {
    final startedAt = DateTime.now();
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('userId == null');
    }

    final ref = _firebase.refUserById(userId).refTransactionById();
    final dto = TransactionDto(
      createdAt: startedAt,
      transactionId: ref.id,
      vnd: cmd.vnd,
    );
    ref.set(dto).then(
      (value) {
        cmd.completer.complete(dto.transactionId);
        final duration = DateTime.now().difference(startedAt);
        logger.debug(
          '_onAddTransaction: path=${ref.path} '
          'createdAt=${dto.createdAt} duration=$duration',
        );
      },
      onError: cmd.completer.completeError,
    );
  }
}
