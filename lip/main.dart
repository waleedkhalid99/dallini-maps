import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(WazeApp());

class WazeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: WazeMap(),
    );
  }
}

class WazeMap extends StatefulWidget {
  @override
  _WazeMapState createState() => _WazeMapState();
}

class _WazeMapState extends State<WazeMap> {
  final MapController _mapController = MapController();
  // القائم
  LatLng currentPos = LatLng(34.366, 41.094);
  LatLng? destination;
  List<LatLng> routePoints = [];
  TextEditingController searchCtrl = TextEditingController();

  void _searchAndGo() {
    // محاكاة بحث - يوديك لحصيبة او القائم
    if(searchCtrl.text.isNotEmpty){
      setState(() {
        destination = LatLng(34.38, 41.12);
        routePoints = [currentPos, LatLng(34.37, 41.10), destination!];
      });
      _mapController.move(destination!, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(center: currentPos, zoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: ['a','b','c'],
              ),
              PolylineLayer(
                polylines: [
                  if(routePoints.isNotEmpty)
                    Polyline(points: routePoints, color: Color(0xFF00D8FF), strokeWidth: 6),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(point: currentPos, width: 60, height: 60, builder: (c)=> Icon(Icons.navigation, color: Colors.blue, size: 40)),
                  if(destination!=null)
                    Marker(point: destination!, width: 60, height: 60, builder: (c)=> Icon(Icons.location_on, color: Colors.red, size: 45)),
                ],
              ),
            ],
          ),
          // شريط بحث Waze
          Positioned(
            top: 50, left: 15, right: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)]),
              child: TextField(
                controller: searchCtrl,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "وين تريد تروح بالقائم؟",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.black),
                  suffixIcon: IconButton(icon: Icon(Icons.arrow_forward, color: Colors.blue), onPressed: _searchAndGo),
                ),
                onSubmitted: (v)=> _searchAndGo(),
              ),
            ),
          ),
          // ازرار جانبية
          Positioned(
            right: 15, bottom: 150,
            child: Column(
              children: [
                FloatingActionButton.small(backgroundColor: Colors.white, onPressed: ()=> _mapController.move(currentPos, 15), child: Icon(Icons.my_location, color: Colors.black)),
                SizedBox(height: 10),
                FloatingActionButton.small(backgroundColor: Color(0xFFFFCC00), onPressed: (){}, child: Icon(Icons.warning, color: Colors.black)),
              ],
            ),
          ),
          // شريط ETA تحت مثل Waze
          if(destination!=null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("12 دقيقة", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)), Text("4.2 كم • 14:30 وصول", style: TextStyle(color: Colors.grey))]),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00D8FF), shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)), onPressed: (){}, child: Text("انطلق", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
