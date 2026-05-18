import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:async';
import '../../../../l10n/app_localizations.dart';

class HomeMapSection extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;
  final ValueChanged<Map<String, dynamic>>? onLocationSelected;

  const HomeMapSection({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
    this.onLocationSelected,
  });

  @override
  State<HomeMapSection> createState() => _HomeMapSectionState();
}

class _HomeMapSectionState extends State<HomeMapSection> {
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _selectedLocation;
  String _selectedAddressEn = '';
  String _selectedAddressAr = '';
  bool _isLoading = false;
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      _selectedAddressEn = widget.initialAddress ?? '';
      _selectedAddressAr = widget.initialAddress ?? '';
    } else {
      await _getCurrentLocation();
    }

    _initialCameraPosition = CameraPosition(
      target:
          _selectedLocation ?? const LatLng(33.8547, 35.8623), // Beirut default
      zoom: 15,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.locationPermissionDenied)),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.locationPermissionDeniedForever),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = location;
      });

      // Get address from coordinates
      await _getAddressFromLatLng(location);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.errorGettingLocation}: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // For now, we'll use the same address for both languages
        // In a real scenario, you might want to call different geocoding APIs
        final address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';

        setState(() {
          _selectedAddressEn = address;
          _selectedAddressAr = address;
        });

        // Notify parent
        widget.onLocationSelected?.call({
          'latitude': location.latitude,
          'longitude': location.longitude,
          'addressEn': _selectedAddressEn,
          'addressAr': _selectedAddressAr,
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _onCameraMove(LatLng newLocation) async {
    setState(() {
      _selectedLocation = newLocation;
    });
    await _getAddressFromLatLng(newLocation);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationSelected?.call({
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'addressEn': _selectedAddressEn,
        'addressAr': _selectedAddressAr,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final displayAddress = isArabic ? _selectedAddressAr : _selectedAddressEn;

    if (_selectedLocation == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            onCameraMove: (CameraPosition cameraPosition) {
              _onCameraMove(cameraPosition.target);
            },
            markers: {
              if (_selectedLocation != null)
                Marker(
                  markerId: MarkerId('selected_location'),
                  position: _selectedLocation!,
                  infoWindow: InfoWindow(
                    title: isArabic ? 'الموقع المختار' : 'Selected Location',
                  ),
                ),
            },
          ),

          // Center marker (pin icon in center of map)
          Center(child: Icon(Icons.location_on, color: Colors.red, size: 40)),

          // Address display card at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'العنوان المختار' : 'Selected Address',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03833d),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        l10n.confirmDeliveryAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
