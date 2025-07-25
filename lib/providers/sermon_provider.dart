import 'package:flutter/foundation.dart';
import '../models/sermon.dart';
import '../services/sermon_service.dart';

/// Provider for managing sermon state and data
class SermonProvider extends ChangeNotifier {
  final SermonService _sermonService = SermonService();

  // State variables
  List<Sermon> _sermons = [];
  List<Sermon> _filteredSermons = [];
  List<String> _availableTags = [];
  List<String> _availableSpeakers = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  // Search and filter state
  String _searchQuery = '';
  List<String> _selectedTags = [];
  String? _selectedSpeaker;
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  List<Sermon> get sermons => _filteredSermons;
  List<String> get availableTags => _availableTags;
  List<String> get availableSpeakers => _availableSpeakers;
  
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  
  String get searchQuery => _searchQuery;
  List<String> get selectedTags => _selectedTags;
  String? get selectedSpeaker => _selectedSpeaker;
  
  bool get hasMoreData => _hasMoreData;
  bool get hasActiveFilters => _searchQuery.isNotEmpty || _selectedTags.isNotEmpty || _selectedSpeaker != null;

  /// Initialize the provider by loading sermons and filter options
  Future<void> initialize() async {
    await Future.wait([
      loadSermons(),
      loadFilterOptions(),
    ]);
  }

  /// Load sermons from the API
  Future<void> loadSermons({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _sermons.clear();
      _filteredSermons.clear();
    }

    if (_isLoading || (!_hasMoreData && !refresh)) return;

    _setLoading(true);
    _setError(null);

    try {
      final newSermons = await _sermonService.getSermons(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
        speaker: _selectedSpeaker,
      );

      if (refresh) {
        _sermons = newSermons;
      } else {
        _sermons.addAll(newSermons);
      }

      _filteredSermons = List.from(_sermons);
      _hasMoreData = newSermons.length >= 20; // Assuming page size is 20
      _currentPage++;

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load more sermons for pagination
  Future<void> loadMoreSermons() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final newSermons = await _sermonService.getSermons(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        tags: _selectedTags.isNotEmpty ? _selectedTags : null,
        speaker: _selectedSpeaker,
      );

      _sermons.addAll(newSermons);
      _filteredSermons = List.from(_sermons);
      _hasMoreData = newSermons.length >= 20;
      _currentPage++;

    } catch (e) {
      _setError(e.toString());
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load filter options (tags and speakers)
  Future<void> loadFilterOptions() async {
    try {
      final results = await Future.wait([
        _sermonService.getSermonTags(),
        _sermonService.getSpeakers(),
      ]);

      _availableTags = results[0];
      _availableSpeakers = results[1];
      notifyListeners();

    } catch (e) {
      // Filter options are not critical, so we don't set error state
      debugPrint('Failed to load filter options: $e');
    }
  }

  /// Search sermons by query
  Future<void> searchSermons(String query) async {
    if (_searchQuery == query) return;

    _searchQuery = query;
    await loadSermons(refresh: true);
  }

  /// Filter sermons by tags
  Future<void> filterByTags(List<String> tags) async {
    if (listEquals(_selectedTags, tags)) return;

    _selectedTags = List.from(tags);
    await loadSermons(refresh: true);
  }

  /// Filter sermons by speaker
  Future<void> filterBySpeaker(String? speaker) async {
    if (_selectedSpeaker == speaker) return;

    _selectedSpeaker = speaker;
    await loadSermons(refresh: true);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    if (!hasActiveFilters) return;

    _searchQuery = '';
    _selectedTags.clear();
    _selectedSpeaker = null;
    await loadSermons(refresh: true);
  }

  /// Get a sermon by ID
  Future<Sermon?> getSermonById(String id) async {
    // First check if we already have it in memory
    try {
      return _sermons.firstWhere((sermon) => sermon.id == id);
    } catch (e) {
      // Not found in memory, fetch from API
      try {
        return await _sermonService.getSermonById(id);
      } catch (e) {
        _setError(e.toString());
        return null;
      }
    }
  }

  /// Get recent sermons
  Future<List<Sermon>> getRecentSermons({int limit = 10}) async {
    try {
      return await _sermonService.getRecentSermons(limit: limit);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadSermons(refresh: true),
      loadFilterOptions(),
    ]);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}