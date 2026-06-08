import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendx/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: AppColors.black,
        title: const Text(
          "Chats",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: employeesAsync.when(
        data: (employees) {
          return ListView.builder(
            itemCount: employees.length + 1, // +1 for the group chat
            itemBuilder: (context, index) {
              if (index == 0) {
                // Group Chat Item
                return _buildChatListItem(
                  context,
                  title: "Company Group",
                  subtitle: "Chat with everyone",
                  icon: Icons.groups_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ChatDetailScreen(isGroup: true),
                      ),
                    );
                  },
                );
              }

              final employee = employees[index - 1];
              return _buildChatListItem(
                context,
                title: employee.employeeName,
                subtitle: employee.designation,
                icon: Icons.person_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatDetailScreen(isGroup: false, otherUser: employee),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.yellow),
        ),
        error: (error, stack) => Center(
          child: Text(
            "Error loading chats: $error",
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildChatListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.grey.withValues(alpha: 0.2),
        radius: 26,
        child: Icon(icon, color: AppColors.grey, size: 30),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.grey, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
