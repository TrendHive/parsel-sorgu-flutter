import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Stores a list of registry parcels by number, in one go.
///
/// ```bash
/// dart run tool/import_parcels.dart <username> <neighbourhoodId> \
///     <block>/<parcel> [<block>/<parcel> ...] [--cache <dir>]
/// ```
///
/// For a family that has its parcel numbers on paper: each number is looked
/// up in the registry once and stored exactly as the app stores a lookup —
/// the same document, the same "queried" activity line, signed by the member
/// who runs the tool, and checked by the same Firestore rules.
///
/// The registry is rationed, so the tool is careful with it: a parcel the
/// store already has is skipped without a lookup, every answer is kept in
/// the `--cache` folder so a second run never asks twice, calls are spaced
/// by [_pause], and the first refusal (403) stops the run.
///
/// The password is read without echo and goes only to Firebase Auth.
/// The tool is plain Dart (the app's own mappers import Flutter), so the
/// reading of a registry answer mirrors `TkgmParcelMapper` and the document
/// layout mirrors `OfficialParcelDocumentMapper` and
/// `FirestoreStoreService.log`; change them together.
Future<void> main(List<String> args) async {
  final int cacheFlag = args.indexOf('--cache');
  final Directory cache = Directory(
    cacheFlag >= 0 && cacheFlag + 1 < args.length
        ? args[cacheFlag + 1]
        : '${Directory.systemTemp.path}/parcel-atlas-registry',
  )..createSync(recursive: true);
  final List<String> positional = <String>[
    for (int i = 0; i < args.length; i++)
      if (i != cacheFlag && i != cacheFlag + 1) args[i],
  ];
  final int? neighbourhoodId = positional.length > 2
      ? int.tryParse(positional[1])
      : null;
  final List<String> numbers = positional.skip(2).toList();
  if (neighbourhoodId == null ||
      numbers.any((String n) => !RegExp(r'^[^/\s]+/[^/\s]+$').hasMatch(n))) {
    stderr.writeln(
      'usage: dart run tool/import_parcels.dart <username> <neighbourhoodId> '
      '<block>/<parcel> [...] [--cache <dir>]',
    );
    exitCode = _usageError;
    return;
  }

  stdout.writeln('1/3 registry answers (cache: ${cache.path})');
  final List<_Parcel> records = <_Parcel>[];
  for (final String number in numbers) {
    final _Parcel? record = await _answer(cache, neighbourhoodId, number);
    if (record == null) {
      stderr.writeln('stopped at $number; run again later to continue');
      break;
    }
    records.add(record);
    stdout.writeln(
      '   ${record.label}  ${record.area} m2  ${record.text('mevkii')}',
    );
  }

  stdout.writeln('2/3 sign in as ${positional.first}');
  final (int status, Map<String, dynamic> session) = await _send(
    'POST',
    Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword'
      '?key=${_webApiKey()}',
    ),
    <String, Object>{
      'email': '${positional.first.trim().toLowerCase()}@$_emailDomain',
      'password': _askPassword(),
      'returnSecureToken': true,
    },
  );
  if (status != HttpStatus.ok) {
    stderr.writeln('sign-in refused');
    exitCode = _usageError;
    return;
  }
  final String token = session['idToken'] as String;
  final Map<String, Object> stamp = <String, Object>{
    'memberId': <String, String>{'stringValue': session['localId'] as String},
    'memberName': <String, String>{
      'stringValue': '${session['displayName'] ?? positional.first}',
    },
  };

  stdout.writeln('3/3 storing');
  int stored = 0;
  for (final _Parcel record in records) {
    final (int exists, _) = await _send(
      'GET',
      Uri.parse('$_documents/officialParcels/${record.key}'),
      null,
      token: token,
    );
    if (exists == HttpStatus.ok) {
      stdout.writeln('   ${record.label} already stored, skipped');
      continue;
    }
    final (int written, Map<String, dynamic> answer) = await _send(
      'POST',
      Uri.parse('$_documents:commit'),
      _commit(record, stamp),
      token: token,
    );
    if (written != HttpStatus.ok) {
      stderr.writeln('   ${record.label} not stored: ${jsonEncode(answer)}');
      exitCode = _storeError;
      continue;
    }
    stored++;
    stdout.writeln('   ${record.label} stored');
  }
  stdout.writeln('done: $stored stored, ${records.length - stored} skipped');
}

