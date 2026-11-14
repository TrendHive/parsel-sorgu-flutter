import 'package:parcel_atlas/core/base/base_read_model.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/read_model/holding_line_read_model.dart';

/// Everything one person or one group holds, with totals.
///
/// [lines] are the parcels, largest owned area first. [parcelCount] is how
/// many; [totalArea] the sum of those parcels' full areas; [ownedArea] the
/// sum of the parts the shares stand for — what the holder actually owns.
final class HoldingsReadModel extends BaseReadModel {
  HoldingsReadModel(List<HoldingLineReadModel> lines)
    : lines = List<HoldingLineReadModel>.unmodifiable(
        <HoldingLineReadModel>[...lines]..sort(
          (HoldingLineReadModel a, HoldingLineReadModel b) =>
              b.ownedArea.compareTo(a.ownedArea),
        ),
      );

  final List<HoldingLineReadModel> lines;

  int get parcelCount => lines.length;

  double get totalArea => lines.fold(
    CoreConstants.zeroDouble,
    (double sum, HoldingLineReadModel line) => sum + line.area,
  );

  double get ownedArea => lines.fold(
    CoreConstants.zeroDouble,
    (double sum, HoldingLineReadModel line) => sum + line.ownedArea,
  );

  @override
  List<Object?> get props => <Object?>[lines];
}
