import 'dart:convert';
import 'dart:io';

/// Adds a family member: the only way an account is ever created.
///
/// ```bash
/// dart run tool/add_member.dart <username> "<Display name>" [--admin]
/// ```
///
/// 1. Asks for the password twice, without echo. It goes to Firebase Auth
///    and nowhere else — not to disk, not to the terminal.
/// 2. Creates the sign-in account `<username>@members.parcel-atlas.app` (or
///    signs in to it, if it already exists, to re-run the remaining steps).
/// 3. Adds the account's id to the member list in `firestore.rules` (and to
///    the admin list with `--admin`) and deploys the rules with the Firebase
///    CLI.
/// 4. Writes the member's profile (`members/{uid}`: name, username, role)
///    signed in as that member — the rules accept it only because step 3
///    listed the account.
///
/// The repository holds only account ids; names live in the store.
Future<void> main(List<String> args) async {
  final List<String> positional = args
      .where((String a) => !a.startsWith('--'))
      .toList();
  if (positional.length != _arguments) {
    stderr.writeln(
      'usage: dart run tool/add_member.dart <username> "<Display name>" [--admin]',
    );
    exitCode = _usageError;
    return;
  }
  final String username = positional.first.trim().toLowerCase();
  final String name = positional.last.trim();
  final bool admin = args.contains('--admin');
  if (!RegExp(r'^[a-z0-9._-]{3,32}$').hasMatch(username)) {
    stderr.writeln('username: 3-32 of a-z 0-9 . _ -');
    exitCode = _usageError;
    return;
  }

  final String password = _askPassword();
  final String apiKey = _webApiKey();
  final String email = '$username@$_emailDomain';

  stdout.writeln('1/4 account $email');
  final Map<String, dynamic> session = await _signUpOrIn(
    apiKey,
    email,
    password,
  );
  final String uid = session['localId'] as String;
  final String token = session['idToken'] as String;
  await _post(_identity('accounts:update', apiKey), <String, Object>{
    'idToken': token,
    'displayName': name,
    'returnSecureToken': false,
  });

  stdout.writeln('2/4 member list in firestore.rules');
  _listInRules(uid, admin: admin);

  stdout.writeln('3/4 deploying rules');
  final Process deploy = await Process.start('firebase', <String>[
    'deploy',
    '--only',
    'firestore:rules',
    '--project',
    _project,
  ], mode: ProcessStartMode.inheritStdio);
  if (await deploy.exitCode != 0) {
    stderr.writeln(
      'rules deploy failed — fix and re-run; nothing else changed',
    );
    exitCode = _deployError;
    return;
  }

  stdout.writeln('4/4 profile');
  await _writeProfile(
    uid: uid,
    token: token,
    name: name,
    username: username,
    role: admin ? 'admin' : 'member',
  );
  stdout.writeln('done: $name can sign in as "$username"');
}

const int _arguments = 2;
const int _usageError = 64;
const int _deployError = 70;
const int _retries = 10;
const Duration _retryDelay = Duration(seconds: 6);
const String _project = 'parcel-info';
const String _emailDomain = 'members.parcel-atlas.app';
const String _rules = 'firestore.rules';

String _askPassword() {
  if (!stdin.hasTerminal) {
    stderr.writeln('run this in a terminal: the password is read without echo');
    exit(_usageError);
  }
  stdin.echoMode = false;
  try {
    stdout.write('password (min 8): ');
    final String first = stdin.readLineSync() ?? '';
    stdout.write('\nrepeat: ');
    final String second = stdin.readLineSync() ?? '';
    stdout.writeln();
    if (first.length < 8 || first != second) {
      stderr.writeln('passwords must match and be at least 8 characters');
      exit(_usageError);
    }
    return first;
  } finally {
    stdin.echoMode = true;
  }
}

