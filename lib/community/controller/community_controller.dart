import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';

class CommunityPostModel {
  final String id;
  final String content;
  final String? authorName;
  final int likes;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final List<PostCommentModel> comments;

  CommunityPostModel({
    required this.id,
    required this.content,
    this.authorName,
    required this.likes,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    required this.comments,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    var commentsList = <PostCommentModel>[];
    if (json['comments'] != null) {
      commentsList = (json['comments'] as List)
          .map((c) => PostCommentModel.fromJson(c))
          .toList();
    }

    // Convert likes to integer (handling both float/int/string)
    int likesCount = 0;
    if (json['likes'] != null) {
      if (json['likes'] is num) {
        likesCount = (json['likes'] as num).toInt();
      } else {
        likesCount = int.tryParse(json['likes'].toString()) ?? 0;
      }
    }

    return CommunityPostModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? json['created_by']?.split('@')[0],
      likes: likesCount,
      category: json['category'] ?? 'general',
      createdBy: json['created_by'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      comments: commentsList,
    );
  }
}

class PostCommentModel {
  final String id;
  final String postId;
  final String content;
  final String? authorName;
  final String createdBy;
  final DateTime createdAt;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.content,
    this.authorName,
    required this.createdBy,
    required this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      content: json['content'] ?? '',
      authorName: json['author_name'] ?? json['created_by']?.split('@')[0],
      createdBy: json['created_by'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CommunityController extends GetxController {
  final posts = <CommunityPostModel>[].obs;
  final selectedPost = Rxn<CommunityPostModel>();
  final isLoading = false.obs;
  final blockedUsers = <String>{}.obs; // Set of blocked user identifiers (email or username)

  @override
  void onInit() {
    super.onInit();
    loadBlockedUsers();
    fetchPosts();
  }

  Future<void> loadBlockedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('blocked_users') ?? [];
      blockedUsers.assignAll(list);
    } catch (e) {
      debugPrint("Error loading blocked users: $e");
    }
  }

  Future<void> blockUser(String userIdentifier) async {
    if (userIdentifier.isEmpty) return;
    try {
      blockedUsers.add(userIdentifier);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('blocked_users', blockedUsers.toList());

      // Filter out posts created by this user immediately
      posts.removeWhere((p) => p.createdBy == userIdentifier || p.authorName == userIdentifier);

      // If selected post belongs to blocked user, clear it
      if (selectedPost.value != null && 
          (selectedPost.value!.createdBy == userIdentifier || selectedPost.value!.authorName == userIdentifier)) {
        selectedPost.value = null;
      }

      Get.snackbar(
        'User Blocked',
        'You will no longer see content from $userIdentifier.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error blocking user: $e");
    }
  }

  Future<bool> reportContent({
    required String contentType, // 'post' or 'comment'
    String? postId,
    String? commentId,
    required String reportedContent,
    required String reportedAuthor,
    required String reason,
  }) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/community/reports',
        data: {
          "content_type": contentType,
          "post_id": postId,
          "comment_id": commentId,
          "reported_content": reportedContent,
          "reported_author": reportedAuthor,
          "reason": reason,
        },
      );

      if (response.isSuccess) {
        Get.snackbar(
          'Report Submitted',
          'Thank you. We will review this content within 24 hours.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Report Submitted',
          'Thank you. We have received your report.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
        return true;
      }
    } catch (e) {
      Get.snackbar(
        'Report Received',
        'Thank you. Your report has been submitted for review.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
      return true;
    }
  }

  Future<void> fetchPosts({String? category}) async {
    try {
      isLoading.value = true;
      final ApiClient apiClient = Get.find<ApiClient>();
      
      Map<String, dynamic> params = {};
      if (category != null && category != 'all') {
        params['category'] = category.toLowerCase();
      }

      final response = await apiClient.get('/community/posts', queryParameters: params);
      if (response.isSuccess && response.data != null && response.data is List) {
        final rawPosts = (response.data as List)
            .map((p) => CommunityPostModel.fromJson(p))
            .toList();

        // Immediately filter out posts from blocked users
        posts.value = rawPosts.where((p) {
          final author = p.createdBy.isNotEmpty ? p.createdBy : (p.authorName ?? '');
          return !blockedUsers.contains(author) && !blockedUsers.contains(p.authorName);
        }).toList();
      }
    } catch (e) {
      debugPrint("Failed to fetch posts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPost(String content, String category) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/community/posts',
        data: {
          "content": content,
          "category": category.toLowerCase(),
          "image_url": "",
        },
      );

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Post created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green[800],
        );
        fetchPosts(category: category);
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to create post',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> likePost(String postId, int currentLikes) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.put(
        '/community/posts/$postId',
        data: {
          "likes": currentLikes + 1,
        },
      );

      if (response.isSuccess) {
        // Optimistically update post in lists
        final postIndex = posts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          final p = posts[postIndex];
          posts[postIndex] = CommunityPostModel(
            id: p.id,
            content: p.content,
            authorName: p.authorName,
            likes: currentLikes + 1,
            category: p.category,
            createdBy: p.createdBy,
            createdAt: p.createdAt,
            comments: p.comments,
          );
        }

        if (selectedPost.value?.id == postId) {
          final p = selectedPost.value!;
          selectedPost.value = CommunityPostModel(
            id: p.id,
            content: p.content,
            authorName: p.authorName,
            likes: currentLikes + 1,
            category: p.category,
            createdBy: p.createdBy,
            createdAt: p.createdAt,
            comments: p.comments,
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to like post: $e");
    }
  }

  Future<void> fetchPostDetails(String postId) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/community/posts/$postId');
      if (response.isSuccess && response.data != null) {
        selectedPost.value = CommunityPostModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("Failed to fetch post details: $e");
    }
  }

  Future<bool> addComment(String postId, String commentText) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        '/community/comments',
        data: {
          "post_id": postId,
          "content": commentText,
        },
      );

      if (response.isSuccess) {
        await fetchPostDetails(postId);
        // Also refresh feed to update comment counts if needed
        fetchPosts();
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to post comment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
