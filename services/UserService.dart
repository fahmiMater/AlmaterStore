// services/user_service.dart
import '../core/app_response.dart';
import '../models/User.dart';
import '../repositories/user_repository.dart';

class Userservice {
  // Singleton + InMemory repo
  static final Userservice _instance =
      Userservice._internal(InMemoryUserRepository());

  final UserRepository _repo;

  Userservice._internal(this._repo);
  factory Userservice() => _instance;

  // --------- عمليات CRUD أساسية ---------

  AppResponse<User> addUser({
    required String id,
    required String name,
    required String email,
    required String password,
  }) {
    if (_repo.exists(id)) {
      return AppResponse.failure(
        'User with id $id already exists.',
        code: ErrorCode.alreadyExists,
      );
    }

    if (name.trim().isEmpty) {
      return AppResponse.failure('User name is required.', code: ErrorCode.invalidInput);
    }

    if (email.trim().isEmpty || !email.contains('@')) {
      return AppResponse.failure('Valid email is required.', code: ErrorCode.invalidInput);
    }

    if (password.trim().length < 4) {
      return AppResponse.failure('Password must be at least 4 characters.', code: ErrorCode.invalidInput);
    }

    final u = User(id: id, name: name.trim(), email: email.trim(), password: password);
    _repo.add(u);

    return AppResponse.success(u, message: 'User $name added successfully.');
  }

  AppResponse<List<User>> getAllUsers() {
    final all = _repo.getAll();
    return AppResponse.success(
      List<User>.unmodifiable(all),
      message: 'Fetched ${all.length} users.',
    );
  }

  User? byId(String id) => _repo.byId(id);

  AppResponse<User> deleteUser(String id) {
    final current = _repo.byId(id);
    if (current == null) {
      return AppResponse.failure(
        'User with id $id not found.',
        code: ErrorCode.notFound,
      );
    }

    final ok = _repo.removeById(id);
    if (!ok) {
      return AppResponse.failure('User not found.', code: ErrorCode.notFound);
    }

    return AppResponse.success(current, message: 'User ${current.name} deleted.');
  }

  Future<AppResponse<User>> updateUser(
    String id,
    Map<String, dynamic> userData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final original = _repo.byId(id);
    if (original == null) {
      return AppResponse.failure(
        'User with id $id not found.',
        code: ErrorCode.notFound,
      );
    }

    final newName = (userData['name'] as String?)?.trim() ?? original.name;
    final newEmail = (userData['email'] as String?)?.trim() ?? original.email;
    final newPassword = (userData['password'] as String?)?.trim() ?? original.password;

    if (newName.isEmpty || newEmail.isEmpty) {
      return AppResponse.failure(
        'Name and email are required.',
        code: ErrorCode.invalidInput,
      );
    }

    final updated = User(
      id: original.id,
      name: newName,
      email: newEmail,
      password: newPassword,
    );

    final ok = _repo.update(updated);
    if (!ok) {
      return AppResponse.failure('Failed to update user.', code: ErrorCode.unknown);
    }

    return AppResponse.success(updated, message: 'User updated successfully.');
  }

  // --------- تحقق بسيط لتسجيل الدخول ---------
  AppResponse<User> login(String email, String password) {
    final users = _repo.getAll();
    final user = users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => User(id: '', name: '', email: '', password: ''),
    );

    if (user.id.isEmpty) {
      return AppResponse.failure('Invalid email or password.', code: ErrorCode.invalidInput);
    }

    return AppResponse.success(user, message: 'Welcome back, ${user.name}!');
  }
}
