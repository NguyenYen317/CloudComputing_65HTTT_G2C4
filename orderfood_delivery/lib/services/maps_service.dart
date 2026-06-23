import 'package:url_launcher/url_launcher.dart';

import '../config/maps_config.dart';

class MapsService {
  const MapsService();

  ({double lat, double lng})? knownVietnamLocation(String? address) {
    final normalized = (address ?? '').toLowerCase();
    if (!normalized.contains('1002')) return null;

    if (normalized.contains('giải phóng') ||
        normalized.contains('giai phong') ||
        normalized.contains('giáº£i phÃ³ng')) {
      return (lat: 20.98285, lng: 105.84184);
    }

    return null;
  }

  String normalizeVietnamAddress(String? address) {
    final normalized = (address ?? '').trim();
    if (normalized.isEmpty) return '';

    final lower = normalized.toLowerCase();
    if (lower.contains('viet nam') ||
        lower.contains('việt nam') ||
        lower.contains('viá»‡t nam')) {
      return normalized;
    }

    return '$normalized, Việt Nam';
  }

  String buildDirectionsUrl({
    double? originLat,
    double? originLng,
    double? destinationLat,
    double? destinationLng,
    String? destinationAddress,
    bool useCurrentLocationAsOrigin = true,
  }) {
    final normalizedOriginLat = originLat ?? MapsConfig.defaultStoreLat;
    final normalizedOriginLng = originLng ?? MapsConfig.defaultStoreLng;
    final knownLocation = knownVietnamLocation(destinationAddress);
    final destination = destinationLat != null && destinationLng != null
        ? '$destinationLat,$destinationLng'
        : knownLocation != null
        ? '${knownLocation.lat},${knownLocation.lng}'
        : normalizeVietnamAddress(destinationAddress);

    final query = {
      'api': '1',
      'destination': destination,
      'travelmode': 'two-wheeler',
    };

    if (!useCurrentLocationAsOrigin) {
      query['origin'] = '$normalizedOriginLat,$normalizedOriginLng';
    }

    return Uri.https('www.google.com', '/maps/dir/', query).toString();
  }

  Future<void> openDirectionsUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Không mở được Google Maps');
    }
  }
}
