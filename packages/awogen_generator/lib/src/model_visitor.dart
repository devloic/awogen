import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';

import 'package:analyzer/dart/element/visitor.dart';

/* print('1 + 1 = ...');
    var line = stdin.readLineSync(encoding: utf8);
    print(line?.trim() == '2' ? 'Yup!' : 'Nope :('); */

class ModelVisitor extends SimpleElementVisitor<void> {
  String className = '';
  Map<String, dynamic> fields = {};
  Map<String, dynamic> initializers = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    final returnType = element.returnType.toString();
    className = returnType.replaceFirst('*', '');
    if (className.startsWith('_')) {
      className = className.replaceFirst('_', '');
    }
  }

  @override
  void visitFieldElement(FieldElement element) {
    fields[element.name] = element.type.toString().replaceFirst('*', '');
    var initializer = element.computeConstantValue();

    if (initializer != null) {
      initializers[element.name] = initializer
          .toListValue()!
          .map((DartObject e) => e.toStringValue() ?? "")
          .toList();
    }
  }
}
