import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/infrastructure/activity/mapper/activity_document_mapper.dart';

void main() {
  final Timestamp changedAt = Timestamp(1763470000, 0);
  final Timestamp later = Timestamp(1763470100, 0);

  Map<String, dynamic> line(String action) => <String, dynamic>{
    'action': action,
    'by': <String, dynamic>{'memberId': 'm', 'at': changedAt},
  };

  Map<String, dynamic> record(Timestamp updated) => <String, dynamic>{
    'name': 'Tarla',
    'updated': <String, dynamic>{'memberId': 'm', 'at': updated},
  };

  test('a record still as the change left it can be undone', () {
    expect(
      ActivityDocumentMapper.leftAsChanged(
        now: record(changedAt),
        line: line('updated'),
      ),
      isTrue,
    );
    expect(
      ActivityDocumentMapper.leftAsChanged(now: null, line: line('deleted')),
      isTrue,
    );
  });

  test('undo does not overwrite an edit made since, even from an old app that '
      'writes no undo data', () {
    expect(
      ActivityDocumentMapper.leftAsChanged(
        now: record(later),
        line: line('updated'),
      ),
      isFalse,
    );
    expect(
      ActivityDocumentMapper.leftAsChanged(
        now: record(later),
        line: line('deleted'),
      ),
      isFalse,
    );
    expect(
      ActivityDocumentMapper.leftAsChanged(now: null, line: line('created')),
      isFalse,
    );
  });
}