String _webApiKey() {
  final String options = File('lib/firebase_options.dart').readAsStringSync();
  final RegExpMatch? web = RegExp(
    r"static const FirebaseOptions web = FirebaseOptions\(\s*apiKey: '([^']+)'",
  ).firstMatch(options);
  if (web == null) {
    stderr.writeln('no web apiKey in lib/firebase_options.dart');
    exit(_usageError);
  }
  return web.group(1)!;
}

Uri _identity(String method, String apiKey) =>
    Uri.parse('https://identitytoolkit.googleapis.com/v1/$method?key=$apiKey');

Future<Map<String, dynamic>> _signUpOrIn(
  String apiKey,
  String email,
  String password,
) async {
  final Map<String, Object> body = <String, Object>{
    'email': email,
    'password': password,
    'returnSecureToken': true,
  };
  final (int status, Map<String, dynamic> created) = await _post(
    _identity('accounts:signUp', apiKey),
    body,
  );
  if (status == HttpStatus.ok) return created;
  final String error =
      '${(created['error'] as Map<String, dynamic>?)?['message']}';
  if (!error.startsWith('EMAIL_EXISTS')) {
    stderr.writeln('sign-up refused: $error');
    exit(_usageError);
  }
  final (int signInStatus, Map<String, dynamic> session) = await _post(
    _identity('accounts:signInWithPassword', apiKey),
    body,
  );
  if (signInStatus != HttpStatus.ok) {
    stderr.writeln('account exists and the password does not match it');
    exit(_usageError);
  }
  return session;
}

void _listInRules(String uid, {required bool admin}) {
  final File file = File(_rules);
  String text = file.readAsStringSync();
  String add(String function, String text) {
    final RegExp pattern = RegExp(
      'function $function\\(\\) \\{ return \\[([^\\]]*)\\]; \\}',
    );
    final RegExpMatch match = pattern.firstMatch(text)!;
    final Set<String> ids = <String>{
      for (final String raw in match.group(1)!.split(','))
        if (raw.trim().isNotEmpty) raw.trim().replaceAll("'", ''),
      uid,
    };
    final String list = (ids.toList()..sort())
        .map((String id) => "'$id'")
        .join(', ');
    return text.replaceFirst(
      pattern,
      'function $function() { return [$list]; }',
    );
  }

  text = add('memberIds', text);
  if (admin) text = add('adminIds', text);
  file.writeAsStringSync(text);
}

Future<void> _writeProfile({
  required String uid,
  required String token,
  required String name,
  required String username,
  required String role,
}) async {
  final Uri uri = Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$_project/databases/%28default%29/documents/members/$uid',
  );
  final Map<String, Object> body = <String, Object>{
    'fields': <String, Object>{
      'name': <String, String>{'stringValue': name},
      'username': <String, String>{'stringValue': username},
      'role': <String, String>{'stringValue': role},
    },
  };
  for (int attempt = 1; attempt <= _retries; attempt++) {
    final (int status, Map<String, dynamic> answer) = await _send(
      'PATCH',
      uri,
      body,
      token: token,
    );
    if (status == HttpStatus.ok) return;
    stdout.writeln(
      '   rules still propagating ($status), retry $attempt/$_retries',
    );
    if (attempt == _retries) {
      stderr.writeln('profile not written: ${jsonEncode(answer)}');
      exit(_deployError);
    }
    await Future<void>.delayed(_retryDelay);
  }
}

Future<(int, Map<String, dynamic>)> _post(Uri uri, Map<String, Object> body) =>
    _send('POST', uri, body);

Future<(int, Map<String, dynamic>)> _send(
  String method,
  Uri uri,
  Map<String, Object> body, {
  String? token,
}) async {
  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request = await client.openUrl(method, uri);
    request.headers.contentType = ContentType.json;
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    request.write(jsonEncode(body));
    final HttpClientResponse response = await request.close();
    final String text = await response.transform(utf8.decoder).join();
    return (
      response.statusCode,
      text.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(text) as Map<String, dynamic>,
    );
  } finally {
    client.close();
  }
}
