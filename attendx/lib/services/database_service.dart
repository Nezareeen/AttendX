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

  Future<Employee?> loginEmployee(int id, String password) async {
    final response = await _supabase
        .from('employees')
        .select()
        .eq('id', id)
        .eq('password', password)
        .maybeSingle();

    if (response != null) {
      return Employee.fromJson(response);
    }
    return null;
  }

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
}
