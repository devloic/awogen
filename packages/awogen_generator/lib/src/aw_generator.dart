// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'package:analyzer/dart/element/element.dart';

import 'package:build/src/builder/build_step.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

import 'package:dart_appwrite/models.dart';

import 'package:awogen/AwIncludes.dart';
import 'model_visitor.dart';

import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:envied_generator/src/load_envs.dart';

class AwGenerator extends GeneratorForAnnotation<awogen> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    List<DartObject> ignoreFieldsRaw = element.metadata.first
        .computeConstantValue()!
        .getField("ignoreFields")!
        .toListValue()!;
    List<String?> ignoreFields =
        ignoreFieldsRaw.map((e) => e.toStringValue()).toList();

    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    String className = visitor.className;
    //create collection in database
    //add the collectionId to the generated class as field
    final envs = await loadEnvs(".env.awogen", (error) {
      throw Exception(
          ".env.awogen file not found . Please provide it next to pubspec.yaml.");
    });
    AwogenEnv config = AwogenEnv(
      DATABASEID: envs["DATABASEID"] ?? "",
      ENDPOINT: envs["ENDPOINT"] ?? "",
      PROJECTID: envs["PROJECTID"] ?? "",
      APIKEY: envs["APIKEY"] ?? "",
      FLAVOR: envs["FLAVOR"] ?? "",
    );

    AwServerHelper myhelper = AwServerHelper(config: config);
    Collection? collection = await myhelper.genCollection(className);
    if (collection == null) {
      throw AppwriteException("Couldn't create collection $className");
    }
    myhelper.genAttributes(visitor, collection.$id, ignoreFields);
    final buffer = StringBuffer();

    //create enum for each static const List<String> in
    Map<String, String> enums = {};

    visitor.initializers.forEach((key, value) {
      value = value as List<String>;
      String concat = "{ ";
      for (var element in value) {
        concat += "$element, ";
      }
      concat = "$concat}";
      concat = concat.replaceAll(", }", "}");
      String enumName = '${key}_awEnum';
      enums[key] = enumName;
      buffer.writeln('enum $enumName$concat');
    });

    buffer.writeln('class $className extends AwObject {');
    buffer.writeln('@override');
    buffer.writeln('String get collectionId => "${collection.$id}";');
    if (envs["APPWRITE_USE_SERVERSDK"]!.toLowerCase() == "true") {
      buffer.writeln("""
  @override
  AwServerHelper get awServerHelper => AwServerHelper(
      config: AwogenEnv(
          PROJECTID: Env.PROJECTID,
          DATABASEID: Env.DATABASEID,
          ENDPOINT: Env.ENDPOINT,
          APIKEY: Env.APIKEY));""");
    } else {
      buffer.writeln("""
@override
AwServerHelper? get awServerHelper => null;
""");
    }

    if (envs["APPWRITE_USE_CLIENTSDK"]!.toLowerCase() == "true") {
      buffer.writeln("""
  @override
  AwClientHelper? get awClientHelper => AwClientHelper(
      config: AwogenEnv(
          PROJECTID: Env.PROJECTID,
          DATABASEID: Env.DATABASEID,
          ENDPOINT: Env.ENDPOINT));
          """);
    }

    if (visitor.initializers.isNotEmpty) {
      buffer.writeln('static Map<String, List<String>> enum_values ={');
    }
    visitor.initializers.forEach((key, value) {
      String enumName = '${key}_awEnum';

      String listConcat = "  [ ";
      //create List<String> string representation
      value.forEach((element) {
        element = element.replaceAll('"', "\\\"");
        listConcat += '"$element", ';
      });
      listConcat = "$listConcat]";
      listConcat = listConcat.replaceAll(", ]", "],");

      buffer.writeln('"$enumName" : $listConcat');
    });
    if (visitor.initializers.isNotEmpty) {
      buffer.writeln('};');
    }
    buffer.writeln("""
  @override
  Map<String, List<String>> get enum_values2 => enum_values;
  """);
    String enumvaluefunctions = "";
    for (int i = 0; i < visitor.fields.length; i++) {
      String key = visitor.fields.keys.elementAt(i);

      if (visitor.initializers.containsKey(key)) {
        visitor.fields[key] = "${enums[key]!}?";
        enumvaluefunctions += """String? get${key}Value(){
           if ($key != null) {
              return enum_values2["${key}_awEnum"]![$key!.index];
          }
          return null;
          }\n""";
      }
      String typestring = visitor.fields.values.elementAt(i);
      String varname = visitor.fields.keys.elementAt(i);
      buffer.writeln(
        ' $typestring $varname;',
      );
    }
    buffer.writeln(enumvaluefunctions);
    // CONSTRUCTOR
    buffer.writeln(' $className({');
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln(
        'this.${visitor.fields.keys.elementAt(i)},',
      );
    }
    buffer.writeln("""
      collectionId,
      documentId,
     """);
    buffer.writeln('});');

    // TO MAP
    buffer.writeln('Map<String, dynamic> toMap() {');
    buffer.writeln('return {');
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln(
        "'${visitor.fields.keys.elementAt(i)}': ${visitor.fields.keys.elementAt(i)},",
      );
    }
    buffer.writeln("""
      'collectionId'  : collectionId,
      'documentId'  : documentId,
     """);
    buffer.writeln('};');
    buffer.writeln('}');

    // TO JSON
    buffer.writeln('@override');
    buffer.writeln('Map<String, dynamic> toJSON() {');
    buffer.writeln('return {');
    buffer.writeln("""
     'collectionId' : collectionId,
      'documentId' : documentId,
     """);
    visitor.fields.forEach((key, value) {
      if (value.endsWith("?")) {
        value = value.replaceAll('?', '');
      }
      if (ignoreFields.contains(key)) {
        return;
      }
      switch (value) {
        case "DateTime":
          buffer.writeln(
            "'$key': $key?.toUtc().toIso8601String(),",
          );
          break;
        case "bool":
        case "String":
        case "int":
        case "double":
          buffer.writeln(
            "'$key': $key,",
          );
          break;

        case "AwEmail":
          buffer.writeln(
            "'$key': $key?.email,",
          );
          break;
        case "AwUrl":
          buffer.writeln(
            "'$key': $key?.url,",
          );
          break;
        case "AwIp":
          buffer.writeln(
            "'$key': $key?.ip,",
          );
          break;
        case "Relation-fix":
          buffer.writeln(
            "'$key': $key,",
          );
          break;
        default:
          if (value.toString().endsWith("_awEnum")) {
            buffer.writeln(
              "'$key': $key != null ? $key!.index : null,",
            );
          }
      }
    });

    buffer.writeln('};');
    buffer.writeln('}');

    // FROM MAP
    buffer.writeln('factory $className.fromMap(Map<String, dynamic> map) {');
    buffer.writeln('return $className(');
    for (int i = 0; i < visitor.fields.length; i++) {
      String key = visitor.fields.keys.elementAt(i);
      String type = visitor.fields.values.elementAt(i);
      if (type.endsWith("?")) {
        type = type.replaceAll('?', '');
      }

      switch (type) {
        case "DateTime":
          buffer.writeln(
              "$key: map['$key'].runtimeType==$type ? map['$key'] : map['$key']!= null ? DateTime.parse(map['$key']) : null,");
          break;
        case "bool":
        case "String":
        case "int":
          buffer.writeln("$key: map['$key'],");
          break;
        case "double":
          buffer.writeln(
              "$key: map['$key'].runtimeType==$type ? map['$key'] : map['$key']!= null ? map['$key'].toDouble() : null,");
          break;

        case "AwEmail":
          buffer.writeln(
              "$key: map['$key'].runtimeType==$type ? map['$key'] : map['$key']!= null ? AwEmail(map['$key']) : null,");

          break;

        case "AwUrl":
          buffer.writeln(
              "$key: map['$key'].runtimeType==$type ? map['$key'] : map['$key']!= null ?  AwUrl(map['$key']) : null,");
          break;
        case "AwIp":
          buffer.writeln(
              "$key: map['$key'].runtimeType==$type ? map['$key'] :  map['$key']!= null ? AwIp(map['$key']) : null,");
          break;
        case "Relation-fix":
          buffer.writeln("$key: map['$key'],");
          break;
        default:
          if (type.toString().endsWith("_awEnum")) {
            buffer.writeln(
                "$key:  ${key}_awEnum.values[enum_values[\"${key}_awEnum\"]!.indexOf(map['$key'])],");
          }
          break;
      }
    }
    buffer.writeln("""
      collectionId: map['collectionId'],
      documentId: map['documentId'],
     """);
    buffer.writeln(');');
    buffer.writeln('}');
    // end FROM MAP

    // copyWith
    buffer.writeln('$className copyWith({');
    for (int i = 0; i < visitor.fields.length; i++) {
      String type = visitor.fields.values.elementAt(i);
      if (type.endsWith("?")) {
        type = type.replaceAll('?', '');
      }
      buffer.writeln(
        '$type? ${visitor.fields.keys.elementAt(i)},',
      );
    }
    buffer.writeln("""
      String? collectionId,
      String? documentId,
     """);
    buffer.writeln('}) {');
    buffer.writeln('return $className(');
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln(
        "${visitor.fields.keys.elementAt(i)}: ${visitor.fields.keys.elementAt(i)} ?? this.${visitor.fields.keys.elementAt(i)},",
      );
    }
    buffer.writeln("""
       collectionId: collectionId ?? this.collectionId,
       documentId: documentId ?? this.documentId,
     """);
    buffer.writeln(');');
    buffer.writeln('}');
    // end copyWith

    buffer.writeln("""
    @override
    AwObject toObject(dynamic doc) {
      $className result=$className.fromMap(doc.data);
      result.documentId=doc.\$id;
      return result;
    }
    """);

    buffer.writeln('}');

    return buffer.toString();
  }
}
