


import 'dart:io';

abstract class UiConsole {
  
  printMenu();
  prompt(String label){
     stdout.write('$label: ');
    return stdin.readLineSync()?.trim() ?? '';
  }
}
