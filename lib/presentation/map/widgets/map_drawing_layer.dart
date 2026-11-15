import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/drawing/value_object/drawing_draft_value_object.dart';
import 'package:parcel_atlas/domain/map/rule/geo_rules.dart';
import 'package:parcel_atlas/domain/map/rule/map_rules.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_color.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_dimens.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_corner_handle.dart';
import 'package:parcel_atlas/presentation/map/widgets/map_edge_chip.dart';

/// A drawing in progress, on the map.
///
/// The shape is drawn thick in yellow, so it stands out from both stored
/// layers. Each edge carries a [MapEdgeChip] with its live length that
/// inserts a corner when tapped; each corner is a draggable, numbered
/// [MapCornerHandle] — tap to select, drag to move. Every handle is drawn
/// small but hit at the full 48 px tap target, so a fingertip finds it.
///
/// [lengthOf] writes a length in the reader's format. The callbacks hand
/// positions to the Cubit, which snaps and records them.
class MapDrawingLayer extends StatelessWidget {
  const MapDrawingLayer({
    super.key,
    required this.draft,
    required this.lengthOf,
    required this.onSelect,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onInsert,
  });

  final DrawingDraftValueObject draft;

  final String Function(double meters) lengthOf;

  final ValueChanged<int> onSelect;

  final ValueChanged<int> onDragStart;

  final void Function(int index, LatLng point) onDragUpdate;

  final VoidCallback onDragEnd;

  final void Function(int afterIndex, LatLng point) onInsert;

  @override
  Widget build(BuildContext context) {
    final List<LatLng> corners = draft.corners;
    final bool closed = corners.length >= MapRules.minimumCorners;
    final int edgeCount = closed
        ? corners.length
        : corners.length - CoreConstants.one;
    return Stack(
      children: <Widget>[
        if (closed)
          PolygonLayer(
            polygons: <Polygon>[
              Polygon(
                points: corners,
                color: ParcelInfoColor.draftStroke.withValues(
                  alpha: ParcelInfoDimens.fillAlpha,
                ),
                borderColor: ParcelInfoColor.draftStroke,
                borderStrokeWidth: ParcelInfoDimens.drawingOutline,
              ),
            ],
          )
        else if (corners.length > CoreConstants.one)
          PolylineLayer(
            polylines: <Polyline>[
              Polyline(
                points: corners,
                color: ParcelInfoColor.draftStroke,
                strokeWidth: ParcelInfoDimens.drawingOutline,
              ),
            ],
          ),
        MarkerLayer(
          markers: <Marker>[
            for (int i = CoreConstants.zero; i < edgeCount; i++)
              _edge(
                i,
                corners[i],
                corners[(i + CoreConstants.one) % corners.length],
              ),
          ],
        ),
        DragMarkers(
          markers: <DragMarker>[
            for (int i = CoreConstants.zero; i < corners.length; i++)
              DragMarker(
                key: ValueKey<int>(i),
                point: corners[i],
                size: const Size.square(ParcelInfoDimens.minTapTarget),
                builder: (BuildContext context, LatLng _, bool dragging) =>
                    Center(
                      child: SizedBox.square(
                        dimension: ParcelInfoDimens.cornerHandle,
                        child: MapCornerHandle(
                          number: i + CoreConstants.one,
                          selected: draft.selected == i,
                          dragging: dragging,
                        ),
                      ),
                    ),
                onTap: (_) => onSelect(i),
                onDragStart: (_, _) => onDragStart(i),
                onDragUpdate: (_, LatLng point) => onDragUpdate(i, point),
                onDragEnd: (_, _) => onDragEnd(),
                scrollMapNearEdge: true,
              ),
          ],
        ),
      ],
    );
  }

  Marker _edge(int index, LatLng from, LatLng to) {
    final LatLng middle = LatLng(
      (from.latitude + to.latitude) / CoreConstants.two,
      (from.longitude + to.longitude) / CoreConstants.two,
    );
    return Marker(
      point: middle,
      width: ParcelInfoDimens.edgeLabelWidth,
      height: ParcelInfoDimens.edgeLabelHeight,
      child: MapEdgeChip(
        length: lengthOf(GeoRules.distanceMeters(from, to)),
        onInsert: () => onInsert(index, middle),
      ),
    );
  }
}
