import 'dart:io';
import 'package:flutter/material.dart';
import 'package:attendx/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:attendx/services/database_service.dart';
import 'package:attendx/models/database_models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Workshop? _selectedWorkshop;
  List<Workshop> _workshops = [];
  bool _isLoadingWorkshops = true;
  
  Position? _userPosition;
  String? _userAddress;
  bool _isLoadingLocation = true;

  bool _isSelfieTaken = false;
  bool _isLocationMatched = false;
  bool _isSubmitting = false;
  File? _imageFile;
  
  static const double _locationMatchThresholdMeters = 500.0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    // Fetch user location
    await _getUserLocation();
    
    // Fetch workshops
    try {
      final dbService = ref.read(databaseServiceProvider);
      final workshops = await dbService.getWorkshops();
      if (mounted) {
        setState(() {
          _workshops = workshops;
          _isLoadingWorkshops = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWorkshops = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading workshops: $e')),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _selectedWorkshop = null;
      _isSelfieTaken = false;
      _isLocationMatched = false;
      _imageFile = null;
      _isLoadingWorkshops = true;
      _isLoadingLocation = true;
    });
    await _fetchInitialData();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
          
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _userPosition = position;
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            _userAddress = '${place.street}, ${place.locality}, ${place.country}';
          } else {
            _userAddress = '${position.latitude}, ${position.longitude}';
          }
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _userAddress = 'Location Error';
        });
      }
    }
  }
  
  Future<void> _checkLocationMatch(Workshop workshop) async {
    if (_userPosition == null) return;
    
    try {
      List<Location> locations = await locationFromAddress(workshop.workshopLocation);
      if (locations.isNotEmpty) {
        final workshopLocation = locations.first;
        final distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          workshopLocation.latitude,
          workshopLocation.longitude,
        );
        
        if (mounted) {
          setState(() {
            _isLocationMatched = distance <= _locationMatchThresholdMeters;
          });
          
          if (!_isLocationMatched) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You are ${distance.toStringAsFixed(0)}m away. Must be within ${_locationMatchThresholdMeters}m.')),
            );
          }
        }
      }
    } catch (e) {
       if (mounted) {
         setState(() {
           _isLocationMatched = false;
         });
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Could not verify workshop location coordinates.')),
         );
       }
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isSelfieTaken = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkStart,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          "Mark Attendance",
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.grey.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.yellow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop Selection
            const Text(
              "Select Workshop",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoadingWorkshops
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<Workshop>(
                        value: _selectedWorkshop,
                        hint: const Text("Choose an ongoing workshop"),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: _workshops.map((Workshop workshop) {
                          return DropdownMenuItem<Workshop>(
                            value: workshop,
                            child: Text(
                              workshop.workshopPlace,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                        onChanged: (Workshop? newValue) {
                          setState(() {
                            _selectedWorkshop = newValue;
                            _isLocationMatched = false;
                          });
                          if (newValue != null) {
                            _checkLocationMatch(newValue);
                          }
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 32),

            // Selfie Section
            const Text(
              "Capture Selfie",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.grey.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isSelfieTaken
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _imageFile != null ? Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ) : null,
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 40,
                              color: AppColors.yellow,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Tap to take a selfie",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Location Verification Section
            const Text(
              "Location Verification",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildLocationRow(
                    icon: Icons.person_pin_circle_rounded,
                    title: "Your Location",
                    subtitle: _isLoadingLocation
                        ? "Fetching location..."
                        : (_userAddress ?? "Location not available"),
                    isVerified: _userPosition != null,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 24,
                        child: VerticalDivider(
                          color: AppColors.grey,
                          thickness: 1,
                        ),
                      ),
                    ),
                  ),
                  _buildLocationRow(
                    icon: Icons.location_on_rounded,
                    title: "Workshop Location",
                    subtitle: _selectedWorkshop != null
                        ? _selectedWorkshop!.workshopLocation
                        : "Select a workshop first",
                    isVerified: _selectedWorkshop != null,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _isLocationMatched
                          ? AppColors.black
                          : AppColors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLocationMatched
                              ? Icons.verified_user_rounded
                              : Icons.info_outline_rounded,
                          color: _isLocationMatched
                              ? AppColors.yellow
                              : AppColors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLocationMatched
                                ? "Location Matched Successfully"
                                : "Location match pending",
                            style: TextStyle(
                              color: _isLocationMatched
                                  ? AppColors.white
                                  : AppColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (_isSelfieTaken &&
                        _isLocationMatched &&
                        _selectedWorkshop != null &&
                        !_isSubmitting)
                    ? () async {
                        setState(() {
                          _isSubmitting = true;
                        });
                        try {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          
                          final storage = const FlutterSecureStorage();
                          final empIdStr = await storage.read(key: 'employeeId');
                          if (empIdStr == null) throw Exception('Not logged in');
                          
                          final empId = int.parse(empIdStr);
                          final dbService = ref.read(databaseServiceProvider);
                          String? imageUrl;
                          
                          if (_imageFile != null) {
                            final fileName = 'attendance_${empId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                            imageUrl = await dbService.uploadAttendanceImage(_imageFile!, fileName);
                          }
                          
                          await dbService.submitAttendance(
                            empId,
                            _selectedWorkshop!.workshopPlace,
                            _userAddress ?? "Unknown",
                            "Present",
                            imageUrl
                          );
                          
                          if (mounted) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Attendance submitted successfully!')),
                            );
                            setState(() {
                              _imageFile = null;
                              _isSelfieTaken = false;
                              _isLocationMatched = false;
                              _selectedWorkshop = null;
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSubmitting = false;
                            });
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  disabledBackgroundColor: AppColors.grey.withValues(
                    alpha: 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.black, strokeWidth: 2))
                  : Text(
                  "Submit Attendance",
                  style: TextStyle(
                    color:
                        (_isSelfieTaken &&
                            _isLocationMatched &&
                            _selectedWorkshop != null)
                        ? AppColors.black
                        : AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isVerified,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isVerified ? AppColors.black : AppColors.grey,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),
        ),
        if (isVerified)
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.black,
            size: 20,
          ),
      ],
    );
  }
}
