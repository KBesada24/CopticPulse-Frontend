import 'package:flutter/material.dart';
import '../models/liturgy_event.dart';

/// Widget for displaying liturgy event information in a card format
class LiturgyEventCard extends StatelessWidget {
  final LiturgyEvent event;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compact;

  const LiturgyEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showDate = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 8.0 : 16.0,
        vertical: compact ? 4.0 : 8.0,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12.0 : 16.0),
          child: compact ? _buildCompactContent(context) : _buildFullContent(context),
        ),
      ),
    );
  }

  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event type icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEventColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(),
                color: _getEventColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.serviceType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getEventColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (event.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Status indicator
            if (event.isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'TODAY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (event.isUpcoming)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'UPCOMING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Date, time, and location info
        Row(
          children: [
            if (showDate) ...[
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                event.formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
            ],
            Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              event.formattedTime,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (event.formattedDuration != null) ...[
              const SizedBox(width: 4),
              Text(
                '(${event.formattedDuration})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                event.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Row(
      children: [
        // Event type icon
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getEventColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getEventIcon(),
            color: _getEventColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // Event details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${event.formattedTime} • ${event.location}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Status indicator
        if (event.isToday)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          )
        else if (event.isUpcoming)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  /// Get the appropriate icon for the event type
  IconData _getEventIcon() {
    final serviceType = event.serviceType.toLowerCase();
    if (serviceType.contains('liturgy') || serviceType.contains('mass')) {
      return Icons.church;
    } else if (serviceType.contains('prayer') || serviceType.contains('vespers')) {
      return Icons.favorite;
    } else if (serviceType.contains('baptism')) {
      return Icons.water_drop;
    } else if (serviceType.contains('wedding')) {
      return Icons.favorite_border;
    } else if (serviceType.contains('funeral')) {
      return Icons.local_florist;
    } else {
      return Icons.event;
    }
  }

  /// Get the appropriate color for the event type
  Color _getEventColor() {
    final serviceType = event.serviceType.toLowerCase();
    if (serviceType.contains('liturgy') || serviceType.contains('mass')) {
      return const Color(0xFF8B0000); // Burgundy for main liturgy
    } else if (serviceType.contains('prayer') || serviceType.contains('vespers')) {
      return Colors.purple;
    } else if (serviceType.contains('baptism')) {
      return Colors.blue;
    } else if (serviceType.contains('wedding')) {
      return Colors.pink;
    } else if (serviceType.contains('funeral')) {
      return Colors.grey;
    } else {
      return Colors.brown;
    }
  }
}

/// Widget for displaying a list of liturgy events for a specific date
class LiturgyEventsList extends StatelessWidget {
  final List<LiturgyEvent> events;
  final bool compact;
  final String? emptyMessage;

  const LiturgyEventsList({
    super.key,
    required this.events,
    this.compact = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage ?? 'No liturgy events scheduled',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return LiturgyEventCard(
          event: event,
          compact: compact,
          onTap: () => _showEventDetails(context, event),
        );
      },
    );
  }

  /// Show event details in a modal bottom sheet
  void _showEventDetails(BuildContext context, LiturgyEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LiturgyEventDetailsModal(event: event),
    );
  }
}

/// Modal widget for displaying detailed liturgy event information
class LiturgyEventDetailsModal extends StatelessWidget {
  final LiturgyEvent event;

  const LiturgyEventDetailsModal({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Event title and type
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.church,
                      color: const Color(0xFF8B0000),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.serviceType,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF8B0000),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Event details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        context,
                        Icons.calendar_today,
                        'Date',
                        event.formattedDate,
                      ),
                      _buildDetailRow(
                        context,
                        Icons.access_time,
                        'Time',
                        event.formattedTime + 
                        (event.formattedDuration != null ? ' (${event.formattedDuration})' : ''),
                      ),
                      _buildDetailRow(
                        context,
                        Icons.location_on,
                        'Location',
                        event.location,
                      ),
                      if (event.description != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}