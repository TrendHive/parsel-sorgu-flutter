import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_draft_value_object.dart';

void main() {
  const LatLng a = LatLng(40.0, 41.0);
  const LatLng b = LatLng(40.0, 41.001);
  const LatLng c = LatLng(40.001, 41.001);
  const LatLng moved = LatLng(40.0005, 41.0015);

  test('two corners cannot be saved; three can', () {
    final DrawingDraftValueObject two = DrawingDraftValueObject.empty
        .add(a)
        .add(b);
    expect(two.canSave, isFalse);
    expect(two.add(c).canSave, isTrue);
  });

  test('undo walks back one edit at a time and redo walks forward', () {
    final DrawingDraftValueObject draft = DrawingDraftValueObject.empty
        .add(a)
        .add(b)
        .add(c);
    expect(draft.undo().corners, <LatLng>[a, b]);
    expect(draft.undo().undo().redo().corners, <LatLng>[a, b]);
  });

  test('a drag from the same origin is one undo step however far it went', () {
    final DrawingDraftValueObject origin = DrawingDraftValueObject.empty
        .add(a)
        .add(b)
        .add(c);
    final DrawingDraftValueObject dragged = origin
        .move(2, const LatLng(40.0002, 41.0012))
        .undo();
    expect(dragged.corners, origin.corners);
    expect(origin.move(2, moved).undo().corners, origin.corners);
  });

  test('a corner inserted on an edge lands between its two ends', () {
    final DrawingDraftValueObject draft = DrawingDraftValueObject.empty
        .add(a)
        .add(b)
        .add(c)
        .insertAfter(0, moved);
    expect(draft.corners, <LatLng>[a, moved, b, c]);
    expect(draft.selected, 1);
  });

  test('deleting the selected corner removes only that corner', () {
    final DrawingDraftValueObject draft = DrawingDraftValueObject.empty
        .add(a)
        .add(b)
        .add(c)
        .select(1)
        .removeSelected();
    expect(draft.corners, <LatLng>[a, c]);
  });
}
