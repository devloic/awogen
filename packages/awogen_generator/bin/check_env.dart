import 'steps.dart';

Future<void> main(List<String> arguments) async {
  Map<String, String> envs = await loadAwogenEnvs();

  validEnvValuesFile(envs);
}
