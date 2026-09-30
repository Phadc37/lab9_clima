import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentLocation() async {
  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) throw Exception('Dịch vụ vị trí đang tắt');

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception('Chưa được cấp quyền vị trí');
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
  );
}