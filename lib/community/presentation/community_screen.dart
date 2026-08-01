import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/app_route.dart';
import '../controller/community_controller.dart';
import '../../nav_bar/navbar_controller.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityController controller = Get.put(CommunityController());
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'general',
    'tips',
    'support',
    'workout',
    'nutrition',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Top Section with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark ? [
                    const Color(0xFF2C2C2C),
                    const Color(0xFF1E1E1E),
                    const Color(0xFF121212),
                  ] : [
                    AppColors.homeGradientStart,
                    AppColors.homeGradientMid,
                    AppColors.homeGradientEnd,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.find<NavbarController>().changePage(0),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Community',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Connect with your tribe',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 24),

                      // Create Post Input Card
                      GestureDetector(
                        onTap: _showCreatePostDialog,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.background
                                    .withOpacity(0.4),
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "What's on your mind?",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.accent : AppColors.textPrimary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Post',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isActive = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedCategory = cat);
                                controller.fetchPosts(category: cat);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white24,
                                  ),
                                ),
                                child: Text(
                                  cat.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Content Section
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }
                        if (controller.posts.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('No posts found in this category'),
                            ),
                          );
                        }
                        return Column(
                          children: controller.posts.map((post) {
                            final timeAgo = DateFormat('jm').format(post.createdAt);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildPostCard(
                                id: post.id,
                                username: post.authorName ?? 'Anonymous',
                                category: post.category,
                                timeAgo: timeAgo,
                                content: post.content,
                                likes: post.likes,
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    final postContentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Create Post',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: postContentController,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF333333) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textPrimary)),
            ),
            ElevatedButton(
            onPressed: () async {
              if (postContentController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please enter some content');
                return;
              }
              final postCategory = _selectedCategory == 'all' ? 'general' : _selectedCategory;
              final success = await controller.createPost(postContentController.text, postCategory);
              if (success) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.accent : AppColors.textPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Post'),
          ),
        ],
      );
    },
  );
}

  Widget _buildPostCard({
    required String id,
    required String username,
    required String category,
    required String timeAgo,
    required String content,
    required int likes,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () async {
        await controller.fetchPostDetails(id);
        Get.toNamed(AppRoute.postDetail);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                    username[0],
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryBadge(category),
                        ],
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'report') {
                      _showReportPostDialog(id, username, content);
                    } else if (value == 'block') {
                      _showBlockUserConfirmation(username);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag_outlined, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Text('Report Post'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Row(
                        children: [
                          Icon(Icons.block_rounded, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Block User'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionButton(
                  Icons.favorite_border_rounded,
                  likes.toString(),
                  onTap: () => controller.likePost(id, likes),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  Icons.chat_bubble_outline_rounded,
                  'Comment',
                  onTap: () async {
                    await controller.fetchPostDetails(id);
                    Get.toNamed(AppRoute.postDetail);
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 18, color: Colors.grey),
                  onPressed: () => _showReportPostDialog(id, username, content),
                  tooltip: 'Report Post',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportPostDialog(String postId, String authorName, String content) {
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
              title: const Text('Report Post', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Help us keep HerWellness safe. Select a reason:'),
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
                      contentType: 'post',
                      postId: postId,
                      reportedContent: content,
                      reportedAuthor: authorName,
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

  void _showBlockUserConfirmation(String username) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Block $username?'),
          content: const Text(
            'Blocking this user will permanently hide all their current and future posts and comments from your feed.',
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

  Widget _buildCategoryBadge(String category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    Color bg;
    switch (category) {
      case 'workout':
        color = isDark ? Colors.orange[300]! : Colors.orange[700]!;
        bg = isDark ? Colors.orange.withOpacity(0.2) : Colors.orange[50]!;
        break;
      case 'nutrition':
        color = isDark ? Colors.green[300]! : Colors.green[700]!;
        bg = isDark ? Colors.green.withOpacity(0.2) : Colors.green[50]!;
        break;
      case 'support':
        color = isDark ? Colors.pink[300]! : Colors.pink[700]!;
        bg = isDark ? Colors.pink.withOpacity(0.2) : Colors.pink[50]!;
        break;
      case 'tips':
        color = isDark ? Colors.blue[300]! : Colors.blue[700]!;
        bg = isDark ? Colors.blue.withOpacity(0.2) : Colors.blue[50]!;
        break;
      default:
        color = isDark ? Colors.grey[300]! : Colors.grey[700]!;
        bg = isDark ? Colors.grey.withOpacity(0.2) : Colors.grey[100]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
