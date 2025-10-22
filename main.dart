import 'dart:io';

import 'UI/Admin_UI.dart';
import 'UI/UI_Consol.dart';

import 'UI/User_UI.dart';
import 'UI/Delivary_UI.dart';

void main() {
  final app = ConsoleApp();
  app.printMenu();
}
class ConsoleApp extends UiConsole {
  final UiConsole adminUi = AdminUi();
  final UiConsole userUi = UserUi();
  final UiConsole deliveryUi = DelivaryUi();  
  
  @override
  printMenu() {
    print('Welcome to AlmaterStore Console App');
    while (true) {
      
      print('\nSelect your role:');
      print('1) Admin');
      print('2) User');
      print('3) Delivery Man');
      print('0) Exit');
      final choice = prompt('Enter choice');
      switch (choice) {
        case '1':
          stdout.write('you selsct 1'); // Clear console
          adminUi.printMenu();
          break;
        case '2':
          userUi.printMenu();
          break;
        case '3':
          deliveryUi.printMenu();
          break;
        case '0':
          print('Goodbye!');
          return;
        default:
          print('Invalid option.');
      }
    }
  }
 
 
 
} 