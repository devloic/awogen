import 'dart:convert';
import 'dart:io';

//inspired from
//https://stackoverflow.com/questions/59746768/dart-how-to-pass-data-from-one-process-to-another-via-streams
//and
//https://dev.to/5422m4n/dart-io---streaming-strings-in-a-nutshell-275g
Future<String> runPipe(String workingDirectory, String command1,
    List<String> args1, String command2, List<String> args2) async {
  final procCommand1 =
      await Process.start(command1, args1, workingDirectory: workingDirectory);
  final procCommand2 =
      await Process.start(command2, args2, workingDirectory: workingDirectory);

  // the output from ls is sent to the input of head
  await procCommand1.stdout.pipe(procCommand2.stdin).catchError(
    // ignore: avoid_types_on_closure_parameters
    (Object e) {
      // ignore broken pipe after head process exit
    },
    test: (e) => e is SocketException && (e.osError!.message == 'Broken pipe'),
  );

  /// the output of head is sent to the console.
  /// We can't use the normal pipe command is it will close stdout
  /// which will stop our app from outputting any further text to stdout.
  ///  print(await myStream
  ///
  var lines =
      procCommand2.stdout.transform(utf8.decoder); //.transform(LineSplitter());
  String finalresult = "";

  try {
    await for (var line in lines) {
      finalresult += line;
    }
  } catch (e) {
    print(e);
  }
  return Future.value(finalresult);
}

//await pipeNoClose(head.stdout, stdout);
/* Future<void> _pipeNoClose(Stream<List<int>> stdout, IOSink stdin) async {
  print(await stdout.toSet());
  return stdin.addStream(stdout);
}
 */