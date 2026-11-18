import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parcel_atlas/application/activity/usecase/undo_change_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_target_enum.dart';
import 'package:parcel_atlas/domain/activity/interface/activity_repository_interface.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';

import '../../support/fakes.dart';

class _Auth extends Mock implements AuthRepositoryInterface {}

class _Activity extends Mock implements ActivityRepositoryInterface {}

void main() {
  const MemberEntity member = MemberEntity(
    id: 'uid',
    name: 'Tester',
    username: 'tester',
    role: MemberRoleEnum.member,
  );
  const MemberEntity admin = MemberEntity(
    id: 'boss',
    name: 'Boss',
    username: 'boss',
    role: MemberRoleEnum.admin,
  );
  late _Auth auth;
  late _Activity activity;
  late UndoChangeUseCase undo;

  ActivityEntity line(
    ActivityActionEnum action, {
    String? changeId = 'split',
  }) => ActivityEntity(
    id: '${action.name}-line',
    action: action,
    target: ActivityTargetEnum.drawnParcel,
    targetId: 'd',
    label: 'Tarla',
    stamp: testStamp,
    changeId: changeId,
  );

  setUpAll(() => registerFallbackValue(member));

  setUp(() {
    auth = _Auth();
    activity = _Activity();
    undo = UndoChangeUseCase(auth, activity);
    when(() => auth.currentMember).thenReturn(member);
    when(() => activity.undo(any(), actor: any(named: 'actor')))
        .thenAnswer((_) async => const Right('undo'));
  });

  test('a wrong edit is undone from the history', () async {
    when(() => activity.linesOf('edit')).thenAnswer(
      (_) async => Right(<ActivityEntity>[
        line(ActivityActionEnum.updated, changeId: 'edit'),
      ]),
    );
    final Either<BaseException, String> result = await undo(changeId: 'edit');
    expect(result.right, 'undo');
    verify(() => activity.undo('edit', actor: member)).called(1);
  });

  test("the undo button takes back the member's own newest change", () async {
    when(() => activity.latestChangeBy('uid'))
        .thenAnswer((_) async => const Right('edit'));
    when(() => activity.linesOf('edit')).thenAnswer(
      (_) async => Right(<ActivityEntity>[
        line(ActivityActionEnum.deleted, changeId: 'edit'),
      ]),
    );
    expect((await undo()).isRight, isTrue);
    verify(() => activity.undo('edit', actor: member)).called(1);
  });

  test(
    'undoing a split, which deletes its new pieces, is for the main account',
    () async {
      when(() => activity.linesOf('split')).thenAnswer(
        (_) async => Right(<ActivityEntity>[
          line(ActivityActionEnum.updated),
          line(ActivityActionEnum.created),
        ]),
      );
      final Either<BaseException, String> refused = await undo(
        changeId: 'split',
      );
      expect(refused.left.cause?.errorCode?.code, CauseCode.adminOnlyCode);
      verifyNever(() => activity.undo(any(), actor: any(named: 'actor')));

      when(() => auth.currentMember).thenReturn(admin);
      expect((await undo(changeId: 'split')).isRight, isTrue);
    },
  );

  test('a registry lookup or an old change cannot be undone', () async {
    when(() => activity.latestChangeBy('uid'))
        .thenAnswer((_) async => const Right(null));
    expect(
      (await undo()).left.cause?.errorCode?.code,
      CauseCode.nothingToUndoCode,
    );
    when(() => activity.linesOf('old')).thenAnswer(
      (_) async => Right(<ActivityEntity>[
        line(ActivityActionEnum.updated, changeId: null),
      ]),
    );
    expect(
      (await undo(changeId: 'old')).left.cause?.errorCode?.code,
      CauseCode.nothingToUndoCode,
    );
  });
}
