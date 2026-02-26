import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHelper {
  /// Returns true if permission is granted and location services are ON.
  /// If permission is denied -> requests it.
  /// If permanently denied -> opens app settings.
  static Future<bool> ensureLocationReady() async {
    // 1) Check device location services
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Opens the Location settings page (Android/iOS)
      await Geolocator.openLocationSettings();
      return false;
    }

    // 2) Check permission
    var status = await Permission.locationWhenInUse.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    }

    // 3) Permanently denied / restricted -> open app settings
    if (status.isPermanentlyDenied || status.isRestricted || status.isLimited) {
      await openAppSettings();
      return false;
    }

    return false;
  }
}
