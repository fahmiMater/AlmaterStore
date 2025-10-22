import 'dart:io';

abstract class UiConsole {
  void printMenu();

  String prompt(String label) {
    stdout.write('$label: ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}
