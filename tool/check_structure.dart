import 'dart:io';

/// The project's rules the analyzer cannot see, checked in one pass.
///
/// Run it with `dart run tool/check_structure.dart`; CI and the pre-commit
/// hook run it between `flutter analyze` and `flutter test`. Every problem
/// names the file and the CLAUDE.md rule it breaks, so the message is its
/// own fix.
///
/// [_knownDebt] lists files written before a rule existed. It only shrinks:
/// fix a file and remove it from the list; never add one without the owner's
/// approval.
void main() {
  final List<File> dart = _files(
    'lib',
    '.dart',
  ).where((File f) => !_generated(f.path)).toList();
  final List<String> problems = <String>[
    for (final File file in dart) ..._layerImports(file),
    for (final File file in dart) ..._oneDeclaration(file),
    for (final File file in dart) ..._kindFolder(file),
    for (final File file in dart) ..._getIt(file),
    for (final File file in <File>[
      ...dart,
      ..._files('test', '.dart'),
      ..._files('tool', '.dart'),
    ])
      ..._englishCode(file),
    for (final File file in _markdown()) ..._englishDocs(file),
  ];
  if (problems.isEmpty) {
    stdout.writeln('check_structure: clean');
    return;
  }
  stderr
    ..writeln('check_structure: ${problems.length} problem(s)')
    ..writeAll(problems, '\n')
    ..writeln();
  exitCode = 1;
}

const Map<String, List<String>> _mayImport = <String, List<String>>{
  'core': <String>['core'],
  'core_ui': <String>['core', 'core_ui'],
  'domain': <String>['core', 'domain'],
  'domain_ui': <String>['core', 'core_ui', 'domain', 'domain_ui'],
  'application': <String>['core', 'domain', 'application'],
  'infrastructure': <String>['core', 'domain', 'infrastructure'],
  'presentation': <String>[
    'core',
    'core_ui',
    'domain',
    'domain_ui',
    'application',
    'presentation',
  ],
};

const Map<String, String> _kindSuffix = <String, String>{
  'domain/entity': '_entity.dart',
  'domain/value_object': '_value_object.dart',
  'domain/read_model': '_read_model.dart',
  'domain/enum': '_enum.dart',
  'domain/interface': '_interface.dart',
  'domain/rule': '_rules.dart',
  'domain/validator': '_validator.dart',
  'application/usecase': '_usecase.dart',
  'infrastructure/repository': '_repository.dart',
  'infrastructure/mapper': '_mapper.dart',
  'infrastructure/dto': '_dto.dart',
};

const Set<String> _knownDebt = <String>{'lib/core_ui/values/base_dimens.dart'};

final RegExp _turkish = RegExp(
  '[\\u00e7\\u011f\\u0131\\u00f6\\u015f\\u00fc\\u00c7\\u011e\\u0130\\u00d6\\u015e\\u00dc]',
);

List<File> _files(String root, String extension) {
  final Directory directory = Directory(root);
  if (!directory.existsSync()) return <File>[];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith(extension))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));
}