const int _usageError = 64;
const int _storeError = 70;
const Duration _pause = Duration(seconds: 3);
const String _project = 'parcel-info';
const String _emailDomain = 'members.parcel-atlas.app';
const String _registry =
    'https://cbsapi.tkgm.gov.tr/megsiswebapi.v3.1/api/parsel';
const String _database = 'projects/$_project/databases/(default)/documents';
const String _documents =
    'https://firestore.googleapis.com/v1/projects/$_project/databases/%28default%29/documents';

Future<_Parcel?> _answer(
  Directory cache,
  int neighbourhoodId,
  String number,
) async {
  final File file = File(
    '${cache.path}/$neighbourhoodId-${number.replaceAll('/', '-')}.json',
  );
  if (!file.existsSync()) {
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.getUrl(
        Uri.parse('$_registry/$neighbourhoodId/$number'),
      );
      final HttpClientResponse response = await request.close();
      final String body = await response.transform(utf8.decoder).join();
      if (response.statusCode != HttpStatus.ok) {
        stderr.writeln('   $number: registry answered ${response.statusCode}');
        return null;
      }
      file.writeAsStringSync(body);
    } finally {
      client.close();
    }
    await Future<void>.delayed(_pause);
  }
  final _Parcel? record = _Parcel.read(
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
  );
  if (record == null) {
    stderr.writeln('   $number: the registry answer holds no parcel');
  }
  return record;
}

/// One registry answer, read the way `TkgmParcelMapper` reads it.
final class _Parcel {
  const _Parcel(this.properties, this.corners);

  final Map<String, dynamic> properties;

  final List<(double, double)> corners;

  static _Parcel? read(Map<String, dynamic> feature) {
    final Object? properties = feature['properties'];
    final Object? geometry = feature['geometry'];
    final Object? rings = geometry is Map<String, dynamic>
        ? geometry['coordinates']
        : null;
    if (properties is! Map<String, dynamic> ||
        rings is! List ||
        rings.isEmpty ||
        rings.first is! List) {
      return null;
    }
    final List<(double, double)> corners = <(double, double)>[
      for (final Object? pair in rings.first as List)
        if (pair is List && pair.length >= 2)
          ((pair[1] as num).toDouble(), (pair[0] as num).toDouble()),
    ];
    if (corners.length > 1 && corners.first == corners.last) {
      corners.removeLast();
    }
    final _Parcel parcel = _Parcel(properties, corners);
    return corners.length < 3 ||
            int.tryParse(parcel.text('mahalleId')) == null ||
            parcel.block.isEmpty ||
            parcel.number.isEmpty
        ? null
        : parcel;
  }

  String text(String key) => '${properties[key] ?? ''}';

  String get block => text('adaNo').trim();

  String get number => text('parselNo').trim();

  int get neighborhoodId => int.parse(text('mahalleId'));

  String get key => '$neighborhoodId-$block-$number'.replaceAll('/', '-');

  String get label => '$block/$number';

  double? get area => properties['alan'] == null
      ? null
      : double.tryParse(text('alan').replaceAll('.', '').replaceAll(',', '.'));
}

