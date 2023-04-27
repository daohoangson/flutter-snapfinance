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
    } else {
      throw Exception('Unknown state: $state');
    }
  }

  SnapState reset() => SnapState.initial();

  SnapState setVnd(int newVnd);
}

abstract class Step1 implements SnapState {
  int get vnd;
}

abstract class Step2 implements Step1 {
  String get photoPath;
}

class StateFailure extends SnapState {
  final dynamic error;
  final SnapState previous;

  const StateFailure._(this.error, this.previous);

  @override
  SnapState setVnd(int newVnd) => StateInitiatingCamera._(vnd: newVnd);
}

class StateInitiatingCamera extends SnapState {
  final int? vnd;

  const StateInitiatingCamera._({this.vnd});

  StateInitializedCamera initialized() => StateInitializedCamera._(vnd: vnd);

  @override
  SnapState setVnd(int newVnd) => StateInitiatingCamera._(vnd: newVnd);
}

class StateInitializedCamera extends SnapState {
  final int? vnd;

  const StateInitializedCamera._({this.vnd});

  @override
  StateInitializedCamera setVnd(int newVnd) =>
      StateInitializedCamera._(vnd: newVnd);

  StateTakingPhoto takePhoto(int vnd) => StateTakingPhoto._(vnd);
}

class StateTakingPhoto extends SnapState implements Step1 {
  @override
  final int vnd;

  const StateTakingPhoto._(this.vnd);

  @override
  StateTakingPhoto setVnd(int newVnd) => StateTakingPhoto._(newVnd);

  SnapState tookPhoto(String photoPath) {
    if (vnd > 0) {
      return StateReviewing._(photoPath, vnd);
    } else {
      return StateProcessingPhoto._(photoPath, vnd);
    }
  }
}

class StateProcessingPhoto extends SnapState implements Step2 {
  @override
  final String photoPath;

  @override
  final int vnd;

  const StateProcessingPhoto._(this.photoPath, this.vnd);

  StateReviewing completed() => StateReviewing._(photoPath, vnd);

  @override
  SnapState setVnd(int newVnd) => throw UnimplementedError();
}

class StateReviewing extends SnapState implements Step2 {
  @override
  final String photoPath;

  @override
  final int vnd;

  const StateReviewing._(this.photoPath, this.vnd);

  bool get canContinue => vnd > 0;

  @override
  SnapState setVnd(int newVnd) => StateReviewing._(photoPath, newVnd);
}
