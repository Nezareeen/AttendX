import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendx/providers/user_provider.dart';
import 'package:attendx/models/database_models.dart';
import 'package:attendx/services/database_service.dart';

final leavesProvider = FutureProvider<List<Leave>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  final userData = ref.watch(userProvider);
  
  if (userData.id.isEmpty) {
    return [];
  }

  return await databaseService.getLeavesByEmployeeName(userData.name);
});
