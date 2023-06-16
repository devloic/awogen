import 'dart:io';

import 'package:awogen/AwMisc.dart';

import 'steps.dart';

Future<void> main(List<String> arguments) async {
  printAwogenMessage("Starting env.awogen.dart update\n");

  Map<String, String> envs = await loadAwogenEnvs();

  validEnvValuesFile(envs) == false ? exit(1) : "";

  String DATABASEID = "";
  String PROJECTID = "";
  String ENDPOINT = "";
  String APIKEY = "";
  String APPWRITE_USE_CLIENTSDK = "";
  String APPWRITE_OBFUSCATE = "";
  String APPWRITE_USE_SERVERSDK = "";

  printAwogenMessage(".env.awogen found, importing KEYS");
  DATABASEID = envs["DATABASEID"] ?? "";
  PROJECTID = envs["PROJECTID"] ?? "";
  ENDPOINT = envs["ENDPOINT"] ?? "";
  APIKEY = envs["APIKEY"] ?? "";
  APPWRITE_USE_CLIENTSDK = envs["APPWRITE_USE_CLIENTSDK"] ?? "";
  APPWRITE_OBFUSCATE = envs["APPWRITE_OBFUSCATE"] ?? "";
  APPWRITE_USE_SERVERSDK = envs["APPWRITE_USE_SERVERSDK"] ?? "";

  bool includeClientsdk = false;
  if (APPWRITE_USE_CLIENTSDK.toLowerCase() == "true") {
    includeClientsdk = true;
  }
  bool includeServersdk = false;
  if (APPWRITE_USE_SERVERSDK.toLowerCase() == "true") {
    includeServersdk = true;
  }
  String obfuscate = "false";
  if (APPWRITE_OBFUSCATE.toLowerCase() == "true") {
    obfuscate = "true";
  }

  String envAwogenDartString =
      createEnvAwogenDartContent(obfuscate, includeServersdk);
  await writeEnvAwogenDartFile(envAwogenDartString);

  String envAwogenString = createEnvAwogenEnvContent(PROJECTID, DATABASEID,
      ENDPOINT, APIKEY, APPWRITE_OBFUSCATE, includeClientsdk, includeServersdk);
  //replacing file
  await updateAwogenEnvFile(envAwogenString);

  printDartBuild();
}
