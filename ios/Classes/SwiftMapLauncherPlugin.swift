import Flutter
import UIKit
import MapKit


private enum MapTypes: String {
  case apple
  case google
  case amap
  case baidu
  case waze
  case yandexNavi
  case yandexMaps
  case citymapper
  case mapswithme
  case osmand
  case doubleGis

  func type() -> String {
    return self.rawValue
  }
}

private class Map {
  let mapName: String;
  let mapTypes: MapTypes;
  let urlPrefix: String?;


    init(mapName: String, mapTypes: MapTypes, urlPrefix: String?) {
        self.mapName = mapName
        self.mapTypes = mapTypes
        self.urlPrefix = urlPrefix
    }

    func toMap() -> [String:String] {
    return [
      "mapName": mapName,
      "mapTypes": mapTypes.type(),
    ]
  }
}

private let maps: [Map] = [
    Map(mapName: "Apple Maps", mapTypes: MapTypes.apple, urlPrefix: ""),
    Map(mapName: "Google Maps", mapTypes: MapTypes.google, urlPrefix: "comgooglemaps://"),
    Map(mapName: "Amap", mapTypes: MapTypes.amap, urlPrefix: "iosamap://"),
    Map(mapName: "Baidu Maps", mapTypes: MapTypes.baidu, urlPrefix: "baidumap://"),
    Map(mapName: "Waze", mapTypes: MapTypes.waze, urlPrefix: "waze://"),
    Map(mapName: "Yandex Navigator", mapTypes: MapTypes.yandexNavi, urlPrefix: "yandexnavi://"),
    Map(mapName: "Yandex Maps", mapTypes: MapTypes.yandexMaps, urlPrefix: "yandexmaps://"),
    Map(mapName: "Citymapper", mapTypes: MapTypes.citymapper, urlPrefix: "citymapper://"),
    Map(mapName: "MAPS.ME", mapTypes: MapTypes.mapswithme, urlPrefix: "mapswithme://"),
    Map(mapName: "OsmAnd", mapTypes: MapTypes.osmand, urlPrefix: "osmandmaps://"),
    Map(mapName: "2GIS", mapTypes: MapTypes.doubleGis, urlPrefix: "dgis://")
]

private func getMapByRawMapTypes(type: String) -> Map {
    return maps.first(where: { $0.mapTypes.type() == type })!
}

private func getMapItem(latitude: String, longitude: String) -> MKMapItem {
    let coordinate = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
    let destinationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)

    return MKMapItem(placemark: destinationPlacemark);
}

private func getDirectionsMode(directionsMode: String?) -> String {
    switch directionsMode {
    case "driving":
        return MKLaunchOptionsDirectionsModeDriving
    case "walking":
        return MKLaunchOptionsDirectionsModeWalking
    case "transit":
        if #available(iOS 9.0, *) {
            return MKLaunchOptionsDirectionsModeTransit
        } else {
            return MKLaunchOptionsDirectionsModeDriving
        }
    default:
        if #available(iOS 10.0, *) {
            return MKLaunchOptionsDirectionsModeDefault
        } else {
            return MKLaunchOptionsDirectionsModeDriving
        }
    }
}

private func showMarker(mapTypes: MapTypes, url: String, title: String, latitude: String, longitude: String) {
    switch mapTypes {
    case MapTypes.apple:
        let coordinate = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    default:
        UIApplication.shared.openURL(URL(string:url)!)

    }
}

private func showDirections(mapTypes: MapTypes, url: String, destinationTitle: String?, destinationLatitude: String, destinationLongitude: String, originTitle: String?, originLatitude: String?, originLongitude: String?, directionsMode: String?) {
    switch mapTypes {
    case MapTypes.apple:

        let destinationMapItem = getMapItem(latitude: destinationLatitude, longitude: destinationLongitude);
        destinationMapItem.name = destinationTitle ?? "Destination"

        let hasOrigin = originLatitude != nil && originLatitude != nil
        var originMapItem: MKMapItem {
            if !hasOrigin {
                return MKMapItem.forCurrentLocation()
            }
            let origin = getMapItem(latitude: originLatitude!, longitude: originLongitude!)
            origin.name = originTitle ?? "Origin"
            return origin
        }


        MKMapItem.openMaps(
            with: [originMapItem, destinationMapItem],
            launchOptions: [MKLaunchOptionsDirectionsModeKey: getDirectionsMode(directionsMode: directionsMode)]
        )
    default:
        UIApplication.shared.openURL(URL(string:url)!)

    }
}


private func isMapAvailable(map: Map) -> Bool {
    if map.mapTypes == MapTypes.apple {
        return true
    }
    return UIApplication.shared.canOpenURL(URL(string:map.urlPrefix!)!)
}


public class SwiftMapLauncherPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "map_launcher", binaryMessenger: registrar.messenger())
    let instance = SwiftMapLauncherPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInstalledMaps":
      result(maps.filter({ isMapAvailable(map: $0) }).map({ $0.toMap() }))

    case "showMarker":
      let args = call.arguments as! NSDictionary
      let mapTypes = args["mapTypes"] as! String
      let url = args["url"] as! String
      let title = args["title"] as! String
      let latitude = args["latitude"] as! String
      let longitude = args["longitude"] as! String

      let map = getMapByRawMapTypes(type: mapTypes)
      if (!isMapAvailable(map: map)) {
        result(FlutterError(code: "MAP_NOT_AVAILABLE", message: "Map is not installed on a device", details: nil))
        return;
      }

      showMarker(mapTypes: MapTypes(rawValue: mapTypes)!, url: url, title: title, latitude: latitude, longitude: longitude)

    case "showDirections":
      let args = call.arguments as! NSDictionary
      let mapTypes = args["mapTypes"] as! String
      let url = args["url"] as! String

      let destinationTitle = args["destinationTitle"] as? String
      let destinationLatitude = args["destinationLatitude"] as! String
      let destinationLongitude = args["destinationLongitude"] as! String

      let originTitle = args["originTitle"] as? String
      let originLatitude = args["originLatitude"] as? String
      let originLongitude = args["originLongitude"] as? String

      let directionsMode = args["directionsMode"] as? String

      let map = getMapByRawMapTypes(type: mapTypes)
      if (!isMapAvailable(map: map)) {
        result(FlutterError(code: "MAP_NOT_AVAILABLE", message: "Map is not installed on a device", details: nil))
        return;
      }

      showDirections(
        mapTypes: MapTypes(rawValue: mapTypes)!,
        url: url,
        destinationTitle: destinationTitle,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        originTitle: originTitle,
        originLatitude: originLatitude,
        originLongitude: originLongitude,
        directionsMode: directionsMode
      )

    case "isMapAvailable":
      let args = call.arguments as! NSDictionary
      let mapTypes = args["mapTypes"] as! String
      let map = getMapByRawMapTypes(type: mapTypes)
      result(isMapAvailable(map: map))

    default:
      print("method does not exist")
    }
  }
}
