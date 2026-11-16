import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/enum/redivide_step_enum.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';

/// Two neighbouring real boundaries being divided again by their deeds.
///
/// [first] is the drawing it started from and [second] the neighbour tapped
/// next (null until then). [firstDeed] and [secondDeed] are their registry
/// parcels' deed areas. The line between the two moves, parallel to where it
/// was, until each piece has the same part of their joined ground as its
/// deed has of the two deeds together — [pieces], with [step] saying why
/// there are none.
final class MapRedivideReadModel extends BaseReadModel {
  const MapRedivideReadModel._({
    required this.first,
    required this.second,
    required this.firstDeed,
    required this.secondDeed,
    required this.pieces,
    required this.step,
  });

  const MapRedivideReadModel.start(this.first)
    : second = null,
      firstDeed = null,
      secondDeed = null,
      pieces = null,
      step = RedivideStepEnum.pickNeighbour;

  factory MapRedivideReadModel.between({
    required DrawnParcelEntity first,
    required DrawnParcelEntity second,
    required MapSnapshotReadModel snapshot,
  }) {
    final OfficialParcelEntity? firstOfficial = snapshot.officialOf(first);
    final OfficialParcelEntity? secondOfficial = snapshot.officialOf(second);
    final double? firstDeed = _deed(firstOfficial);
    final double? secondDeed = _deed(secondOfficial);
    MapRedivideReadModel result(
      RedivideStepEnum step, [
      ({List<LatLng> first, List<LatLng> second})? pieces,
    ]) => MapRedivideReadModel._(
      first: first,
      second: second,
      firstDeed: firstDeed,
      secondDeed: secondDeed,
      pieces: pieces,
      step: step,
    );
    if (firstDeed == null || secondDeed == null) {
      return result(RedivideStepEnum.noDeed);
    }
    if (firstOfficial!.id == secondOfficial!.id) {
      return result(RedivideStepEnum.sameDeed);
    }
    if (snapshot.drawingsCorrecting(firstOfficial).length > 1 ||
        snapshot.drawingsCorrecting(secondOfficial).length > 1) {
      return result(RedivideStepEnum.splitDeed);
    }
    final ({List<LatLng> first, List<LatLng> second})? pieces =
        GeoRules.redivide(
          first.outline.corners,
          second.outline.corners,
          firstDeed / (firstDeed + secondDeed),
        );
    return pieces == null
        ? result(RedivideStepEnum.notNeighbours)
        : result(RedivideStepEnum.ready, pieces);
  }

  final DrawnParcelEntity first;

  final DrawnParcelEntity? second;

  final double? firstDeed;

  final double? secondDeed;

  final ({List<LatLng> first, List<LatLng> second})? pieces;

  final RedivideStepEnum step;

  bool get canConfirm => step == RedivideStepEnum.ready;

  static double? _deed(OfficialParcelEntity? official) => official == null
      ? null
      : official.record.registryAreaSquareMeters ??
            official.record.outline.areaSquareMeters;

  @override
  List<Object?> get props => <Object?>[first.id, second?.id, step];
}
