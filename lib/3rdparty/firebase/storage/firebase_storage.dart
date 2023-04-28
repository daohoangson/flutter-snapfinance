import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:snapfinance/3rdparty/firebase/firebase_logger.dart';
import 'package:snapfinance/3rdparty/firebase/storage/upload_file_command.dart';

class FirebaseStorageApp extends StatefulWidget {
  final Widget child;
  final Stream<UploadFileCommand> uploadFileCommands;

  const FirebaseStorageApp({
    required this.child,
    super.key,
    required this.uploadFileCommands,
  });

  @override
  State<FirebaseStorageApp> createState() => _FirebaseStorageAppState();
}

class _FirebaseStorageAppState extends State<FirebaseStorageApp> {
  late final StreamSubscription<UploadFileCommand> _uploadFileCommands;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseStorage get _firebase => FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _uploadFileCommands = widget.uploadFileCommands.listen(_onUploadFile);
  }

  @override
  void dispose() {
    _uploadFileCommands.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onUploadFile(UploadFileCommand cmd) async {
    final startedAt = DateTime.now();
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('userId == null');
    }

    final basename = p.basename(cmd.path);
    final ref = _firebase.ref(userId).child('files').child(basename);
    final uploadTask = ref.putFile(File(cmd.path));

    await for (final snapshot in uploadTask.snapshotEvents) {
      switch (snapshot.state) {
        case TaskState.paused:
          logger.verbose('$basename: paused');
          break;
        case TaskState.running:
          cmd.progress?.add(snapshot.bytesTransferred / snapshot.totalBytes);
          break;
        case TaskState.success:
          cmd.progress?.add(1.0);
          final duration = DateTime.now().difference(startedAt);
          logger.debug(
            '_onUploadFile: bytesTransferred=${snapshot.bytesTransferred} '
            'totalBytes=${snapshot.totalBytes} duration=$duration',
          );
          break;
        case TaskState.canceled:
          cmd.progress?.addError(StateError('TaskState.canceled'));
          break;
        case TaskState.error:
          cmd.progress?.addError(StateError('TaskState.error'));
          break;
      }
    }
  }
}
