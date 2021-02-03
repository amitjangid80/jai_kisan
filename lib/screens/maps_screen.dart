// Created by AMIT JANGID on 03/02/21.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  int _markerIdCounter = 1, _polygonIdCounter = 1;
  bool _isLoading = true, _isMarker = true, _isPolygon = false;

  LocationData _locationData;
  Location _location = Location();
  GoogleMapController _googleMapController;

  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  List<LatLng> _polygonLatLongs = List<LatLng>();

  @override
  void initState() {
    super.initState();

    // calling enable location services method
    _enableLocationServices();

    // calling get current location method
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jai Kisan'), backgroundColor: Colors.green[700]),
      floatingActionButton: (_polygonLatLongs.length > 0 && _isPolygon)
          ? FloatingActionButton.extended(
              //Remove the last point set at the polygon
              icon: Icon(Icons.undo),
              label: Text('Undo point'),
              backgroundColor: Colors.orange,
              onPressed: () => setState(() => _polygonLatLongs.removeLast()),
            )
          : null,
      body: _isLoading
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator(), const SizedBox(width: 10), Text('Getting Location...')],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  markers: _markers,
                  polygons: _polygons,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    zoom: 12,
                    target: LatLng(_locationData.latitude, _locationData.longitude),
                  ),
                  onTap: (latLng) {
                    debugPrint('selected lat lng is: $latLng');

                    _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(zoom: 12, target: latLng)),
                    );

                    if (_isPolygon) {
                      _polygonLatLongs.add(latLng);

                      // calling set polygon method
                      _setPolygon();
                    } else if (_isMarker) {
                      // calling set markers method
                      _setMarkers(latLng);
                    }
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RaisedButton(
                        color: _isMarker ? Colors.blueAccent : Colors.white,
                        child: Text('Marker', style: TextStyle(color: _isMarker ? Colors.white : Colors.black)),
                        onPressed: () {
                          setState(() {
                            _isMarker = true;
                            _isPolygon = false;
                          });
                        },
                      ),
                      RaisedButton(
                        color: _isPolygon ? Colors.blueAccent : Colors.white,
                        child: Text('Area', style: TextStyle(color: _isPolygon ? Colors.white : Colors.black)),
                        onPressed: () {
                          setState(() {
                            _isMarker = false;
                            _isPolygon = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  _enableLocationServices() async {
    bool _isServiceEnabled = await _location.serviceEnabled();

    if (_isServiceEnabled != null && !_isServiceEnabled) {
      await _location.requestService();
    }
  }

  /// this method will get current location of the user
  _getCurrentLocation() async {
    LocationData locationData = await _location.getLocation();
    debugPrint('location data is: $locationData');

    setState(() {
      _locationData = locationData;
      _isLoading = false;
    });

    // calling set markers method
    _setMarkers(LatLng(_locationData.latitude, _locationData.longitude));
  }

  _onMapCreated(GoogleMapController googleMapController) async {
    _googleMapController = googleMapController;
  }

  _setMarkers(LatLng latLng) {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;

    setState(() {
      debugPrint('Marker | Latitude: ${latLng.latitude} & Longitude: ${latLng.longitude}');
      _markers.clear();

      _markers.add(Marker(markerId: MarkerId(markerIdVal), position: latLng));
    });
  }

  _setPolygon() {
    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';

    _polygons.add(Polygon(
      strokeWidth: 2,
      points: _polygonLatLongs,
      strokeColor: Colors.yellow,
      polygonId: PolygonId(polygonIdVal),
      fillColor: Colors.yellow.withOpacity(0.15),
    ));
  }

  @override
  void dispose() {
    _googleMapController.dispose();

    super.dispose();
  }
}
