import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/core/constants.dart';

class RoutePath {
  final RoutePath? _path;
  final String _pathEnd;
  final String? _parameter;
  final String? name;
  Key _key = UniqueKey();

  RoutePath({this._path, required this._pathEnd, this._parameter, this.name});

  String path({String? parameter}) {
    String path =
        (_path?.path() ?? CoreConstants.empty) + CoreConstants.slash + _pathEnd;
    path = _parameter == null
        ? path
        : path + CoreConstants.slash + (parameter ?? _parameter);
    return path;
  }

  String pathEnd() {
    String pathEnd = (_path?.path() ?? CoreConstants.empty).isEmpty
        ? CoreConstants.slash + _pathEnd
        : _pathEnd;
    pathEnd = _parameter == null
        ? pathEnd
        : pathEnd + CoreConstants.slash + CoreConstants.colon + _parameter;
    return pathEnd;
  }

  String parameter() {
    return _parameter ?? CoreConstants.empty;
  }

  Key key({String? fullPath}) {
    if (fullPath?.replaceAll(CoreConstants.colon, CoreConstants.empty) ==
        path()) {
      _key = UniqueKey();
    }
    return _key;
  }
}
