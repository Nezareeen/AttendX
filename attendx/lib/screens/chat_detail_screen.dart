import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../models/database_models.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final bool isGroup;
  final Employee? otherUser;

  const ChatDetailScreen({
    super.key,
    required this.isGroup,
    this.otherUser,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _optimisticMessages = [];
  final Set<String> _failedMessageIds = {};
  bool _isUploadingFile = false;

  Future<void> _pickAndSendFile(int currentUserId) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _isUploadingFile = true;
    });

    final chatService = ref.read(chatServiceProvider);
    
    try {
      String mimeType = 'application/octet-stream';
      if (file.extension != null) {
        final ext = file.extension!.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          mimeType = 'image/$ext';
        } else if (ext == 'pdf') {
          mimeType = 'application/pdf';
        } else if (['doc', 'docx'].contains(ext)) {
          mimeType = 'application/msword';
        }
      }

      final url = await chatService.uploadFile(file.name, file.bytes!, mimeType);
      
      if (url != null) {
        final content = _messageController.text.trim();
        _messageController.clear();
        
        await chatService.sendMessage(
          senderId: currentUserId,
          receiverId: widget.isGroup ? null : widget.otherUser?.id,
          isGroup: widget.isGroup,
          content: content.isEmpty ? 'File attached' : content,
          attachmentUrl: url,
          attachmentType: mimeType,
          attachmentName: file.name,
        );

        if (widget.isGroup) {
          ref.invalidate(groupMessagesProvider);
        } else if (widget.otherUser != null) {
          ref.invalidate(directMessagesProvider(widget.otherUser!.id));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingFile = false;
        });
      }
    }
  }

  Future<void> _sendMessage(int currentUserId) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final fakeId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newMessage = Message(
      id: fakeId,
      senderId: currentUserId,
      receiverId: widget.isGroup ? null : widget.otherUser?.id,
      isGroup: widget.isGroup,
      content: content,
      createdAt: DateTime.now(),
    );

    setState(() {
      _optimisticMessages.add(newMessage);
    });

    final chatService = ref.read(chatServiceProvider);
    
    try {
      await chatService.sendMessage(
        senderId: currentUserId,
        receiverId: widget.isGroup ? null : widget.otherUser?.id,
        isGroup: widget.isGroup,
        content: content,
      );

      if (widget.isGroup) {
        ref.invalidate(groupMessagesProvider);
      } else if (widget.otherUser != null) {
        ref.invalidate(directMessagesProvider(widget.otherUser!.id));
      }
      
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _optimisticMessages.removeWhere((m) => m.id == fakeId);
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _failedMessageIds.add(fakeId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final currentUserId = int.tryParse(user.id) ?? 0;
    
    final messagesAsync = widget.isGroup 
        ? ref.watch(groupMessagesProvider)
        : (widget.otherUser != null 
            ? ref.watch(directMessagesProvider(widget.otherUser!.id))
            : const AsyncValue.data(<Message>[]));

    final title = widget.isGroup ? "Company Group" : widget.otherUser?.employeeName ?? "Chat";

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: AppColors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                final serverMessages = messages.toList();
                final pendingMessages = _optimisticMessages.where((opt) => 
                  !serverMessages.any((m) => 
                    m.senderId == currentUserId && 
                    m.content == opt.content &&
                    m.createdAt.difference(opt.createdAt).inSeconds.abs() < 60
                  )
                ).toList();

                final allMessages = [...serverMessages, ...pendingMessages];

                if (allMessages.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet. Start the conversation!",
                      style: TextStyle(color: AppColors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final message = allMessages[index];
                    final isMe = message.senderId == currentUserId;
                    final isFailed = _failedMessageIds.contains(message.id);
                    
                    return _buildMessageBubble(message, isMe, isFailed: isFailed);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.yellow),
              ),
              error: (error, stack) => Center(
                child: Text(
                  "Error loading messages: $error",
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
          _buildMessageInput(currentUserId),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe, {bool isFailed = false}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.yellow.withValues(alpha: 0.8) : AppColors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isMe ? 8 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 8),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isGroup && !isMe) ...[
              Text(
                message.sender?.employeeName ?? "Employee #${message.senderId}", 
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
            ],
            if (message.attachmentUrl != null) ...[
              if (message.attachmentType?.startsWith('image/') == true)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.attachmentUrl!,
                    height: 150,
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 150,
                        width: 200,
                        child: Center(child: CircularProgressIndicator(color: AppColors.black)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      height: 150,
                      width: 200,
                      child: Center(child: Icon(Icons.error)),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, color: AppColors.black, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message.attachmentName ?? 'Attachment',
                          style: const TextStyle(color: AppColors.black, decoration: TextDecoration.underline, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
            ],
            Text(
              message.content,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                if (isMe && isFailed) ...[
                  const SizedBox(width: 4),
                  const Text(
                    "Failed",
                    style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                  )
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(int currentUserId) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Message",
                      hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.8)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isUploadingFile ? null : () => _pickAndSendFile(currentUserId),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _isUploadingFile 
                    ? const SizedBox(
                        width: 20, height: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black)
                      )
                    : const Icon(
                        Icons.attach_file,
                        color: AppColors.black,
                        size: 20,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isUploadingFile ? null : () => _sendMessage(currentUserId),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isUploadingFile ? AppColors.grey : AppColors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: AppColors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