Map<String, Object> _commit(_Parcel record, Map<String, Object> stamp) {
  Map<String, Object> text(String value) => <String, Object>{
    'stringValue': value,
  };
  Map<String, Object> map(Map<String, Object> fields) => <String, Object>{
    'mapValue': <String, Object>{'fields': fields},
  };
  final double? area = record.area;
  return <String, Object>{
    'writes': <Object>[
      <String, Object>{
        'update': <String, Object>{
          'name': '$_database/officialParcels/${record.key}',
          'fields': <String, Object>{
            'neighborhoodId': <String, Object>{
              'integerValue': '${record.neighborhoodId}',
            },
            'block': text(record.block),
            'parcel': text(record.number),
            'cityName': text(record.text('ilAd')),
            'districtName': text(record.text('ilceAd')),
            'neighborhoodName': text(record.text('mahalleAd')),
            'locality': text(record.text('mevkii')),
            'quality': text(record.text('nitelik')),
            'sheet': text(record.text('pafta')),
            'landStatus': text(record.text('zeminKmdurum')),
            'status': text(record.text('durum')),
            if (area != null)
              'registryAreaSquareMeters': <String, Object>{'doubleValue': area},
            'outline': <String, Object>{
              'arrayValue': <String, Object>{
                'values': <Object>[
                  for (final (double lat, double lng) in record.corners)
                    map(<String, Object>{
                      'lat': <String, Object>{'doubleValue': lat},
                      'lng': <String, Object>{'doubleValue': lng},
                    }),
                ],
              },
            },
            'attributes': map(<String, Object>{
              for (final String name in record.properties.keys)
                name: text(record.text(name)),
            }),
            'created': map(stamp),
            'refreshed': map(stamp),
          },
        },
        'currentDocument': <String, Object>{'exists': false},
        'updateTransforms': <Object>[_now('created.at'), _now('refreshed.at')],
      },
      <String, Object>{
        'update': <String, Object>{
          'name': '$_database/activity/${_newId()}',
          'fields': <String, Object>{
            'action': text('queried'),
            'target': text('officialParcel'),
            'targetId': text(record.key),
            'label': text(record.label),
            'by': map(stamp),
          },
        },
        'currentDocument': <String, Object>{'exists': false},
        'updateTransforms': <Object>[_now('by.at')],
      },
    ],
  };
}

Map<String, String> _now(String path) => <String, String>{
  'fieldPath': path,
  'setToServerValue': 'REQUEST_TIME',
};

String _newId() {
  const String alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random.secure();
  return <String>[
    for (int i = 0; i < 20; i++) alphabet[random.nextInt(alphabet.length)],
  ].join();
}

String _webApiKey() {
  final RegExpMatch? web = RegExp(
    r"static const FirebaseOptions web = FirebaseOptions\(\s*apiKey: '([^']+)'",
  ).firstMatch(File('lib/firebase_options.dart').readAsStringSync());
  if (web == null) {
    stderr.writeln('no web apiKey in lib/firebase_options.dart');
    exit(_usageError);
  }
  return web.group(1)!;
}

String _askPassword() {
  bool hidden = true;
  try {
    stdin.echoMode = false;
  } on StdinException {
    hidden = false;
    stderr.writeln(
      'warning: this terminal cannot hide input, so what you type will be '
      'visible; run it in a real Terminal to keep the password hidden',
    );
  }
  try {
    stdout.write('password: ');
    final String password = stdin.readLineSync() ?? '';
    if (hidden) stdout.writeln();
    return password;
  } finally {
    if (hidden) stdin.echoMode = true;
  }
}

Future<(int, Map<String, dynamic>)> _send(
  String method,
  Uri uri,
  Map<String, Object>? body, {
  String? token,
}) async {
  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request = await client.openUrl(method, uri);
    request.headers.contentType = ContentType.json;
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) request.write(jsonEncode(body));
    final HttpClientResponse response = await request.close();
    final String text = await response.transform(utf8.decoder).join();
    final Object? decoded = text.isEmpty ? null : jsonDecode(text);
    return (
      response.statusCode,
      decoded is Map<String, dynamic> ? decoded : <String, dynamic>{},
    );
  } finally {
    client.close();
  }
}
