import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/database_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supabase_provider.dart';
import 'encryption_service.dart';
import 'dart:typed_data';

final chatServiceProvider = Provider<ChatService>((ref) {
  final supabaseClient = ref.watch(supabaseProvider);
  return ChatService(supabaseClient);
});

class ChatService {
  final SupabaseClient _supabase;

  ChatService(this._supabase);

  // Fetch all employees except the current one
  Future<List<Employee>> getEmployees(int currentUserId) async {
    final response = await _supabase
        .from('employees')
        .select()
        .neq('id', currentUserId);
    
    return (response as List<dynamic>)
        .map((json) => Employee.fromJson(json))
        .toList();
  }

  // Fetch group messages
  Future<List<Message>> getGroupMessages() async {
    final response = await _supabase
        .from('messages')
        .select('*, employees:employees!messages_sender_id_fkey(*)')
        .eq('is_group', true)
        .order('created_at', ascending: true);
        
    return (response as List<dynamic>).map((e) {
      final Map<String, dynamic> data = Map.from(e);
      data['content'] = EncryptionService.decryptMessage(data['content'] as String? ?? '');
      return Message.fromJson(data);
    }).toList();
  }

  // Fetch direct messages between two users
  Future<List<Message>> getDirectMessages(int user1Id, int user2Id) async {
    final response = await _supabase
        .from('messages')
        .select('*, employees:employees!messages_sender_id_fkey(*)')
        .eq('is_group', false)
        .filter('sender_id', 'in', [user1Id, user2Id])
        .filter('receiver_id', 'in', [user1Id, user2Id])
        .order('created_at', ascending: true);
        
    final messages = (response as List<dynamic>).map((e) {
      final Map<String, dynamic> data = Map.from(e);
      data['content'] = EncryptionService.decryptMessage(data['content'] as String? ?? '');
      return Message.fromJson(data);
    }).toList();
    return messages;
  }

  // Upload a file for chat attachment
  Future<String?> uploadFile(String fileName, Uint8List fileBytes, String mimeType) async {
    try {
      final String path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await _supabase.storage.from('chat_attachments').uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType),
      );

      final String publicUrl = _supabase.storage.from('chat_attachments').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Send a message
  Future<void> sendMessage({
    required int senderId,
    int? receiverId,
    required bool isGroup,
    required String content,
    String? attachmentUrl,
    String? attachmentType,
    String? attachmentName,
  }) async {
    final encryptedContent = EncryptionService.encryptMessage(content);
    await _supabase.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'is_group': isGroup,
      'content': encryptedContent,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      if (attachmentType != null) 'attachment_type': attachmentType,
      if (attachmentName != null) 'attachment_name': attachmentName,
    });
  }
}
