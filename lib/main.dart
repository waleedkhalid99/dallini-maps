import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(DalliniApp());

class DalliniApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دليني',
      theme: ThemeData(fontFamily: 'Cairo'),
      home: DalliniMap(),
    );
  }
}

class DalliniMap extends StatefulWidget {
  @override
  _DalliniMapState createState() => _DalliniMapState();
}

class _DalliniMapState extends State<DalliniMap> {
  final MapController _mapCtrl = MapController();
  LatLng _current = LatLng(33.425, 43.300); // الرمادي
  double _speed = 0;
  double _distance = 0;
  bool _avoidDirt = false;
  List<Marker> _reports = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    Geolocator.getPositionStream().listen((pos) {
      setState(() {
        _current = LatLng(pos.latitude, pos.longitude);
        _speed = pos.speed * 3.6; // كم/سا
      });
      _mapCtrl.move(_current, 16);
    });
  }

  void _addReport(String type) {
    setState(() {
      _reports.add(Marker(
        point: _current,
        width: 40, height: 40,
        child: Icon(
          type == 'سيطرة' ? Icons.local_police : 
          type == 'حادث' ? Icons.warning : Icons.construction,
          color: Colors.red, size: 35,
        ),
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم التبليغ عن $type - شكرا! +10 نقاط')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _current,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.dallini',
              ),
              MarkerLayer(markers: [
                Marker(point: _current, child: Icon(Icons.navigation, color: Colors.blue, size: 40)),
                ..._reports
              ]),
            ],
          ),
          // 1-4: سرعة ومسافة وتنبيه استدارة
          Positioned(top: 40, left: 10, right: 10,
            child: Column(children: [
              // شريط البحث - 11: اسماء شوارع عراقية
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  decoration: InputDecoration(hintText: 'وين تريد تروح؟ الرمادي، بغداد...', prefixIcon: Icon(Icons.search), border: InputBorder.none, contentPadding: EdgeInsets.all(15)),
                ),
              ),
              SizedBox(height: 10),
              Row(children: [
                _infoBox('${_speed.toStringAsFixed(0)} كم/س', Icons.speed), // 3
                SizedBox(width: 8),
                _infoBox('${_distance.toStringAsFixed(1)} كم متبقي', Icons.route), // 4
                SizedBox(width: 8),
                _infoBox('بانزين: 850 د.ع', Icons.local_gas_station), // 15
              ])
            ])
          ),
          // 26: زر طوارئ + 14-19 خدمات
          Positioned(bottom: 90, right: 10,
            child: Column(children: [
              FloatingActionButton.small(heroTag: 'sos', backgroundColor: Colors.red, onPressed: (){}, child: Text('122')), // 26
              SizedBox(height: 8),
              FloatingActionButton.small(heroTag: 'mosque', onPressed: (){}, child: Icon(Icons.mosque)), // 19
              FloatingActionButton.small(heroTag: 'repair', onPressed: (){}, child: Icon(Icons.build)), // 14
            ])
          ),
          // 1-10 تبليغات مثل Waze
          Positioned(bottom: 20, left: 10, right: 10,
            child: SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: Row(children: [
                _reportBtn('سيطرة', Icons.local_police),
                _reportBtn('حادث', Icons.car_crash),
                _reportBtn('ازدحام', Icons.traffic),
                _reportBtn('حفرة', Icons.warning),
                _reportBtn('رادار', Icons.speed),
                _reportBtn('مغلق', Icons.block),
              ])
            )
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'الخريطة'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'نقاط: 120'), // 29
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'اعدادات'),
        ],
      ),
    );
  }

  Widget _infoBox(String text, IconData icon) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [Icon(icon, size: 16), SizedBox(width: 4), Text(text, style: TextStyle(fontSize: 12))]),
  );

  Widget _reportBtn(String label, IconData icon) => Padding(
    padding: EdgeInsets.only(right: 8),
    child: ElevatedButton.icon(onPressed: () => _addReport(label), icon: Icon(icon, size: 18), label: Text(label)),
  );
}