bool _generated(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('firebase_options.dart') ||
    path.contains('/l10n/app_localizations');

String _layerOf(String path) {
  final List<String> parts = path.split('/');
  return parts.length > 2 ? parts[1] : '';
}

List<String> _layerImports(File file) {
  final String layer = _layerOf(file.path);
  final List<String>? allowed = _mayImport[layer];
  if (allowed == null) return <String>[];
  final String text = file.readAsStringSync();
  final List<String> problems = <String>[
    for (final RegExpMatch m in RegExp(
      r"^import 'package:parcel_atlas/(\w+)/",
      multiLine: true,
    ).allMatches(text))
      if (!allowed.contains(m.group(1)))
        '${file.path}  $layer may not import ${m.group(1)} (CLAUDE.md, layer table)',
  ];
  if (layer == 'domain' &&
      RegExp(
        r"^import 'package:(flutter|material_ui|cupertino_ui)/",
        multiLine: true,
      ).hasMatch(text)) {
    problems.add(
      '${file.path}  domain imports Flutter (CLAUDE.md, layer table)',
    );
  }
  if (layer == 'application' &&
      RegExp(
        r"^import 'package:(material_ui|cupertino_ui|flutter/widgets\.dart|flutter/material\.dart)",
        multiLine: true,
      ).hasMatch(text)) {
    problems.add(
      '${file.path}  application imports widgets (CLAUDE.md, layer table)',
    );
  }
  return problems;
}

List<String> _oneDeclaration(File file) {
  if (_knownDebt.contains(file.path) || file.path == 'lib/main.dart') {
    return <String>[];
  }
  final String text = file.readAsStringSync();
  if (RegExp(r'^part of ', multiLine: true).hasMatch(text)) return <String>[];
  final List<String> public = <String>[
    for (final RegExpMatch m in RegExp(
      r'^(?:(?:abstract|sealed|final|base|interface|mixin)\s+)*(class|enum|mixin|extension|typedef)\s+(\w+)',
      multiLine: true,
    ).allMatches(text))
      if (!m.group(2)!.startsWith('_')) m.group(2)!,
  ];
  if (public.length <= 1) return <String>[];
  final String first = public.first;
  final bool sealedFamily =
      RegExp('sealed class $first\\b').hasMatch(text) &&
      public
          .skip(1)
          .every(
            (String name) =>
                RegExp('class $name extends $first\\b').hasMatch(text),
          );
  final bool fieldsTypedef =
      public.length == 2 &&
      public.last == '${first.replaceAll('ValueObject', '')}Fields';
  final bool valueObjectFields =
      public.length == 2 &&
      first.endsWith('ValueObject') &&
      public.last.endsWith('Fields');
  return sealedFamily || fieldsTypedef || valueObjectFields
      ? <String>[]
      : <String>[
          '${file.path}  one public declaration per file, found ${public.join(', ')} (rule 1)',
        ];
}

List<String> _kindFolder(File file) {
  final List<String> parts = file.path.split('/');
  if (parts.length < 5) return <String>[];
  final String suffix =
      _kindSuffix['${parts[1]}/${parts[parts.length - 2]}'] ?? '';
  if (suffix.isEmpty || file.path.endsWith(suffix)) return <String>[];
  return <String>[
    '${file.path}  ${parts[parts.length - 2]}/ holds only *$suffix (CLAUDE.md, folders)',
  ];
}

List<String> _getIt(File file) {
  final String path = file.path;
  final bool allowed =
      path == 'lib/main.dart' ||
      path.contains('/di/') ||
      path.endsWith('_page.dart');
  return !allowed && file.readAsStringSync().contains('getIt')
      ? <String>['$path  getIt outside main.dart, di/ and a page (rule 12)']
      : <String>[];
}

List<String> _englishCode(File file) {
  final List<String> lines = file.readAsLinesSync();
  return <String>[
    for (int i = 0; i < lines.length; i++)
      if (_turkish.hasMatch(lines[i]))
        '${file.path}:${i + 1}  Turkish outside the language files (rule 13)',
  ];
}

Iterable<File> _markdown() => <File>[
  for (final String root in <String>['.', 'docs', '.claude'])
    if (Directory(root).existsSync())
      ...Directory(root)
          .listSync(recursive: root != '.')
          .whereType<File>()
          .where((File f) => f.path.endsWith('.md'))
          .where((File f) => !f.path.contains('/build/')),
];

List<String> _englishDocs(File file) {
  final List<String> problems = <String>[];
  bool inCode = false;
  final List<String> lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    if (line.trimLeft().startsWith('```')) {
      inCode = !inCode;
      continue;
    }
    if (inCode) continue;
    final String prose = line
        .replaceAll(RegExp('"[^"]*"'), '')
        .replaceAll(RegExp('`[^`]*`'), '');
    if (_turkish.hasMatch(prose)) {
      problems.add(
        '${file.path}:${i + 1}  Turkish in a doc outside a "quote" or `code` (rule 13)',
      );
    }
  }
  return problems;
}
