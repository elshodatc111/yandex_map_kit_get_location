import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Marker with Address',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late YandexMapController _controller;
  PlacemarkMapObject? _currentLocationPlacemark;
  String _currentAddress = "Joylashuv aniqlanmoqda...";
  bool _isSatellite = true; // Xarita boshlanishida satellite turida
  final String _apiKey = 'ac15b0d0-d297-4162-9eac-c94f30e05bb8'; // Yandex Geocoding API yoki Google API key

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndUpdateMap();
  }

  /// Lokatsiyani olish va xaritani yangilash
  Future<void> _getCurrentLocationAndUpdateMap() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      Point currentLocation = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Manzilni yangilash
      await _updateAddress(currentLocation);

      setState(() {
        // Marker (belgi) ni yaratish va xaritaga qo'yish
        _currentLocationPlacemark = PlacemarkMapObject(
          mapId: const MapObjectId('current_location'),
          point: currentLocation,
          isDraggable: true, // Marker surilishi mumkin bo'lishi uchun
          onDragEnd: (newPoint) async {
            // Marker surilganda yangi joylashuvni yangilash
            Point draggedPoint = newPoint as Point;
            await _updateAddress(draggedPoint);
            setState(() {
              _currentLocationPlacemark = _currentLocationPlacemark?.copyWith(point: draggedPoint);
            });
          },
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/location_icon.png'),
              scale: 4.0,
            ),
          ),
        );
      });

      // Kamerani yangi joylashuvga qaratish
      _controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 16),
        ),
      );
    } catch (e) {
      debugPrint('Lokatsiyani olishda xato yuz berdi: $e');
    }
  }

  /// Manzilni yangilash va API orqali manzilni aniqlash
  Future<void> _updateAddress(Point point) async {
    // Yandex geocoding API
    final String url = 'https://geocode-maps.yandex.ru/1.x/?geocode=${point.longitude},${point.latitude}&format=json&apikey=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // GeoObject'ni olish
      final geoObject = data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject'];

      // To'liq manzilni olish
      final address = geoObject['name']; // Manzil
      final addressDetails = geoObject['description']; // Qo'shimcha ma'lumotlar (ko'cha nomi va uy raqami)

      setState(() {
        _currentAddress = address ?? "Manzil topilmadi";
        // Qo'shimcha manzilni ko'rsatish
        _currentAddress += (addressDetails != null) ? " - $addressDetails" : "";
      });

      // Konsolga tanlangan joyning koordinatalarini chiqarish
      debugPrint("Latitude: ${point.latitude}, Longitude: ${point.longitude}");
      debugPrint("Manzil: $address");
    } else {
      debugPrint('Manzilni olishda xato yuz berdi.');
    }
  }


  /// Satellite yoki vektor xarita turini o'zgartirish
  void _toggleMapView() {
    setState(() {
      _isSatellite = !_isSatellite;
    });

    // Kamera pozitsiyasini olish
    _controller.getCameraPosition().then((currentCameraPosition) {
      // Kamera pozitsiyasini saqlab, zoom darajasini o'zgartirmasdan xarita turini o'zgartirish
      _controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentCameraPosition.target, zoom: currentCameraPosition.zoom),
        ),
      );

      // Satellite yoki vektor xarita turini o'zgartirish
      _controller.setMapStyle(_isSatellite
          ? 'satellite' // Satellite turiga o'tish
          : 'vector'); // Vektor (normal) xarita turiga o'tish
    });
  }

  /// Tanlangan manzil va koordinatalarni konsolga chiqarish
  void _printSelectedLocation() {
    if (_currentLocationPlacemark != null) {
      final point = _currentLocationPlacemark!.point;
      debugPrint("Selected Location:");
      debugPrint("Latitude: ${point.latitude}, Longitude: ${point.longitude}");
      debugPrint("Address: $_currentAddress");
    }
  }

  /// Xaritada bosilgan joyga marker qo'yish
  void _onMapTapped(Point point) async {
    await _updateAddress(point);

    setState(() {
      // Markerni yangilash va joylashuvni ko'rsatish
      _currentLocationPlacemark = PlacemarkMapObject(
        mapId: const MapObjectId('current_location'),
        point: point,
        isDraggable: true, // Marker surilishi mumkin bo'lishi uchun
        onDragEnd: (newPoint) async {
          // Marker surilganda yangi joylashuvni yangilash
          Point draggedPoint = newPoint as Point;
          await _updateAddress(draggedPoint);
          setState(() {
            _currentLocationPlacemark = _currentLocationPlacemark?.copyWith(point: draggedPoint);
          });
        },
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/location_icon.png'),
            scale: 4.0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manzil: $_currentAddress'), // Manzilni AppBar sarlavhasida ko'rsatish
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) {
              _controller = controller;
              // Dastlab xaritani satellite turida ochish
              _controller.setMapStyle('satellite');
              _getCurrentLocationAndUpdateMap();
            },
            mapObjects: _currentLocationPlacemark != null
                ? [_currentLocationPlacemark!]
                : [],
            onMapTap: _onMapTapped, // Xaritada bosilgan joyni olish
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleMapView, // Satellite/normal xarita turini almashtirish
              child: Icon(_isSatellite ? Icons.satellite : Icons.map),
            ),
          ),
          Positioned(
            top: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocationAndUpdateMap,
              child: const Icon(Icons.my_location),
            ),
          ),
          // Pastki tugma
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Colors.blueAccent,
              child: TextButton(
                onPressed: _printSelectedLocation, // Tanlangan manzilni konsolga chiqarish
                child: const Text(
                  'Tanlangan manzilni ko\'rish',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
