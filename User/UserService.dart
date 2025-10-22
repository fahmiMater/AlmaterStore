import '../core/app_response.dart';
import 'User.dart';

class Userservice {
  // This class is responsible for managing user-related operations.
  final List<User> users = [];

  AppResponse<User> addUser(User user) {
    final exists = users.any((element) => element.id == user.id);
    if (exists) {
      return AppResponse.failure(
        'User with id ${user.id} already exists.',
        code: ErrorCode.alreadyExists,
      );
    }

    final emailExists =
        users.any((element) => element.email.toLowerCase() == user.email.toLowerCase());
    if (emailExists) {
      return AppResponse.failure(
        'Email ${user.email} already registered.',
        code: ErrorCode.conflict,
      );
    }

    users.add(user);
    return AppResponse.success(
      user,
      message: 'User ${user.name} registered.',
    );
  }

  AppResponse<List<User>> getallUsers() {
    return AppResponse.success(
      List<User>.unmodifiable(users),
      message: 'Fetched ${users.length} users.',
    );
  }

  AppResponse<User> deleteUser(String userId) {
    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1) {
      return AppResponse.failure(
        'User with id $userId not found.',
        code: ErrorCode.notFound,
      );
    }

    final removed = users.removeAt(index);
    return AppResponse.success(
      removed,
      message: 'User ${removed.name} removed.',
    );
  }

  Future<AppResponse<User>> getUserDetails(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    User? user;
    for (final element in users) {
      if (element.id == userId) {
        user = element;
        break;
      }
    }

    if (user == null) {
      return AppResponse.failure(
        'User with id $userId not found.',
        code: ErrorCode.notFound,
      );
    }

    return AppResponse.success(user, message: 'User details loaded.');
  }

  // Example method to update user information
  Future<AppResponse<User>> updateUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1) {
      return AppResponse.failure(
        'User with id $userId not found.',
        code: ErrorCode.notFound,
      );
    }

    final current = users[index];
    final updated = User(
      id: current.id,
      name: (userData['name'] as String?) ?? current.name,
      email: (userData['email'] as String?) ?? current.email,
      password: (userData['password'] as String?) ?? current.password,
    );

    users[index] = updated;
    return AppResponse.success(
      updated,
      message: 'User ${updated.name} updated.',
    );
  }
}
