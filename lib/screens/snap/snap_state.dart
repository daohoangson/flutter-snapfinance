abstract class SnapState {
  const SnapState();

  factory SnapState.initial() => const StateInitiatingCamera._();

  StateFailure failure(dynamic error) => StateFailure._(error, this);

  T map<T>({
    required T Function(StateFailure state) onFailure,
    required T Function(StateInitiatingCamera state) onInitiatingCamera,
    required T Function(StateInitializedCamera state) onInitializedCamera,
    required T Function(StateTakingPhoto state) onTakingPhoto,
    required T Function(StateProcessingPhoto state) onProcessingPhoto,
    required T Function(StateReviewing state) onReviewing,
    required T Function(StateAddingTransaction state) onAddingTransaction,
    required T Function(StateAddedTransaction state) onAddedTransaction,
  }) {
    final state = this;
    if (state is StateFailure) {
      return onFailure(state);
    } else if (state is StateInitiatingCamera) {
      return onInitiatingCamera(state);
    } else if (state is StateInitializedCamera) {
      return onInitializedCamera(state);
    } else if (state is StateTakingPhoto) {
      return onTakingPhoto(state);
    } else if (state is StateProcessingPhoto) {
      return onProcessingPhoto(state);
    } else if (state is StateReviewing) {
      return onReviewing(state);
    } else if (state is StateAddingTransaction) {
      return onAddingTransaction(state);
    } else if (state is StateAddedTransaction) {
      return onAddedTransaction(state);
    } else {
      throw Exception('Unknown state: $state');
    }
  }

  SnapState reset() => SnapState.initial();
}

abstract class Step1 implements SnapState {
  int get vnd;
}

abstract class Step2 implements Step1 {
  String get photoPath;
}

abstract class Step3 implements Step2 {
  String get transactionId;
}

class StateFailure extends SnapState {
  final dynamic error;
  final SnapState previous;

  const StateFailure._(this.error, this.previous);

  StateInitiatingCamera setVnd(int newVnd) =>
      StateInitiatingCamera._(vnd: newVnd);
}

class StateInitiatingCamera extends SnapState {
  final int? vnd;

  const StateInitiatingCamera._({this.vnd});

  StateInitializedCamera initialized() => StateInitializedCamera._(vnd: vnd);

  StateInitiatingCamera setVnd(int newVnd) =>
      StateInitiatingCamera._(vnd: newVnd);
}

class StateInitializedCamera extends SnapState {
  final int? vnd;

  const StateInitializedCamera._({this.vnd});

  StateInitializedCamera setVnd(int newVnd) =>
      StateInitializedCamera._(vnd: newVnd);

  StateTakingPhoto takePhoto(int vnd) => StateTakingPhoto._(vnd);
}

class StateTakingPhoto extends SnapState implements Step1 {
  @override
  final int vnd;

  const StateTakingPhoto._(this.vnd);

  StateTakingPhoto setVnd(int newVnd) => StateTakingPhoto._(newVnd);

  Step2 tookPhoto(String photoPath) {
    if (vnd > 0) {
      return StateReviewing._(photoPath, vnd);
    } else {
      return StateProcessingPhoto._(photoPath);
    }
  }
}

class StateProcessingPhoto extends SnapState implements Step2 {
  @override
  final String photoPath;

  @override
  int get vnd => 0;

  const StateProcessingPhoto._(this.photoPath);

  StateReviewing completed() => StateReviewing._(photoPath, vnd);
}

class StateReviewing extends SnapState implements Step2 {
  @override
  final String photoPath;

  @override
  final int vnd;

  const StateReviewing._(this.photoPath, this.vnd);

  bool get canContinue => vnd > 0;

  StateAddingTransaction confirm() => StateAddingTransaction._(photoPath, vnd);

  StateReviewing setVnd(int newVnd) => StateReviewing._(photoPath, newVnd);
}

class StateAddingTransaction extends SnapState implements Step2 {
  @override
  final String photoPath;

  @override
  final int vnd;

  const StateAddingTransaction._(this.photoPath, this.vnd);

  StateAddedTransaction addedTransaction(String transactionId) =>
      StateAddedTransaction._(photoPath, transactionId, vnd);
}

class StateAddedTransaction extends SnapState implements Step3 {
  @override
  final String photoPath;

  @override
  final String transactionId;

  @override
  final int vnd;

  const StateAddedTransaction._(this.photoPath, this.transactionId, this.vnd);
}
