import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/src/directions_url.dart';
import 'package:map_launcher/src/marker_url.dart';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

class MapLauncher {
  static const MethodChannel _channel = const MethodChannel('map_launcher');

  static Future<List<AvailableMap>> get installedMaps async {
    final maps = await _channel.invokeMethod('getInstalledMaps');
    return List<AvailableMap>.from(
      maps.map((map) => AvailableMap.fromJson(map)),
    );
  }

  @Deprecated('use showMarker instead')
  static Future<dynamic> launchMap({
    @required MapTypes mapTypes,
    @required Coords coords,
    @required String title,
    String description,
  }) {
    return showMarker(
      mapTypes: mapTypes,
      coords: coords,
      title: title,
      description: description,
    );
  }

  static Future<dynamic> showMarker({
    @required MapTypes mapTypes,
    @required Coords coords,
    @required String title,
    String description,
    int zoom,
  }) async {
    final url = getMapMarkerUrl(
      mapTypes: mapTypes,
      coords: coords,
      title: title,
      description: description,
      zoom: zoom,
    );

    final Map<String, String> args = {
      'mapTypes': Utils.enumToString(mapTypes),
      'url': Uri.encodeFull(url),
      'title': title,
      'description': description,
      'latitude': coords.latitude.toString(),
      'longitude': coords.longitude.toString(),
    };
    return _channel.invokeMethod('showMarker', args);
  }

  static Future<dynamic> showDirections({
    @required MapTypes mapTypes,
    @required Coords destination,
    String destinationTitle,
    Coords origin,
    String originTitle,
    List<Coords> waypoints,
    DirectionsMode directionsMode = DirectionsMode.driving,
  }) async {
    final url = getMapDirectionsUrl(
      mapTypes: mapTypes,
      destination: destination,
      destinationTitle: destinationTitle,
      origin: origin,
      originTitle: originTitle,
      waypoints: waypoints,
      directionsMode: directionsMode,
    );

    final Map<String, String> args = {
      'mapTypes': Utils.enumToString(mapTypes),
      'url': Uri.encodeFull(url),
      'destinationTitle': destinationTitle,
      'destinationLatitude': destination.latitude.toString(),
      'destinationLongitude': destination.longitude.toString(),
      'destinationtitle': destinationTitle,
      'originLatitude': origin?.latitude?.toString(),
      'originLongitude': origin?.longitude?.toString(),
      'origintitle': originTitle,
      'directionsMode': Utils.enumToString(directionsMode),
    };
    return _channel.invokeMethod('showDirections', args);
  }

  static Future<bool> isMapAvailable(MapTypes mapTypes) async {
    return _channel.invokeMethod(
      'isMapAvailable',
      {'mapTypes': Utils.enumToString(mapTypes)},
    );
  }
}
