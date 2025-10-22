import 'dart:io';

import 'UI/Admin_UI.dart';
import 'UI/UI_Consol.dart';
import 'UI/User_UI.dart';
import 'UI/Delivary_UI.dart';
import 'core/seeds.dart';

void main() {
   SeedData.bootstrap();
  final app = ConsoleApp();
  app.printMenu();
}

class ConsoleApp extends UiConsole {
  // نُبقي الواجهات كما هي (تُنشئ خدماتها داخليًا عبر الـSingletons)
  final UiConsole adminUi = AdminUi();
  final UiConsole userUi = UserUi();
  final UiConsole deliveryUi = DelivaryUi();

  @override
  void printMenu() {
    _printWelcome();

    while (true) {
      print('\nSelect your role:');
      print('1) Admin');
      print('2) User');
      print('3) Delivery Man');
      print('0) Exit');

      final choice = prompt('Enter choice');

      switch (choice) {
        case '1':
          _clearScreen();
          print('> Admin mode');
          adminUi.printMenu();
          _pauseAndClear();
          break;

        case '2':
          _clearScreen();
          print('> User mode');
          userUi.printMenu();
          _pauseAndClear();
          break;

        case '3':
          _clearScreen();
          print('> Delivery mode');
          deliveryUi.printMenu();
          _pauseAndClear();
          break;

        case '0':
        case 'q':
        case 'Q':
        case 'exit':
        case 'EXIT':
          print('Goodbye!');
          return;

        default:
          print('Invalid option.');
      }
    }
  }

  void _printWelcome() {
    _clearScreen();
    print('==========================================');
    print('  Welcome to AlmaterStore Console App');
    print('==========================================');
  }

  /// تنظيف الشاشة (اختياري/تقريبي يعمل في معظم البيئات الطرفية)
  void _clearScreen() {
    // على معظم الطرفيات: ANSI escape codes
    if (stdout.hasTerminal) {
      stdout.write('\x1B[2J\x1B[0;0H');
    } else {
      // fallback بسيط
      print(List.filled(50, '').join('\n'));
    }
  }

  /// انتظار Enter ثم تنظيف الشاشة
  void _pauseAndClear() {
    stdout.write('\nPress ENTER to go back to the main menu...');
    stdin.readLineSync();
    _clearScreen();
    _printWelcome();
  }
}
