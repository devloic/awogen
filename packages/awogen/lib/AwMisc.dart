import 'package:chalkdart/chalk.dart';

void printAwogenMessage(String message) {
  print(chalk.bold.underline("\n[AWOGEN]") + chalk.green.bold(" $message\n"));
}
