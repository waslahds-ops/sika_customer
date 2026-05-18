import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../injection_container.dart';
import '../../../orders/domain/entities/order_entities.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  final int orderId;

  const TrackOrderScreen({super.key, required this.orderId});

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _pollingTimer;

  // Tracking data from API
  LatLng? _agentLocation;
  LatLng? _deliveryLocation;
  String? _agentName;
  String? _agentPhone;
  String? _agentVehicleType;
  String? _estimatedArrival;

  // Markers
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    try {
      setState(() => _isLoading = true);

      final repository = ref.read(orderRepositoryProvider);
      final result = await repository.getOrderById(widget.orderId);

      OrderEntity? order;
      result.fold(
        (failure) {
          // If can't fetch order, assume no agent to be safe
          setState(() {
            _errorMessage = 'Unable to load order details. Please try again.';
            _isLoading = false;
          });
          return;
        },
        (orderEntity) {
          order = orderEntity;
        },
      );

      if (order == null) return;

      if (!_hasDeliveryAgent(order!)) {
        setState(() {
          _errorMessage =
              'Your order is on the way! Tracking information will be available once a delivery agent is assigned.';
          _isLoading = false;
        });
        return;
      }

      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.trackOrder(widget.orderId);

      print('📍 Agent Location: ${data['agent_location']}');
      print('📍 Delivery Address: ${data['delivery_address']}');

      setState(() {
        _agentLocation = LatLng(
          (data['agent_location']['latitude'] as num).toDouble(),
          (data['agent_location']['longitude'] as num).toDouble(),
        );
        _deliveryLocation = LatLng(
          (data['delivery_address']['latitude'] as num).toDouble(),
          (data['delivery_address']['longitude'] as num).toDouble(),
        );
        _agentName = data['agent']?['name'] as String?;
        _agentPhone = data['agent']?['phone'] as String?;
        _agentVehicleType = data['agent']?['vehicle_type'] as String?;
        _estimatedArrival = data['estimated_arrival'] as String?;
        _isLoading = false;
      });

      _initializeMap();
      _startPolling();
    } catch (e) {
      String message = 'Failed to load tracking data. Please try again.';
      if (e is DioException) {
        final status = e.response?.statusCode;
        if (status == 401) {
          message = 'Authentication required. Please sign in to track orders.';
        } else if (status == 403) {
          message = 'Account not verified. Please verify your account to enable tracking.';
        } else if (status == 404) {
          message = 'Tracking information not available yet. Please try again later.';
        } else if (e.message != null) {
          message = e.message!;
        }
      } else if (e.toString().contains('No delivery agent assigned')) {
        message = 'Your order is on the way! Tracking information will be available once a delivery agent is assigned.';
      }

      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  void _startPolling({int intervalSeconds = 8}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      try {
        final apiService = ref.read(apiServiceProvider);
        final data = await apiService.trackOrder(widget.orderId);

        if (!mounted) return;

        setState(() {
          _agentLocation = LatLng(
            (data['agent_location']['latitude'] as num).toDouble(),
            (data['agent_location']['longitude'] as num).toDouble(),
          );
          _deliveryLocation = LatLng(
            (data['delivery_address']['latitude'] as num).toDouble(),
            (data['delivery_address']['longitude'] as num).toDouble(),
          );
          _agentName = data['agent']?['name'] as String?;
          _agentPhone = data['agent']?['phone'] as String?;
          _agentVehicleType = data['agent']?['vehicle_type'] as String?;
          _estimatedArrival = data['estimated_arrival'] as String?;
        });

        _setupMarkers();
        _setupPolyline();
        _moveCameraToShowBothMarkers();
      } catch (e) {
        // Ignore polling errors silently; UI has retry button for fatal errors
        print('Polling error: $e');
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  bool _hasDeliveryAgent(OrderEntity order) {
    return order.agentId != null ||
        order.agentName != null ||
        order.deliveryAgentId != null;
  }

  Future<void> _initializeMap() async {
    if (_agentLocation == null || _deliveryLocation == null) return;

    _setupMarkers();
    _setupPolyline();
  }

  void _setupMarkers() {
    if (_agentLocation == null || _deliveryLocation == null || !mounted) return;

    _markers.clear();

    // Agent/Driver marker
    _markers.add(
      Marker(
        markerId: const MarkerId('agent'),
        position: _agentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: _agentName ?? 'Your Driver',
          snippet: 'Driver is on the way',
        ),
      ),
    );

    // Delivery location marker (destination)
    _markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: _deliveryLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Delivery Location'),
      ),
    );

    setState(() {});
  }

  void _setupPolyline() {
    if (_agentLocation == null || _deliveryLocation == null || !mounted) return;

    // Route from agent/driver to delivery location
    final List<LatLng> polylineCoordinates = [
      _agentLocation!,
      _deliveryLocation!,
    ];

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylineCoordinates,
        color: AppPallete.primaryYellow,
        width: 5,
        geodesic: true,
      ),
    );

    setState(() {});
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _stopPolling();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: const Center(child: AppLoader()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppPallete.backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        backgroundColor: AppPallete.backgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _loadTrackingData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryYellow,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  _agentLocation ??
                  _deliveryLocation ??
                  const LatLng(15.5007, 32.5599),
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _moveCameraToShowBothMarkers();
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Track Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                    ),
                  );
                }
              },
              child: const Icon(
                Icons.my_location,
                color: AppPallete.primaryYellow,
              ),
            ),
          ),

          // Bottom Order Info Card with Delivery Agent
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Delivery Agent Info
                  if (_agentName != null || _agentPhone != null)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue[100],
                                ),
                                child: Icon(
                                  Icons.person_outlined,
                                  color: Colors.blue[700],
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your Driver',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _agentName ?? 'Your Driver',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_agentVehicleType != null)
                                      Text(
                                        _agentVehicleType!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_agentPhone != null)
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green[100],
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      // Call driver
                                      final Uri launchUri = Uri(
                                        scheme: 'tel',
                                        path: _agentPhone,
                                      );
                                      await launchUrl(launchUri);
                                    },
                                    icon: Icon(
                                      Icons.phone,
                                      color: Colors.green[700],
                                      size: 18,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Estimated Arrival
                  if (_estimatedArrival != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estimated Arrival',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _estimatedArrival!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_estimatedArrival != null) const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/food1.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Uttoro Coffee House',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ordered At 06 Sept, 10:00pm',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.orderedItems,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppLocalizations.of(context)!.twoItems,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _moveCameraToShowBothMarkers() {
    if (_agentLocation == null ||
        _deliveryLocation == null ||
        _mapController == null) {
      return;
    }

    // Calculate bounds to include agent and delivery markers
    double minLat = _agentLocation!.latitude < _deliveryLocation!.latitude
        ? _agentLocation!.latitude
        : _deliveryLocation!.latitude;
    double maxLat = _agentLocation!.latitude > _deliveryLocation!.latitude
        ? _agentLocation!.latitude
        : _deliveryLocation!.latitude;
    double minLng = _agentLocation!.longitude < _deliveryLocation!.longitude
        ? _agentLocation!.longitude
        : _deliveryLocation!.longitude;
    double maxLng = _agentLocation!.longitude > _deliveryLocation!.longitude
        ? _agentLocation!.longitude
        : _deliveryLocation!.longitude;

    // Add some padding
    double latPadding = (maxLat - minLat) * 0.1;
    double lngPadding = (maxLng - minLng) * 0.1;

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
