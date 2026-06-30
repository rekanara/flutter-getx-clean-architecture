abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class TimeoutFailure extends Failure {
  TimeoutFailure([String message = 'Connection timeout']) : super(message);
}

class NoConnectionFailure extends Failure {
  NoConnectionFailure([String message = 'No internet connection']) : super(message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([String message = 'Unauthorized session']) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}
