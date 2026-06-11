import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../config/maps_config.dart';
import '../services/maps_service.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({
    super.key,
    required this.customerAddress,
    required this.directionsUrl,
    this.storeLat,
    this.storeLng,
    this.customerLat,
    this.customerLng,
  });

  final String customerAddress;
  final String directionsUrl;
  final double? storeLat;
  final double? storeLng;
  final double? customerLat;
  final double? customerLng;

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  final _mapsService = const MapsService();
  late final String _viewType;
  String? _registeredEmbedUrl;

  @override
  void initState() {
    super.initState();
    _viewType = 'google-map-${identityHashCode(this)}';
    _registerMapIfPossible();
  }

  @override
  void didUpdateWidget(covariant GoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registerMapIfPossible();
  }

  void _registerMapIfPossible() {
    final embedUrl = _buildEmbedUrl();
    if (embedUrl == null || embedUrl == _registeredEmbedUrl) return;

    _registeredEmbedUrl = embedUrl;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = embedUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = '0'
        ..loading = 'lazy'
        ..allowFullscreen = true
        ..referrerPolicy = 'no-referrer-when-downgrade';
      return iframe;
    });
  }

  String? _buildEmbedUrl() {
    if (MapsConfig.googleMapsApiKey.isEmpty) return null;

    final knownLocation = _mapsService.knownVietnamLocation(
      widget.customerAddress,
    );
    final destination = widget.customerLat != null && widget.customerLng != null
        ? '${widget.customerLat},${widget.customerLng}'
        : knownLocation != null
        ? '${knownLocation.lat},${knownLocation.lng}'
        : _mapsService.normalizeVietnamAddress(widget.customerAddress);

    if (destination.isEmpty) return null;

    return Uri.https('www.google.com', '/maps/embed/v1/directions', {
      'key': MapsConfig.googleMapsApiKey,
      'origin':
          '${widget.storeLat ?? MapsConfig.defaultStoreLat},${widget.storeLng ?? MapsConfig.defaultStoreLng}',
      'destination': destination,
      // Google Maps Embed Directions does not officially support two-wheeler.
      // The external Google Maps button below opens motorcycle mode instead.
      'mode': 'driving',
    }).toString();
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = _buildEmbedUrl();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 260,
            child: embedUrl == null
                ? _MapFallback(
                    customerAddress: widget.customerAddress,
                    onOpenDirections: _openDirections,
                  )
                : HtmlElementView(viewType: _viewType),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _openDirections,
          icon: const Icon(Icons.two_wheeler_outlined),
          label: const Text('Mở chỉ đường xe máy'),
        ),
      ],
    );
  }

  Future<void> _openDirections() async {
    if (widget.directionsUrl.trim().isEmpty) return;
    try {
      await _mapsService.openDirectionsUrl(widget.directionsUrl);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({
    required this.customerAddress,
    required this.onOpenDirections,
  });

  final String customerAddress;
  final VoidCallback onOpenDirections;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffe8f3f0),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 44, color: Color(0xff0f766e)),
          const SizedBox(height: 12),
          const Text(
            'Chưa hiển thị bản đồ trực tiếp',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            customerAddress.isEmpty
                ? 'Thiếu địa chỉ giao hàng hoặc Google Maps API key.'
                : customerAddress,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpenDirections,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Mở bằng Google Maps'),
          ),
        ],
      ),
    );
  }
}
