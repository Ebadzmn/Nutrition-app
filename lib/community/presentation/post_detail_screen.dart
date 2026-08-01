import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../controller/community_controller.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityController>();
    final commentController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        title: Text(
          'Discussion',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final post = controller.selectedPost.value;
        if (post == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final postTime = DateFormat('jm').format(post.createdAt);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original Post
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.background.withOpacity(0.4),
                          child: Text(
                            (post.authorName ?? 'A')[0].toUpperCase(),
                            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName ?? 'Anonymous',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                              ),
                              Text(postTime, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      post.content,
                      style: TextStyle(fontSize: 15, color: isDark ? Colors.white : AppColors.textPrimary, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => controller.likePost(post.id, post.likes),
                          child: _buildAction(Icons.favorite_rounded, post.likes.toString(), Colors.red),
                        ),
                        const SizedBox(width: 20),
                        _buildAction(Icons.chat_bubble_rounded, post.comments.length.toString(), isDark ? Colors.white : AppColors.textPrimary, isDark),
                        const Spacer(),
                        const Icon(Icons.share_rounded, size: 20, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Comments Section
              Text(
                'Comments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              if (post.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No comments yet. Be the first to reply!',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                ...post.comments.where((comment) {
                  final author = comment.createdBy.isNotEmpty ? comment.createdBy : (comment.authorName ?? '');
                  return !controller.blockedUsers.contains(author) && !controller.blockedUsers.contains(comment.authorName);
                }).map((comment) {
                  final commentTime = DateFormat('jm').format(comment.createdAt);
                  return _buildComment(
                    context: context,
                    controller: controller,
                    commentId: comment.id,
                    postId: post.id,
                    createdBy: comment.createdBy,
                    name: comment.authorName ?? 'Anonymous',
                    text: comment.content,
                    time: commentTime,
                    isDark: isDark,
                  );
                }).toList(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final post = controller.selectedPost.value;
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 10,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.background,
            border: Border(top: BorderSide(color: isDark ? Colors.white24 : Colors.black.withOpacity(0.05))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  if (post == null || commentController.text.trim().isEmpty) return;
                  final success = await controller.addComment(post.id, commentController.text.trim());
                  if (success) {
                    commentController.clear();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isDark ? AppColors.accent : AppColors.textPrimary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAction(IconData icon, String label, Color color, [bool isDark = false]) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildComment({
    required BuildContext context,
    required CommunityController controller,
    required String commentId,
    required String postId,
    required String createdBy,
    required String name,
    required String text,
    required String time,
    bool isDark = false,
  }) {
    final userIdentifier = createdBy.isNotEmpty ? createdBy : name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.background.withOpacity(0.4),
            child: Text(
              name.isEmpty ? 'A' : name[0].toUpperCase(),
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    Row(
                      children: [
                        Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'report') {
                              _showReportCommentDialog(context, controller, commentId, postId, userIdentifier, text);
                            } else if (value == 'block') {
                              _showBlockUserConfirmation(context, controller, userIdentifier);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'report',
                              child: Row(
                                children: [
                                  Icon(Icons.flag_outlined, color: Colors.orange, size: 16),
                                  SizedBox(width: 6),
                                  Text('Report Comment', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'block',
                              child: Row(
                                children: [
                                  Icon(Icons.block_rounded, color: Colors.redAccent, size: 16),
                                  SizedBox(width: 6),
                                  Text('Block User', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showReportCommentDialog(
    BuildContext context,
    CommunityController controller,
    String commentId,
    String postId,
    String author,
    String content,
  ) {
    String selectedReason = 'Objectionable Content';
    final List<String> reasons = [
      'Objectionable Content',
      'Abusive / Harassment',
      'Spam or misleading',
      'Inappropriate behavior',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report Comment', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select a reason for reporting this comment:'),
                  const SizedBox(height: 12),
                  ...reasons.map((r) => RadioListTile<String>(
                    title: Text(r, style: const TextStyle(fontSize: 13)),
                    value: r,
                    groupValue: selectedReason,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedReason = val);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () async {
                    Navigator.pop(context);
                    await controller.reportContent(
                      contentType: 'comment',
                      postId: postId,
                      commentId: commentId,
                      reportedContent: content,
                      reportedAuthor: author,
                      reason: selectedReason,
                    );
                  },
                  child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _showBlockUserConfirmation(BuildContext context, CommunityController controller, String username) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Block $username?'),
          content: const Text(
            'Blocking this user will permanently hide all their current and future posts and comments.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
              onPressed: () async {
                Navigator.pop(context);
                await controller.blockUser(username);
              },
              child: const Text('Block', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
