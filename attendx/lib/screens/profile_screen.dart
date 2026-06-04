import 'package:attendx/screens/SettingScreen.dart';
import 'package:flutter/material.dart';
import 'package:attendx/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> _workshops = [
    {'title': 'Narayana Workshop', 'date': 'Oct 12, 2023', 'status': 'Present'},
    {
      'title': 'Aditya degree college workshop',
      'date': 'Oct 15, 2023',
      'status': 'Absent',
    },
    {'title': 'Narayana Workshop', 'date': 'Nov 02, 2023', 'status': 'Present'},
    {
      'title': 'Aditya degree college workshop',
      'date': 'Nov 18, 2023',
      'status': 'Present',
    },
    {'title': 'Narayana Workshop', 'date': 'Dec 05, 2023', 'status': 'Absent'},
    {
      'title': 'Aditya degree college workshop',
      'date': 'Dec 12, 2023',
      'status': 'Present',
    },
    {'title': 'Narayana Workshop', 'date': 'Jan 02, 2024', 'status': 'Absent'},
    {
      'title': 'Aditya degree college workshop',
      'date': 'Jan 18, 2024',
      'status': 'Present',
    },
    {'title': 'Narayana Workshop', 'date': 'Feb 05, 2024', 'status': 'Absent'},
    {
      'title': 'Aditya degree college workshop',
      'date': 'Feb 12, 2024',
      'status': 'Present',
    },
    {'title': 'Narayana Workshop', 'date': 'Mar 02, 2024', 'status': 'Absent'},
    {
      'title': 'Aditya degree college workshop',
      'date': 'Mar 18, 2024',
      'status': 'Present',
    },
  ];

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
          child: Container(color: AppColors.grey.withOpacity(0.2), height: 1.0),
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
                      "T",
                      style: TextStyle(
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
                          "Tushar",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Trainer",
                          style: TextStyle(fontSize: 16, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Settingscreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 1.0,
              color: AppColors.grey.withOpacity(0.2),
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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                itemCount: _workshops.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final workshop = _workshops[index];
                  final isPresent = workshop['status'] == 'Present';

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.15),
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
                                      ? AppColors.yellow.withOpacity(0.2)
                                      : AppColors.grey.withOpacity(0.1),
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
                                      workshop['title'],
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
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: AppColors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          workshop['date'],
                                          style: TextStyle(
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
                                        : AppColors.grey.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  workshop['status'],
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
          ],
        ),
      ),
    );
  }
}
