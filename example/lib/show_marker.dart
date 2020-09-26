import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher_example/maps_sheet.dart';

class ShowMarker extends StatefulWidget {
  @override
  _ShowMarkerState createState() => _ShowMarkerState();
}

class _ShowMarkerState extends State<ShowMarker> {
  double latitude = 59.940414;
  double longitude = 30.313793;
  String title = 'Ocean Beach';
  int zoom = 18;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Latitude'),
            initialValue: latitude.toString(),
            onChanged: (newValue) {
              setState(() {
                latitude = double.tryParse(newValue);
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Longitude'),
            initialValue: longitude.toString(),
            onChanged: (newValue) {
              setState(() {
                longitude = double.tryParse(newValue);
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Title'),
            initialValue: title,
            onChanged: (newValue) {
              setState(() {
                title = newValue;
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Zoom'),
            initialValue: zoom.toString(),
            onChanged: (newValue) {
              setState(() {
                zoom = int.tryParse(newValue);
              });
            },
          ),
          SizedBox(height: 20),
          MaterialButton(
            onPressed: () {
              MapsSheet.show(
                context: context,
                onMapTap: (map) {
                  map.showMarker(
                    coords: Coords(latitude, longitude),
                    title: title,
                    zoom: zoom,
                  );
                },
              );
            },
            child: Text('Show Maps'),
          )
        ],
      ),
    );
  }
}
