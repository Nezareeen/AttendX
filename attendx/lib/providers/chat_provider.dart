import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/database_models.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';
import 'user_provider.dart';

// Provider to fetch all employees
final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  final user = ref.watch(userProvider);
  
  if (user.id.isEmpty) return [];
  
  final currentUserId = int.tryParse(user.id) ?? 0;
  if (currentUserId == 0) return [];

  return chatService.getEmployees(currentUserId);
});

// Provider to stream group messages via polling
final groupMessagesProvider = StreamProvider<List<Message>>((ref) async* {
  final chatService = ref.watch(chatServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final user = ref.watch(userProvider);
  final currentUserId = int.tryParse(user.id) ?? 0;
  
  List<Message> lastMessages = [];
  
  try {
    lastMessages = await chatService.getGroupMessages();
    yield lastMessages;
  } catch (e) {
    yield [];
  }

  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    try {
      final messages = await chatService.getGroupMessages();
      
      if (lastMessages.isNotEmpty && messages.length > lastMessages.length) {
        final newMessages = messages.sublist(lastMessages.length);
        for (var msg in newMessages) {
          if (msg.senderId != currentUserId) {
            final senderName = msg.sender?.employeeName ?? "Employee #${msg.senderId}";
            notificationService.showNotification(
              id: msg.id.hashCode,
              title: 'Group Chat - $senderName',
              body: msg.content,
            );
          }
        }
      }
      
      lastMessages = messages;
      yield messages;
    } catch (e) {
      // Skip yielding on error to keep last valid state
    }
  }
});

// Provider family to stream direct messages via polling
final directMessagesProvider = StreamProvider.family<List<Message>, int>((ref, otherUserId) async* {
  final chatService = ref.watch(chatServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final user = ref.watch(userProvider);
  
  if (user.id.isEmpty) {
    yield [];
    return;
  }
  
  final currentUserId = int.tryParse(user.id) ?? 0;
  if (currentUserId == 0) {
    yield [];
    return;
  }

  List<Message> lastMessages = [];
  
  try {
    lastMessages = await chatService.getDirectMessages(currentUserId, otherUserId);
    yield lastMessages;
  } catch (e) {
    yield [];
  }

  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    try {
      final messages = await chatService.getDirectMessages(currentUserId, otherUserId);
      
      if (lastMessages.isNotEmpty && messages.length > lastMessages.length) {
        final newMessages = messages.sublist(lastMessages.length);
        for (var msg in newMessages) {
          if (msg.senderId != currentUserId) {
            final senderName = msg.sender?.employeeName ?? "Employee #${msg.senderId}";
            notificationService.showNotification(
              id: msg.id.hashCode,
              title: senderName,
              body: msg.content,
            );
          }
        }
      }
      
      lastMessages = messages;
      yield messages;
    } catch (e) {
      // Skip yielding on error
    }
  }
});
