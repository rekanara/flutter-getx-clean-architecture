abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class TimeoutFailure extends Failure {
  TimeoutFailure([super.message = 'Connection timeout']);
}

class NoConnectionFailure extends Failure {
  NoConnectionFailure([super.message = 'No internet connection']);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure([super.message = 'Unauthorized session']);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}
