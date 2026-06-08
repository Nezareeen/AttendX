import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/database_models.dart';
import '../providers/supabase_provider.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final supabaseClient = ref.watch(supabaseProvider);
  return DatabaseService(supabaseClient);
});

class DatabaseService {
  final SupabaseClient _supabase;

  DatabaseService(this._supabase);

  Future<int> getAttendanceCount(String employeeId) async {
    final response = await _supabase
        .from('attendance')
        .select('id')
        .eq('employee_id', employeeId);

    return (response as List).length;
  }

  Future<List<Leave>> getLeavesByEmployeeName(String employeeName) async {
    final response = await _supabase
        .from('leaves')
        .select()
        .eq('employeeName', employeeName)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Leave.fromJson(json))
        .toList();
  }

  Future<void> submitLeaveRequest(Leave leave) async {
    await _supabase.from('leaves').insert({
      'employeeName': leave.employeeName,
      'leave_title': leave.leaveTitle,
      'leave_decription': leave.leaveDescription,
      'leave_status': leave.leaveStatus,
    });
  }

  Future<List<Workshop>> getWorkshops() async {
    final response = await _supabase
        .from('workshops')
        .select()
        .order('workshop_time', ascending: true);

    return (response as List<dynamic>)
        .map((json) => Workshop.fromJson(json))
        .toList();
  }

  Future<List<Attendance>> getAttendanceHistory(int employeeId) async {
    final response = await _supabase
        .from('attendance')
        .select()
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Attendance.fromJson(json))
        .toList();
  }

  Future<String?> uploadAttendanceImage(File imageFile, String fileName) async {
    try {
      await _supabase.storage.from('attendance-images').upload(fileName, imageFile);
      return _supabase.storage.from('attendance-images').getPublicUrl(fileName);
    } catch (e) {
      // Error uploading image
      return null;
    }
  }

  Future<void> submitAttendance(int employeeId, String workshopName, String locationStatus, String status, String? imageUrl) async {
    await _supabase.from('attendance').insert({
      'employee_id': employeeId,
      'workshop_name': workshopName,
      'location_status': locationStatus,
      'attendance': status,
      if (imageUrl != null) 'image_url': imageUrl,
    });
  }
}
