import 'package:flutter/material.dart';
import 'package:map_launcher/src/map_launcher.dart';
import 'package:map_launcher/src/svg_provider.dart';
import 'package:map_launcher/src/utils.dart';

enum MapTypes {
  apple,
  google,
  amap,
  baidu,
  waze,
  yandexMaps,
  yandexNavi,
  citymapper,
  mapswithme,
  osmand,
  doubleGis,
}

enum DirectionsMode {
  driving,
  walking,
  transit,
  bicycling,
}

class Coords {
  final double latitude;
  final double longitude;

  Coords(this.latitude, this.longitude);
}

class AvailableMap {
  String mapName;
  MapTypes mapTypes;
  ImageProvider icon;

  AvailableMap({this.mapName, this.mapTypes, this.icon});

  static AvailableMap fromJson(json) {
    return AvailableMap(
      mapName: json['mapName'],
      mapTypes: Utils.enumFromString(MapTypes.values, json['mapTypes']),
      icon: SvgImage(
        'assets/icons/${json['mapTypes']}.svg',
        package: 'map_launcher',
      ),
    );
  }

  Future<void> showMarker({
    @required Coords coords,
    @required String title,
    String description,
    int zoom,
  }) {
    return MapLauncher.showMarker(
      mapTypes: mapTypes,
      coords: coords,
      title: title,
      description: description,
      zoom: zoom,
    );
  }

  Future<void> showDirections({
    @required Coords destination,
    String destinationTitle,
    Coords origin,
    String originTitle,
    List<Coords> waypoints,
    DirectionsMode directionsMode,
  }) {
    return MapLauncher.showDirections(
      mapTypes: mapTypes,
      destination: destination,
      destinationTitle: destinationTitle,
      origin: origin,
      originTitle: originTitle,
      waypoints: waypoints,
      directionsMode: directionsMode,
    );
  }

  @override
  String toString() {
    return 'AvailableMap { mapName: $mapName, mapTypes: ${Utils.enumToString(mapTypes)} }';
  }
}
