import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../widgets/community_card.dart';

/// Community screen for displaying posts and community content
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more posts when near the bottom
      context.read<PostProvider>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                return _buildPostsList(postProvider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to new post screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New post creation will be implemented in the next task'),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All',
                        isSelected: postProvider.selectedFilter == null,
                        onTap: () => postProvider.filterByType(null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Announcements',
                        isSelected: postProvider.selectedFilter == PostType.announcement,
                        onTap: () => postProvider.filterByType(PostType.announcement),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Events',
                        isSelected: postProvider.selectedFilter == PostType.event,
                        onTap: () => postProvider.filterByType(PostType.event),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Prayer Requests',
                        isSelected: postProvider.selectedFilter == PostType.prayerRequest,
                        onTap: () => postProvider.filterByType(PostType.prayerRequest),
                      ),
                    ],
                  ),
                ),
              ),
              if (postProvider.isFiltered) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => postProvider.clearFilters(),
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList(PostProvider postProvider) {
    if (postProvider.isLoading && postProvider.posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (postProvider.errorMessage != null && postProvider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              postProvider.errorMessage!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => postProvider.refreshPosts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (postProvider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              postProvider.isFiltered 
                  ? 'No posts found for the selected filter'
                  : 'No posts available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (postProvider.isFiltered) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => postProvider.clearFilters(),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => postProvider.refreshPosts(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: postProvider.posts.length + 
            (postProvider.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == postProvider.posts.length) {
            // Loading indicator for pagination
            return Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: postProvider.isLoadingMore
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            );
          }

          final post = postProvider.posts[index];
          return CommunityCard(post: post);
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Posts'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search terms...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.of(context).pop();
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSearch(_searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<PostProvider>().searchPosts(query.trim());
    }
  }
}