import 'dart:io';
import 'package:flutter/material.dart';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

String getMapMarkerUrl({
  @required MapTypes mapTypes,
  @required Coords coords,
  String title,
  String description,
  int zoom,
}) {
  final zoomLevel = zoom ?? 16;
  switch (mapTypes) {
    case MapTypes.google:
      return Utils.buildUrl(
        url: Platform.isIOS ? 'comgooglemaps://' : 'geo:0,0',
        queryParams: {
          'q': '${coords.latitude},${coords.longitude}($title)',
          'zoom': '$zoomLevel',
        },
      );

    case MapTypes.amap:
      return Utils.buildUrl(
        url: '${Platform.isIOS ? 'ios' : 'android'}amap://viewMap',
        queryParams: {
          'sourceApplication': 'map_launcher',
          'poiname': '$title',
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'zoom': '$zoomLevel',
          'dev': '0',
        },
      );

    case MapTypes.baidu:
      return Utils.buildUrl(
        url: 'baidumap://map/marker',
        queryParams: {
          'location': '${coords.latitude},${coords.longitude}',
          'title': title ?? 'Title',
          'content': description ??
              'Description', // baidu fails if no description provided
          'traffic': 'on',
          'src': 'com.map_launcher',
          'coord_type': 'gcj02',
          'zoom': '$zoomLevel',
        },
      );

    case MapTypes.apple:
      return Utils.buildUrl(
        url: 'http://maps.apple.com/maps',
        queryParams: {
          'saddr': '${coords.latitude},${coords.longitude}',
        },
      );

    case MapTypes.waze:
      return Utils.buildUrl(
        url: 'waze://',
        queryParams: {
          'll': '${coords.latitude},${coords.longitude}',
          'z': '$zoomLevel',
        },
      );

    case MapTypes.yandexNavi:
      return Utils.buildUrl(
        url: 'yandexnavi://show_point_on_map',
        queryParams: {
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'zoom': '$zoomLevel',
          'no-balloon': '0',
          'desc': '$title',
        },
      );

    case MapTypes.yandexMaps:
      return Utils.buildUrl(
        url: 'yandexmaps://maps.yandex.ru/',
        queryParams: {
          'pt': '${coords.longitude},${coords.latitude}',
          'z': '$zoomLevel',
          'l': 'map',
        },
      );

    case MapTypes.citymapper:
      return Utils.buildUrl(
        url: 'citymapper://directions',
        queryParams: {
          'endcoord': '${coords.latitude},${coords.longitude}',
          'endname': '$title',
        },
      );

    case MapTypes.mapswithme:
      return Utils.buildUrl(
        url: 'mapsme://map',
        queryParams: {
          'v': '1',
          'll': '${coords.latitude},${coords.longitude}',
          'n': title
        },
      );

    case MapTypes.osmand:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'osmandmaps://',
          queryParams: {
            'lat': '${coords.latitude}',
            'lon': '${coords.longitude}',
            'title': title,
          },
        );
      }
      return Utils.buildUrl(
        url: 'http://osmand.net/go',
        queryParams: {
          'lat': '${coords.latitude}',
          'lon': '${coords.longitude}',
          'z': '$zoomLevel',
        },
      );

    case MapTypes.doubleGis:
      if (Platform.isIOS) {
        return Utils.buildUrl(
          url: 'dgis://2gis.ru/geo/${coords.longitude},${coords.latitude}',
          queryParams: {},
        );
      }

      // android app does not seem to support marker by coordinates
      // so falling back to directions
      return Utils.buildUrl(
        url:
            'dgis://2gis.ru/routeSearch/rsType/car/to/${coords.longitude},${coords.latitude}',
        queryParams: {},
      );

    default:
      return null;
  }
}
