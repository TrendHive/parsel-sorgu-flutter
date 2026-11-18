import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/person/usecase/save_person_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';

import '../../support/fakes.dart';

class _Auth extends Mock implements AuthRepositoryInterface {}

class _Persons extends Mock implements PersonRepositoryInterface {}

void main() {
  const MemberEntity member = MemberEntity(
    id: 'uid',
    name: 'Tester',
    username: 'tester',
    role: MemberRoleEnum.member,
  );
  late _Auth auth;
  late _Persons persons;
  late SavePersonUseCase save;

  setUpAll(() {
    registerFallbackValue(testPerson('fallback'));
    registerFallbackValue(member);
  });

  setUp(() {
    auth = _Auth();
    persons = _Persons();
    save = SavePersonUseCase(auth, persons);
    when(() => auth.currentMember).thenReturn(member);
    when(() => persons.save(any(), actor: any(named: 'actor')))
        .thenAnswer((_) async => const Right('id'));
  });

  test('a new child is saved under its parent', () async {
    final Either<BaseException, String> result = await save(
      name: ' New ',
      parentId: 'father',
      passesToChildren: false,
      note: '',
      family: testFamily,
    );
    expect(result.isRight, isTrue);
    final PersonEntity saved =
        verify(() => persons.save(captureAny(), actor: member)).captured.single
            as PersonEntity;
    expect((saved.name, saved.parentId, saved.isNew), ('New', 'father', true));
  });

  test('making a grandfather the child of his grandchild is refused', () async {
    final Either<BaseException, String> result = await save(
      name: 'grandfather',
      parentId: 'a',
      passesToChildren: true,
      note: '',
      family: testFamily,
      existing: testFamily.first,
    );
    expect(result.left.cause?.errorCode?.code, CauseCode.familyLoopCode);
    verifyNever(() => persons.save(any(), actor: any(named: 'actor')));
  });

  test('nobody signed in means nothing is saved', () async {
    when(() => auth.currentMember).thenReturn(null);
    final Either<BaseException, String> result = await save(
      name: 'x',
      parentId: null,
      passesToChildren: false,
      note: '',
      family: testFamily,
    );
    expect(result.left.cause?.errorCode?.code, CauseCode.notSignedInCode);
  });

  test('a wife is saved married to her husband', () async {
    final Either<BaseException, String> result = await save(
      name: 'mother',
      parentId: null,
      spouseId: 'father',
      passesToChildren: false,
      note: '',
      family: testFamily,
    );
    expect(result.isRight, isTrue);
    final PersonEntity saved =
        verify(() => persons.save(captureAny(), actor: member)).captured.single
            as PersonEntity;
    expect(saved.spouseId, 'father');
  });

  test(
    'marrying someone already married to another person is refused',
    () async {
      final Either<BaseException, String> result = await save(
        name: 'second',
        parentId: null,
        spouseId: 'father',
        passesToChildren: false,
        note: '',
        family: <PersonEntity>[
          ...testFamily,
          testPerson('mother', spouseId: 'father'),
        ],
      );
      expect(
        result.left.cause?.errorCode?.code,
        CauseCode.spouseNotAllowedCode,
      );
      verifyNever(() => persons.save(any(), actor: any(named: 'actor')));
    },
  );
}
