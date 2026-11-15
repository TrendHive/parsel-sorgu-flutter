import 'package:parcel_atlas/core/base/base_cause.dart';
import 'package:parcel_atlas/core/cause/code/cause_code.dart';

/// A drawing that would cover part of another drawing.
class DrawingOverlapsCause extends BaseCause {
  DrawingOverlapsCause({super.cause})
    : super(errorCode: CauseCode.drawingOverlaps());
}
