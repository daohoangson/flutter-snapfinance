import 'dart:async';

class AddTransactionCommand {
  final completer = Completer<String>();

  final int vnd;

  AddTransactionCommand({
    required this.vnd,
  });

  Future<String> get future => completer.future;
}
