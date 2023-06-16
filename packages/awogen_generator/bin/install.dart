import 'dart:io';
import 'package:awogen/AwMisc.dart';
import 'package:envied_generator/src/load_envs.dart';

import 'steps.dart';

Future<void> main(List<String> arguments) async {
  printAwogenMessage("Starting awogen install");

  await addDeps();

  String DATABASEID = "";
  String PROJECTID = "";
  String ENDPOINT = "";
  String APIKEY = "";
  String APPWRITE_USE_CLIENTSDK = "";
  String APPWRITE_OBFUSCATE = "";
  String APPWRITE_USE_SERVERSDK = "";

  Directory current = Directory.current;

  bool envFileExists = await File('${current.path}/.env.awogen').exists();

  if (envFileExists) {
    final envs = await loadEnvs('${current.path}/.env.awogen', (error) {
      throw Exception(".env.awogen file not found ");
    });

    printAwogenMessage(
        "Found existing .env.awogen, importing DATABASEID,PROJECTID,APIKEY,ENDPOINT keys");
    DATABASEID = envs["DATABASEID"] ?? "";
    PROJECTID = envs["PROJECTID"] ?? "";
    ENDPOINT = envs["ENDPOINT"] ?? "";
    APIKEY = envs["APIKEY"] ?? "";
    APPWRITE_USE_CLIENTSDK = envs["APPWRITE_USE_CLIENTSDK"] ?? "";
    APPWRITE_OBFUSCATE = envs["APPWRITE_OBFUSCATE"] ?? "";
    APPWRITE_USE_SERVERSDK = envs["APPWRITE_USE_SERVERSDK"] ?? "";
  }

  bool includeServersdk = inputServerSdkValue(APPWRITE_USE_SERVERSDK);
  bool includeClientsdk = inputClientSdkValue(APPWRITE_USE_CLIENTSDK);
  String obfuscate = inputObfuscateValue(APPWRITE_OBFUSCATE);
  var envAwogenDartString =
      createEnvAwogenDartContent(obfuscate, includeServersdk);
  await createAwogenDirectory();
  writeEnvAwogenDartFile(envAwogenDartString);
  String envAwogenString = createEnvAwogenEnvContent(PROJECTID, DATABASEID,
      ENDPOINT, APIKEY, APPWRITE_OBFUSCATE, includeClientsdk, includeServersdk);

  //replacing or creating file
  if (envFileExists) {
    await updateAwogenEnvFile(envAwogenString);
  } else {
    Directory current = Directory.current;

    await File('${current.path}/.env.awogen').writeAsString(envAwogenString);
    printAwogenMessage(
        "env.awogen file created in: " + current.path + '/.env.awogen');
  }

  printAwogenMessage("closing");
  printAwogenMessage("You can now manually run: ");
  print("dart run build_runner build -d\n\n");

  /* result = await Process.run('flutter',
      ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs']);
  stdout.write(result.stdout);
  stderr.write(result.stderr); */
}
