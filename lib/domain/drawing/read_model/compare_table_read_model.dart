import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_line_read_model.dart';
import 'package:parcel_atlas/domain/drawing/read_model/compare_owner_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// The parcels a member put side by side, and what each owner holds of them.
///
/// [lines] are the parcels in the order they were added. [owners] has one
/// total per recorded owner — their share of each parcel's real and deed
/// area — largest real area first (family order on a tie), then the unowned rest. A drawing's
/// owners are the ones recorded on it; inheritance is the holdings page's
/// concern. [realTotal] and [registryTotal] sum the lines.
final class CompareTableReadModel extends BaseReadModel {
  factory CompareTableReadModel.of(
    List<CompareLineReadModel> lines,
    List<PersonEntity> persons,
  ) {
    final Map<String?, ({double real, double registry})> sums =
        <String?, ({double real, double registry})>{};
    void add(String? id, double fraction, CompareLineReadModel line) {
      final ({double real, double registry}) before =
          sums[id] ??
          (real: CoreConstants.zeroDouble, registry: CoreConstants.zeroDouble);
      sums[id] = (
        real:
            before.real +
            (line.realArea ?? CoreConstants.zeroDouble) * fraction,
        registry:
            before.registry +
            (line.registryArea ?? CoreConstants.zeroDouble) * fraction,
      );
    }

    for (final CompareLineReadModel line in lines) {
      final List<OwnershipValueObject> owners =
          line.drawing?.owners ?? const <OwnershipValueObject>[];
      for (final OwnershipValueObject owner in owners) {
        add(owner.personId, owner.share.fraction, line);
      }
      final ShareValueObject held =
          line.drawing?.allocated ?? ShareValueObject.none;
      if (!held.isWhole) {
        add(null, CoreConstants.oneDouble - held.fraction, line);
      }
    }
    final List<CompareOwnerReadModel> owners =
        <CompareOwnerReadModel>[
          for (final PersonEntity person in persons)
            if (sums[person.id] case final ({double real, double registry}) sum)
              CompareOwnerReadModel(
                person: person,
                realArea: sum.real,
                registryArea: sum.registry,
              ),
        ]..sort((CompareOwnerReadModel a, CompareOwnerReadModel b) {
          final int byArea = b.realArea.compareTo(a.realArea);
          return byArea != CoreConstants.zero
              ? byArea
              : persons
                    .indexOf(a.person!)
                    .compareTo(persons.indexOf(b.person!));
        });
    final ({double real, double registry})? unowned = sums[null];
    return CompareTableReadModel._(
      lines: List<CompareLineReadModel>.unmodifiable(lines),
      owners: List<CompareOwnerReadModel>.unmodifiable(<CompareOwnerReadModel>[
        ...owners,
        if (unowned != null)
          CompareOwnerReadModel(
            person: null,
            realArea: unowned.real,
            registryArea: unowned.registry,
          ),
      ]),
    );
  }

  const CompareTableReadModel._({required this.lines, required this.owners});

  final List<CompareLineReadModel> lines;

  final List<CompareOwnerReadModel> owners;

  double get realTotal => lines.fold(
    CoreConstants.zeroDouble,
    (double sum, CompareLineReadModel l) =>
        sum + (l.realArea ?? CoreConstants.zeroDouble),
  );

  double get registryTotal => lines.fold(
    CoreConstants.zeroDouble,
    (double sum, CompareLineReadModel l) =>
        sum + (l.registryArea ?? CoreConstants.zeroDouble),
  );

  @override
  List<Object?> get props => <Object?>[lines, owners];
}
