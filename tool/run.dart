import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final file = File('.env');
  if (!file.existsSync()) {
    stderr.writeln('Crie .env a partir de .env.example.');
    exitCode = 1;
    return;
  }
  final env = <String, String>{};
  for (final line in await file.readAsLines()) {
    final match = RegExp(r'^\s*([A-Z_]+)\s*=\s*(.*?)\s*$').firstMatch(line);
    if (match == null) continue;
    var value = match[2]!;
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    env[match[1]!] = value;
  }
  final url = env['SUPABASE_URL'] ?? env['NEXT_PUBLIC_SUPABASE_URL'] ?? '';
  final key =
      env['SUPABASE_PUBLISHABLE_KEY'] ??
      env['NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY'] ??
      env['SUPABASE_ANON_KEY'] ??
      '';
  if (url.isEmpty || key.isEmpty || key.startsWith('sb_secret_')) {
    stderr.writeln('Configure SUPABASE_URL e uma chave pública no .env.');
    exitCode = 1;
    return;
  }
  if (key.split('.').length == 3) {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(key.split('.')[1]))),
    );
    if (payload['role'] != 'anon') {
      stderr.writeln('Chaves administrativas não são permitidas.');
      exitCode = 1;
      return;
    }
  } else if (!key.startsWith('sb_publishable_')) {
    stderr.writeln('Chave pública inválida.');
    exitCode = 1;
    return;
  }
  final config = File('.dart_tool/volttech_public_config.json');
  await config.parent.create(recursive: true);
  await config.writeAsString(
    jsonEncode({'SUPABASE_URL': url, 'SUPABASE_PUBLISHABLE_KEY': key}),
  );
  final command = args.isEmpty ? ['run', '-d', 'chrome'] : args;
  final process = await Process.start(
    Platform.isWindows ? 'flutter.bat' : 'flutter',
    [...command, '--dart-define-from-file=${config.path}'],
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
