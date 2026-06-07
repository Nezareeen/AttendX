import 'package:attendx/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:attendx/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendx/services/database_service.dart';
import 'package:attendx/models/database_models.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;

  const ProfileScreen({super.key, this.onNavigate});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _username = "Loading...";
  String _role = "Loading...";
  final _storage = const FlutterSecureStorage();
  
  List<Attendance> _attendanceHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _storage.read(key: 'EmployeeName');
      final role = await _storage.read(key: 'role');
      final empIdStr = await _storage.read(key: 'employeeId');
      
      if (mounted) {
        setState(() {
          _username = name ?? "Employee";
          _role = role ?? "User";
        });
      }
      
      if (empIdStr != null) {
        final empId = int.parse(empIdStr);
        final history = await ref.read(databaseServiceProvider).getAttendanceHistory(empId);
        if (mounted) {
          setState(() {
            _attendanceHistory = history;
            _isLoadingHistory = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingHistory = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile data: $e')),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoadingHistory = true;
    });
    await _loadUserData();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkStart,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          "Profile",
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24.0),
              color: AppColors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.yellow,
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _role,
                          style: const TextStyle(fontSize: 16, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.black),
                    onPressed: () {
                      if (widget.onNavigate != null) {
                        widget.onNavigate!(4);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Settingscreen(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1.0,
              color: AppColors.grey.withValues(alpha: 0.2),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                "Attendance History",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            Expanded(
              child: _isLoadingHistory 
                ? const Center(child: CircularProgressIndicator(color: AppColors.black))
                : _attendanceHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 48, color: AppColors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text("No attendance history found", style: TextStyle(color: AppColors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _onRefresh,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
                            child: const Text("Refresh", style: TextStyle(color: AppColors.black)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.yellow,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        itemCount: _attendanceHistory.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final attendance = _attendanceHistory[index];
                          final isPresent = attendance.attendance == 'Present';

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.grey.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.0),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: isPresent
                                              ? AppColors.yellow.withValues(alpha: 0.2)
                                              : AppColors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isPresent
                                              ? Icons.check_circle_outline
                                              : Icons.highlight_off,
                                          color: isPresent
                                              ? AppColors.yellow
                                              : AppColors.grey,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              attendance.workshopName,
                                              style: const TextStyle(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                letterSpacing: -0.3,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: AppColors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(attendance.createdAt),
                                                  style: const TextStyle(
                                                    color: AppColors.grey,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPresent
                                              ? AppColors.black
                                              : AppColors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isPresent
                                                ? AppColors.black
                                                : AppColors.grey.withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Text(
                                          attendance.attendance,
                                          style: TextStyle(
                                            color: isPresent
                                                ? AppColors.white
                                                : AppColors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
