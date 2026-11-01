abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ImportFailure extends Failure {
  const ImportFailure(super.message);
}

class CategoryProtectedFailure extends Failure {
  const CategoryProtectedFailure(super.message);
}
