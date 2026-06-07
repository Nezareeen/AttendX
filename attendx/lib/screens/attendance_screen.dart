import 'package:flutter/material.dart';
import 'package:attendx/theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _selectedWorkshop;
  bool _isSelfieTaken = false;
  bool _isLocationMatched = false;

  final List<String> _ongoingWorkshops = [
    'Flutter Masterclass - Hall A',
    'AI/ML Workshop - Room 102',
    'Design Thinking - Main Auditorium',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkStart,
      appBar: AppBar(
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
      body: SingleChildScrollView(
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedWorkshop,
                  hint: const Text("Choose an ongoing workshop"),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: _ongoingWorkshops.map((String workshop) {
                    return DropdownMenuItem<String>(
                      value: workshop,
                      child: Text(
                        workshop,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedWorkshop = newValue;
                    });
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
              onTap: () {
                // Simulate taking selfie and matching location
                setState(() {
                  _isSelfieTaken = !_isSelfieTaken;
                  _isLocationMatched = _isSelfieTaken;
                });
              },
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
                            child: Image.network(
                              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60', // Dummy selfie
                              fit: BoxFit.cover,
                            ),
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
                    subtitle: _isSelfieTaken
                        ? "12.9716° N, 77.5946° E"
                        : "Waiting for selfie...",
                    isVerified: _isSelfieTaken,
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
                        ? "12.9716° N, 77.5946° E"
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
                        Text(
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
                        _selectedWorkshop != null)
                    ? () {
                        // Submit attendance logic
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
                child: Text(
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
