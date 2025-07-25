import 'package:flutter/material.dart';
import '../models/sermon.dart';
import '../utils/theme.dart';

/// Screen for viewing detailed sermon content
class SermonDetailScreen extends StatelessWidget {
  final Sermon sermon;

  const SermonDetailScreen({
    super.key,
    required this.sermon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sermon'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.onPrimaryTextColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Media section
            _buildMediaSection(context),
            const SizedBox(height: 24),
            
            // Title
            Text(
              sermon.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Metadata (speaker, date, duration)
            _buildMetadataSection(context),
            const SizedBox(height: 24),
            
            // Tags
            if (sermon.tags.isNotEmpty) ...[
              _buildTagsSection(context),
              const SizedBox(height: 24),
            ],
            
            // Description
            _buildDescriptionSection(context),
            const SizedBox(height: 32),
            
            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Build media section with thumbnail and play button
  Widget _buildMediaSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.secondaryColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Thumbnail or placeholder
            if (sermon.thumbnailUrl != null)
              Image.network(
                sermon.thumbnailUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildMediaPlaceholder(context);
                },
              )
            else
              _buildMediaPlaceholder(context),
            
            // Play button overlay
            if (sermon.hasMedia)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _playMedia(context),
                        icon: Icon(
                          sermon.hasVideo ? Icons.play_arrow : Icons.volume_up,
                          color: AppTheme.onPrimaryTextColor,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build media placeholder when no thumbnail is available
  Widget _buildMediaPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.secondaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            sermon.hasVideo ? Icons.play_circle_outline : Icons.volume_up,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            sermon.hasVideo ? 'Video Sermon' : 'Audio Sermon',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build metadata section with speaker, date, and duration
  Widget _buildMetadataSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (sermon.speaker != null)
            _buildMetadataRow(
              context,
              icon: Icons.person,
              label: 'Speaker',
              value: sermon.speaker!,
            ),
          if (sermon.speaker != null) const SizedBox(height: 12),
          
          _buildMetadataRow(
            context,
            icon: Icons.calendar_today,
            label: 'Published',
            value: sermon.formattedPublishedDate,
          ),
          
          if (sermon.formattedDuration != null) ...[
            const SizedBox(height: 12),
            _buildMetadataRow(
              context,
              icon: Icons.access_time,
              label: 'Duration',
              value: sermon.formattedDuration!,
            ),
          ],
        ],
      ),
    );
  }

  /// Build a metadata row with icon, label, and value
  Widget _buildMetadataRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Build tags section
  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sermon.tags.map((tag) {
            return Chip(
              label: Text(
                tag,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: AppTheme.primaryColor,
              ),
              side: BorderSide(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build description section
  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.dividerColor,
            ),
          ),
          child: Text(
            sermon.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: AppTheme.primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (sermon.hasMedia)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _playMedia(context),
              icon: Icon(
                sermon.hasVideo ? Icons.play_arrow : Icons.volume_up,
              ),
              label: Text(
                sermon.hasVideo ? 'Watch Sermon' : 'Listen to Sermon',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareSermon(context),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _downloadSermon(context),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Handle media playback
  void _playMedia(BuildContext context) {
    if (!sermon.hasMedia) return;

    // TODO: Implement media player
    // For now, show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media Player'),
        content: Text(
          'Media player will be implemented in a future update.\n\n'
          'Media URL: ${sermon.primaryMediaUrl}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle sermon sharing
  void _shareSermon(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality will be implemented soon'),
      ),
    );
  }

  /// Handle sermon download
  void _downloadSermon(BuildContext context) {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality will be implemented soon'),
      ),
    );
  }
}