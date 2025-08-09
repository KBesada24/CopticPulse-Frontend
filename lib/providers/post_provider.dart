import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../utils/constants.dart';

/// Provider for managing post state throughout the app
class PostProvider extends ChangeNotifier {
  final PostService _postService;

  PostProvider({PostService? postService}) : _postService = postService ?? PostService();

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  PostType? _selectedFilter;
  int _currentPage = 1;
  bool _hasNextPage = true;
  String? _searchQuery;

  /// Current list of posts
  List<Post> get posts => _posts;

  /// Whether initial loading is in progress
  bool get isLoading => _isLoading;

  /// Whether loading more posts is in progress
  bool get isLoadingMore => _isLoadingMore;

  /// Current error message, if any
  String? get errorMessage => _errorMessage;

  /// Currently selected post type filter
  PostType? get selectedFilter => _selectedFilter;

  /// Whether there are more posts to load
  bool get hasNextPage => _hasNextPage;

  /// Current search query
  String? get searchQuery => _searchQuery;

  /// Whether posts are currently filtered
  bool get isFiltered => _selectedFilter != null || _searchQuery != null;

  /// Load posts with optional filtering
  Future<void> loadPosts({
    PostType? type,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _posts.clear();
    }

    if (_isLoading || (!_hasNextPage && !refresh)) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _postService.getPosts(
        type: type,
        page: _currentPage,
        limit: AppConstants.defaultPageSize,
      );

      if (refresh) {
        _posts = response.posts;
      } else {
        _posts.addAll(response.posts);
      }

      _hasNextPage = response.hasNextPage;
      _selectedFilter = type;
      _searchQuery = null;
      
      notifyListeners();
    } on PostServiceException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load posts');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasNextPage) return;

    _setLoadingMore(true);

    try {
      _currentPage++;
      
      PostResponse response;
      if (_searchQuery != null) {
        response = await _postService.searchPosts(
          query: _searchQuery!,
          type: _selectedFilter,
          page: _currentPage,
        );
      } else {
        response = await _postService.getPosts(
          type: _selectedFilter,
          page: _currentPage,
        );
      }

      _posts.addAll(response.posts);
      _hasNextPage = response.hasNextPage;
      
      notifyListeners();
    } on PostServiceException catch (e) {
      _currentPage--; // Revert page increment on error
      _setError(e.message);
    } catch (e) {
      _currentPage--; // Revert page increment on error
      _setError('Failed to load more posts');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Search posts by query
  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      await loadPosts(refresh: true);
      return;
    }

    _currentPage = 1;
    _hasNextPage = true;
    _posts.clear();
    _searchQuery = query.trim();

    _setLoading(true);
    _clearError();

    try {
      final response = await _postService.searchPosts(
        query: _searchQuery!,
        type: _selectedFilter,
        page: _currentPage,
      );

      _posts = response.posts;
      _hasNextPage = response.hasNextPage;
      
      notifyListeners();
    } on PostServiceException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to search posts');
    } finally {
      _setLoading(false);
    }
  }

  /// Filter posts by type
  Future<void> filterByType(PostType? type) async {
    if (_selectedFilter == type) return;

    await loadPosts(type: type, refresh: true);
  }

  /// Clear all filters and search
  Future<void> clearFilters() async {
    if (!isFiltered) return;

    _selectedFilter = null;
    _searchQuery = null;
    await loadPosts(refresh: true);
  }

  /// Refresh posts (pull-to-refresh)
  Future<void> refreshPosts() async {
    await loadPosts(type: _selectedFilter, refresh: true);
  }

  /// Get a specific post by ID
  Future<Post?> getPost(String id) async {
    try {
      return await _postService.getPost(id);
    } on PostServiceException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to load post');
      return null;
    }
  }

  /// Add a new post to the list (for real-time updates)
  void addPost(Post post) {
    if (post.status == PostStatus.approved) {
      _posts.insert(0, post);
      notifyListeners();
    }
  }

  /// Update a post in the list
  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      if (updatedPost.status == PostStatus.approved) {
        _posts[index] = updatedPost;
      } else {
        _posts.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Remove a post from the list
  void removePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  /// Create a new post
  Future<Post> createPost(Post post) async {
    try {
      final createdPost = await _postService.createPost(post);
      // Don't add to the list since it needs approval first
      return createdPost;
    } on PostServiceException catch (e) {
      _setError(e.message);
      rethrow;
    } catch (e) {
      _setError('Failed to create post');
      rethrow;
    }
  }

  /// Clear any error messages
  void clearError() {
    _clearError();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set loading more state
  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}