import 'package:geolocator/geolocator.dart';

Future<bool> _handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled. Please enable the services');
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied');
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    print(
        'Location permissions are permanently denied, we cannot request permissions.');
    return false;
  }
  return true;
}

Future<Position?> getCurrentPosition() async {
  final hasPermission = await _handleLocationPermission();
  if (!hasPermission) return null;
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  return position;
}
