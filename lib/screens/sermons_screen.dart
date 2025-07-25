import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sermon.dart';
import '../providers/sermon_provider.dart';
import '../widgets/sermon_card.dart';
import '../screens/sermon_detail_screen.dart';
import '../utils/theme.dart';

/// Sermons screen for displaying sermon content with search and filter functionality
class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initialize sermon provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SermonProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SermonProvider>().loadMoreSermons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SermonProvider>(
      builder: (context, sermonProvider, child) {
        return Column(
          children: [
            // Search and filter section
            _buildSearchAndFilters(context, sermonProvider),
            
            // Content area
            Expanded(
              child: _buildContent(context, sermonProvider),
            ),
          ],
        );
      },
    );
  }

  /// Build search and filter section
  Widget _buildSearchAndFilters(BuildContext context, SermonProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar and view toggle
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search sermons...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.searchSermons('');
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onSubmitted: (query) {
                    provider.searchSermons(query);
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                tooltip: _isGridView ? 'List View' : 'Grid View',
              ),
              IconButton(
                onPressed: () => _showFilterDialog(context, provider),
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_list),
                    if (provider.hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Filter',
              ),
            ],
          ),
          
          // Active filters
          if (provider.hasActiveFilters) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(context, provider),
          ],
        ],
      ),
    );
  }

  /// Build active filters display
  Widget _buildActiveFilters(BuildContext context, SermonProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Search query chip
        if (provider.searchQuery.isNotEmpty)
          Chip(
            label: Text('Search: ${provider.searchQuery}'),
            onDeleted: () => provider.searchSermons(''),
            deleteIcon: const Icon(Icons.close, size: 16),
          ),
        
        // Selected tags chips
        ...provider.selectedTags.map((tag) => Chip(
          label: Text('Tag: $tag'),
          onDeleted: () {
            final newTags = List<String>.from(provider.selectedTags)..remove(tag);
            provider.filterByTags(newTags);
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        )),
        
        // Selected speaker chip
        if (provider.selectedSpeaker != null)
          Chip(
            label: Text('Speaker: ${provider.selectedSpeaker}'),
            onDeleted: () => provider.filterBySpeaker(null),
            deleteIcon: const Icon(Icons.close, size: 16),
          ),
        
        // Clear all filters
        TextButton.icon(
          onPressed: provider.clearFilters,
          icon: const Icon(Icons.clear_all, size: 16),
          label: const Text('Clear All'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  /// Build main content area
  Widget _buildContent(BuildContext context, SermonProvider provider) {
    if (provider.isLoading && provider.sermons.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.sermons.isEmpty) {
      return _buildErrorState(context, provider);
    }

    if (provider.sermons.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: _isGridView 
          ? _buildGridView(context, provider)
          : _buildListView(context, provider),
    );
  }

  /// Build grid view
  Widget _buildGridView(BuildContext context, SermonProvider provider) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: provider.sermons.length + (provider.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.sermons.length) {
          return const Card(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final sermon = provider.sermons[index];
        return SermonCard(
          sermon: sermon,
          isGridView: true,
          onTap: () => _navigateToSermonDetail(context, sermon),
        );
      },
    );
  }

  /// Build list view
  Widget _buildListView(BuildContext context, SermonProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.sermons.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= provider.sermons.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final sermon = provider.sermons[index];
        return SermonCard(
          sermon: sermon,
          isGridView: false,
          onTap: () => _navigateToSermonDetail(context, sermon),
        );
      },
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, SermonProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load sermons',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No sermons found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show filter dialog
  void _showFilterDialog(BuildContext context, SermonProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(provider: provider),
    );
  }

  /// Navigate to sermon detail screen
  void _navigateToSermonDetail(BuildContext context, Sermon sermon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SermonDetailScreen(sermon: sermon),
      ),
    );
  }
}

/// Filter dialog for advanced filtering options
class _FilterDialog extends StatefulWidget {
  final SermonProvider provider;

  const _FilterDialog({required this.provider});

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late List<String> _selectedTags;
  String? _selectedSpeaker;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.provider.selectedTags);
    _selectedSpeaker = widget.provider.selectedSpeaker;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Sermons'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker filter
            Text(
              'Speaker',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSpeaker,
              decoration: const InputDecoration(
                hintText: 'Select speaker',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All speakers'),
                ),
                ...widget.provider.availableSpeakers.map((speaker) =>
                  DropdownMenuItem<String>(
                    value: speaker,
                    child: Text(speaker),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSpeaker = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Tags filter
            Text(
              'Topics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (widget.provider.availableTags.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView(
                  children: widget.provider.availableTags.map((tag) {
                    return CheckboxListTile(
                      title: Text(tag),
                      value: _selectedTags.contains(tag),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              )
            else
              const Text('No topics available'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedTags.clear();
              _selectedSpeaker = null;
            });
          },
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.provider.filterByTags(_selectedTags);
            widget.provider.filterBySpeaker(_selectedSpeaker);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}