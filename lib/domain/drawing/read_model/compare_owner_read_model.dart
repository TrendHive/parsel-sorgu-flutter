import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';

/// One owner's totals over the compared parcels: [realArea] is what their
/// shares stand for on the real boundaries, [registryArea] the same on the
/// deeds. A null [person] gathers what nobody owns yet, including the
/// unassigned rest of a parcel whose shares do not add up to the whole.
final class CompareOwnerReadModel extends BaseReadModel {
  const CompareOwnerReadModel({
    required this.person,
    required this.realArea,
    required this.registryArea,
  });

  final PersonEntity? person;

  final double realArea;

  final double registryArea;

  double get difference => realArea - registryArea;

  @override
  List<Object?> get props => <Object?>[person?.id, realArea, registryArea];
}
