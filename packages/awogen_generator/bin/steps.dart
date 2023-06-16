import 'package:awogen/AwIncludes.dart';

import 'package:awogen/AwMisc.dart';
import 'dart:io';
import 'package:envied_generator/src/load_envs.dart';

Future<void> addDeps() async {
  printAwogenMessage("Dependencies install\n");
  List<String> packagesToAdd = [];

  /*  String hasEnvied =
      await runPipe(workingdir, 'dart', ['pub', 'deps'], 'grep', [' envied ']); */

  packagesToAdd.add("dev:build_runner:^2.3.3");
  packagesToAdd.add("dev:envied_generator");

  if (packagesToAdd.length > 0) {
    printAwogenMessage(" running: dart pub add ${packagesToAdd.join(" ")}\n");
    var result = await Process.run('dart', ['pub', 'add'] + packagesToAdd);
    stdout.write(result.stdout);
    stderr.write(result.stderr);

    printAwogenMessage(" running: dart pub get\n");

    result = await Process.run('dart', [
      'pub',
      'get',
    ]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }
}

void printErrorMissingKey(List<String> missingkeys) {
  for (var element in missingkeys) {
    switch (element) {
      case "APPWRITE_USE_CLIENTSDK":
      case "APPWRITE_USE_SERVERSDK":
      case "APPWRITE_OBFUSCATE":
        printAwogenMessage(element +
            " is missing in .env.awogen. Expected values: true/false");
        break;
      case "DATABASEID":
      case "PROJECTID":
        printAwogenMessage(element +
            " is missing in .env.awogen. Expected value: an id (String) example : 6469234df25577dd70a6 ");
        break;
      case "ENDPOINT":
        printAwogenMessage(element +
            " is missing in .env.awogen. Expected value:  an url (String) example : https://www.example.com/v1 ");
        break;
      case "APIKEY":
        printAwogenMessage(element +
            " is missing in .env.awogen. Expected value:  an apikey (String) get if from your appwrite console ");
        break;
      case "FLAVOR":
        printAwogenMessage(element +
            " is missing but not required. Suggested value:  a String that helps identify the version of an app: dev,prod,staging... ");
        break;
      default:
    }
  }
}

bool validEnvValuesFile(Map<String, String> envs) {
  List<String> allkeys = [
    "DATABASEID",
    "PROJECTID",
    "ENDPOINT",
    "APIKEY",
    "APPWRITE_USE_CLIENTSDK",
    "APPWRITE_USE_SERVERSDK",
    "APPWRITE_OBFUSCATE",
    "FLAVOR",
  ];
  List<String> missingkeys = [];
  bool validFile = true;

//check if some key is missing
  for (var element in allkeys) {
    envs.keys.contains(element) ? "" : missingkeys.add(element);
  }
  if (missingkeys.isNotEmpty) {
    if (!(missingkeys.length == 1 && missingkeys.first == "FLAVOR")) {
      validFile = false;
    }

    printErrorMissingKey(missingkeys);
  }
//check if values are valid
  envs.forEach((key, value) {
    switch (key) {
      case "APPWRITE_USE_CLIENTSDK":
      case "APPWRITE_OBFUSCATE":
      case "APPWRITE_USE_SERVERSDK":
        if (!["true", "false"].contains(value.toLowerCase())) {
          printAwogenMessage("invalid value \"$value\" for key " +
              key +
              " in .env.awogen. Expected values: true/false");
          validFile = false;
        }
        break;
      case "DATABASEID":
      case "PROJECTID":
        if (value == "") {
          printAwogenMessage(key +
              " has an empty value in .env.awogen. Expected value: an id (String) example : 6469234df25577dd70a6 ");
          validFile = false;
        }
        break;
      case "ENDPOINT":
        if (value == "") {
          printAwogenMessage(key +
              " has an empty value in .env.awogen. Expected value: an url (String) example : https://www.example.com/v1");
          validFile = false;
        }
        if (!AwUrl(value).isvalid || !value.endsWith("v1")) {
          printAwogenMessage(key +
              " value \"$value\" in .env.awogen is not a valid appwrite Endpoint URL. Expected value: an url (String) example : https://www.example.com/v1");
          validFile = false;
        }
        break;
      case "APIKEY":
        if (value.isEmpty) {
          printAwogenMessage(key +
              " has an empty value in .env.awogen. An API key is required to  map dart objects to database collections");
          validFile = false;
        }
        break;
      case "FLAVOR":
        if (value.isEmpty) {
          printAwogenMessage(key +
              " has an empty value in .env.awogen (key is not required). Suggested value:  a String that helps identify the version of an app: dev,prod,staging... ");
        }

        break;
      default:
    }
  });

  if (!validFile) {
    printAwogenMessage("Invalid .env.awogen");
    printAwogenMessage("Please edit .env.awogen ");
  } else {
    printAwogenMessage("valid .env.awogen");
    printDartBuild();
  }
  return validFile;
}

Future<Map<String, String>> loadAwogenEnvs() async {
  Directory current = Directory.current;

  bool fileexists = await File(current.path + '/.env.awogen').exists();
  Future<Map<String, String>> envs;
  if (!fileexists) {
    printAwogenMessage(
        ".env.awogen not found, please run dart run awogen:install to create it");
    printAwogenMessage("Exiting");
    exit(0);
  }
  envs = loadEnvs(current.path + '/.env.awogen', (error) {
    throw Exception(".env.awogen file not found ");
  });
  return envs;
}

String createEnvAwogenEnvContent(
    String PROJECTID,
    String DATABASEID,
    String ENDPOINT,
    String APIKEY,
    String APPWRITE_OBFUSCATE,
    bool include_clientsdk,
    bool include_serversdk) {
  var env_awogen_string = """
PROJECTID=$PROJECTID
DATABASEID=$DATABASEID
ENDPOINT=$ENDPOINT
FLAVOR=dev
APIKEY=$APIKEY
APPWRITE_USE_CLIENTSDK=${include_clientsdk.toString()}
APPWRITE_USE_SERVERSDK=${include_serversdk.toString()}
APPWRITE_OBFUSCATE=$APPWRITE_OBFUSCATE
  """;
  return env_awogen_string;
}

String createEnvAwogenDartContent(String obfuscate, bool includeServersdk) {
  var envAwogenDartString = """
import 'package:envied/envied.dart';

part 'env.awogen.g.dart';

@Envied(path: ".env.awogen")
abstract class Env {
  @EnviedField(varName: 'PROJECTID', obfuscate: $obfuscate)
  static final String PROJECTID = _Env.PROJECTID;
  @EnviedField(varName: 'DATABASEID', obfuscate: $obfuscate)
  static final String DATABASEID = _Env.DATABASEID;
  @EnviedField(varName: 'ENDPOINT', obfuscate: $obfuscate)
  static final String ENDPOINT = _Env.ENDPOINT;
  @EnviedField(varName: 'FLAVOR', obfuscate: false)
  static final String FLAVOR = _Env.FLAVOR;
  @EnviedField(varName: 'APIKEY', obfuscate: $obfuscate)
  static final String APIKEY = ${includeServersdk ? "_Env.APIKEY" : "\"\""} ;
   
  }
   """;
  return envAwogenDartString;
}

Future<void> writeEnvAwogenDartFile(
  String env_awogen_dart_string,
) async {
  Directory current = Directory.current;

  String finalpath = current.path + '/lib/awogen/';
  //creating lib/awogen/env.awogen.dart
  await File(finalpath + 'env.awogen.dart')
      .writeAsString(env_awogen_dart_string);
  printAwogenMessage("env.awogen.dart file created/updated in: " +
      finalpath +
      'env.awogen.dart');
}

Future<void> updateAwogenEnvFile(String env_awogen_string) async {
  Directory current = Directory.current;

  await File(current.path + '/.env.awogen')
      .rename(current.path + '/.env.awogen.old');

  await File(current.path + '/.env.awogen').writeAsString(env_awogen_string);

  await File(current.path + '/.env.awogen.old').delete();
  printAwogenMessage(
      "existing env.awogen file updated in:" + current.path + '/.env.awogen');
}

Future<void> createAwogenDirectory() async {
  Directory current = Directory.current;

  String finalpath = '${current.path}/lib/awogen/';

  bool envdartDirectory = await Directory(finalpath).exists();
  if (!envdartDirectory) {
    Directory newdir = Directory(finalpath);
    await newdir.create();
    printAwogenMessage("awogen directory created: $finalpath ");
  }
}

String inputObfuscateValue(String APPWRITE_OBFUSCATE) {
  String? yesno;
  String obfuscate = "false";
  bool validValueObfuscate = APPWRITE_OBFUSCATE.toLowerCase() == "true" ||
      APPWRITE_OBFUSCATE.toLowerCase() == "false";
  String useObfuscateFileValue = "";
  if (validValueObfuscate) {
    useObfuscateFileValue =
        " or Enter to keep existing value: ${APPWRITE_OBFUSCATE.toLowerCase()}";
  }
  while (
      yesno != "y" && yesno != "n" && !(yesno == "" && validValueObfuscate)) {
    printAwogenMessage(
        "Obfuscate appwrite PROJECTID, DATABASEID, ENDPOINT, APIKEY keys ? y/n $useObfuscateFileValue");
    yesno = stdin.readLineSync();
  }
  if (yesno?.toLowerCase() == "y") {
    obfuscate = "true";
  }
  if (yesno?.toLowerCase() == "n") {
    obfuscate = "false";
  }
  if (yesno == "") {
    obfuscate = APPWRITE_OBFUSCATE.toLowerCase();
  }
  return obfuscate;
}

bool inputClientSdkValue(
  String APPWRITE_USE_CLIENTSDK,
) {
  String? yesno;
  String useFileValue = "";
  bool includeClientsdk = false;
  bool validValueClient = APPWRITE_USE_CLIENTSDK.toLowerCase() == "true" ||
      APPWRITE_USE_CLIENTSDK.toLowerCase() == "false";
  if (validValueClient) {
    useFileValue =
        " or Enter to keep existing value: ${APPWRITE_USE_CLIENTSDK.toLowerCase()}";
  }
  while (yesno != "y" && yesno != "n" && !(yesno == "" && validValueClient)) {
    printAwogenMessage(
        "Include appwrite flutter client sdk in your app? y/n $useFileValue ");

    yesno = stdin.readLineSync();
  }
  if (yesno?.toLowerCase() == "y") {
    includeClientsdk = true;
  }
  if (yesno?.toLowerCase() == "n") {
    includeClientsdk = false;
  }
  if (yesno == "") {
    includeClientsdk = APPWRITE_USE_CLIENTSDK.toLowerCase() == "true";
  }
  return includeClientsdk;
}

bool inputServerSdkValue(
  String APPWRITE_USE_SERVERSDK,
) {
  String? yesno;
  String useFileValue = "";
  bool includeClientsdk = false;
  bool validValueClient = APPWRITE_USE_SERVERSDK.toLowerCase() == "true" ||
      APPWRITE_USE_SERVERSDK.toLowerCase() == "false";
  if (validValueClient) {
    useFileValue =
        " or Enter to keep existing value: ${APPWRITE_USE_SERVERSDK.toLowerCase()}";
  }
  while (yesno != "y" && yesno != "n" && !(yesno == "" && validValueClient)) {
    printAwogenMessage(
        "Include appwrite server sdk in your app? y/n $useFileValue ");

    yesno = stdin.readLineSync();
  }
  if (yesno?.toLowerCase() == "y") {
    includeClientsdk = true;
  }
  if (yesno?.toLowerCase() == "n") {
    includeClientsdk = false;
  }
  if (yesno == "") {
    includeClientsdk = APPWRITE_USE_SERVERSDK.toLowerCase() == "true";
  }
  return includeClientsdk;
}

void printDartBuild() {
  printAwogenMessage("closing");
  printAwogenMessage("You can now manually run: ");
  print("dart run build_runner build -d\n\n");
}
