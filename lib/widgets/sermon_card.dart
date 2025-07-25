import 'package:flutter/material.dart';
import '../models/sermon.dart';
import '../utils/theme.dart';

/// Card widget for displaying sermon previews in lists and grids
class SermonCard extends StatelessWidget {
  final Sermon sermon;
  final VoidCallback? onTap;
  final bool isGridView;

  const SermonCard({
    super.key,
    required this.sermon,
    this.onTap,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(isGridView ? 4 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: isGridView ? _buildGridLayout(context) : _buildListLayout(context),
      ),
    );
  }

  /// Build layout for grid view
  Widget _buildGridLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        Expanded(
          flex: 3,
          child: _buildThumbnail(context),
        ),
        // Content
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  sermon.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Speaker and date
                if (sermon.speaker != null) ...[
                  Text(
                    sermon.speaker!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  sermon.formattedPublishedDate,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Media type and duration
                _buildMediaInfo(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build layout for list view
  Widget _buildListLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          SizedBox(
            width: 120,
            height: 80,
            child: _buildThumbnail(context),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  sermon.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  sermon.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Speaker, date, and media info
                Row(
                  children: [
                    if (sermon.speaker != null) ...[
                      Text(
                        sermon.speaker!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(' • '),
                    ],
                    Text(
                      sermon.formattedPublishedDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    _buildMediaInfo(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build thumbnail widget
  Widget _buildThumbnail(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.secondaryColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: sermon.thumbnailUrl != null
            ? Image.network(
                sermon.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderThumbnail(context);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingThumbnail(context);
                },
              )
            : _buildPlaceholderThumbnail(context),
      ),
    );
  }

  /// Build placeholder thumbnail when no image is available
  Widget _buildPlaceholderThumbnail(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.secondaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            sermon.hasVideo ? Icons.play_circle_outline : Icons.volume_up,
            size: isGridView ? 32 : 24,
            color: AppTheme.primaryColor,
          ),
          if (isGridView) ...[
            const SizedBox(height: 4),
            Text(
              sermon.hasVideo ? 'Video' : 'Audio',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build loading thumbnail
  Widget _buildLoadingThumbnail(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.secondaryColor,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build media info (type and duration)
  Widget _buildMediaInfo(BuildContext context) {
    if (!sermon.hasMedia) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          sermon.hasVideo ? Icons.play_circle_outline : Icons.volume_up,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 4),
        if (sermon.formattedDuration != null)
          Text(
            sermon.formattedDuration!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

/// Compact sermon card for horizontal lists
class CompactSermonCard extends StatelessWidget {
  final Sermon sermon;
  final VoidCallback? onTap;

  const CompactSermonCard({
    super.key,
    required this.sermon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: AppTheme.secondaryColor,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: sermon.thumbnailUrl != null
                        ? Image.network(
                            sermon.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(context);
                            },
                          )
                        : _buildPlaceholder(context),
                  ),
                ),
              ),
              // Content
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sermon.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (sermon.speaker != null)
                        Text(
                          sermon.speaker!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.secondaryColor,
      child: Icon(
        sermon.hasVideo ? Icons.play_circle_outline : Icons.volume_up,
        size: 32,
        color: AppTheme.primaryColor,
      ),
    );
  }
}