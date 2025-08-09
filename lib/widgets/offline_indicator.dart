import 'package:flutter/material.dart';
import '../services/offline_sync_service.dart';
import '../services/connection_service.dart';
import '../models/cache_metadata.dart';

/// Widget that displays offline status and sync information
class OfflineIndicator extends StatefulWidget {
  final bool showWhenOnline;
  final EdgeInsetsGeometry? margin;

  const OfflineIndicator({super.key, this.showWhenOnline = false, this.margin});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final OfflineSyncService _syncService = OfflineSyncService();
  final ConnectionService _connectionService = ConnectionService();

  bool _isOnline = true;
  bool _isSyncing = false;
  CacheStatistics? _cacheStats;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
    _loadCacheStatistics();
  }

  Future<void> _checkConnectionStatus() async {
    final result = await _connectionService.testConnection();
    if (mounted) {
      setState(() {
        _isOnline = result.isConnected;
        _isSyncing = _syncService.isSyncing;
      });
    }
  }

  Future<void> _loadCacheStatistics() async {
    final stats = await _syncService.getCacheStatistics();
    if (mounted) {
      setState(() {
        _cacheStats = stats;
      });
    }
  }

  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    await _syncService.syncAll();
    await _loadCacheStatistics();
    await _checkConnectionStatus();

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show indicator if online and showWhenOnline is false
    if (_isOnline && !widget.showWhenOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 8),
              Expanded(child: _buildStatusText()),
              if (_isOnline && !_isSyncing) ...[
                const SizedBox(width: 8),
                _buildSyncButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!_isOnline) {
      return Colors.orange.withOpacity(0.1);
    } else if (_isSyncing) {
      return Colors.blue.withOpacity(0.1);
    } else {
      return Colors.green.withOpacity(0.1);
    }
  }

  Widget _buildStatusIcon() {
    if (_isSyncing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    } else if (!_isOnline) {
      return const Icon(Icons.cloud_off, size: 16, color: Colors.orange);
    } else {
      return const Icon(Icons.cloud_done, size: 16, color: Colors.green);
    }
  }

  Widget _buildStatusText() {
    if (_isSyncing) {
      return const Text(
        'Syncing...',
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (!_isOnline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Offline Mode',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_cacheStats != null)
            Text(
              '${_cacheStats!.totalCachedItems} items cached',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Online',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_cacheStats?.newestSyncTime != null)
            Text(
              'Last sync: ${_formatSyncTime(_cacheStats!.newestSyncTime!)}',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
        ],
      );
    }
  }

  Widget _buildSyncButton() {
    return GestureDetector(
      onTap: _performSync,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.refresh, size: 14, color: Colors.blue),
      ),
    );
  }

  String _formatSyncTime(DateTime syncTime) {
    final now = DateTime.now();
    final difference = now.difference(syncTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}

/// Compact version of offline indicator for app bars
class CompactOfflineIndicator extends StatelessWidget {
  const CompactOfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const OfflineIndicator(
      showWhenOnline: false,
      margin: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

/// Full offline status card for settings or debug screens
class OfflineStatusCard extends StatefulWidget {
  const OfflineStatusCard({super.key});

  @override
  State<OfflineStatusCard> createState() => _OfflineStatusCardState();
}

class _OfflineStatusCardState extends State<OfflineStatusCard> {
  final OfflineSyncService _syncService = OfflineSyncService();
  final ConnectionService _connectionService = ConnectionService();

  bool _isLoading = false;
  CacheStatistics? _cacheStats;
  Map<String, CacheMetadata?> _syncStatus = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _syncService.getCacheStatistics();
      final status = await _syncService.getSyncStatus();

      if (mounted) {
        setState(() {
          _cacheStats = stats;
          _syncStatus = status;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cache'),
            content: const Text(
              'Are you sure you want to clear all cached data? This will remove all offline content.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Clear'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _syncService.forceRefreshAll();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage),
                const SizedBox(width: 8),
                const Text(
                  'Offline Storage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _loadData,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_cacheStats != null) ...[
              _buildStatRow('Total Items', '${_cacheStats!.totalCachedItems}'),
              _buildStatRow('Posts', '${_cacheStats!.postsCount}'),
              _buildStatRow(
                'Liturgy Events',
                '${_cacheStats!.liturgyEventsCount}',
              ),
              _buildStatRow('Sermons', '${_cacheStats!.sermonsCount}'),

              const SizedBox(height: 16),
              const Text(
                'Sync Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              ..._syncStatus.entries.map(
                (entry) =>
                    _buildSyncStatusRow(entry.key.toUpperCase(), entry.value),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _syncService.syncAll(),
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _clearCache,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Cache'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSyncStatusRow(String label, CacheMetadata? metadata) {
    Color statusColor;
    String statusText;

    if (metadata == null) {
      statusColor = Colors.grey;
      statusText = 'Not synced';
    } else {
      switch (metadata.syncStatus) {
        case CacheSyncStatus.success:
          statusColor = Colors.green;
          statusText = 'Synced ${_formatTime(metadata.lastSync)}';
          break;
        case CacheSyncStatus.syncing:
          statusColor = Colors.blue;
          statusText = 'Syncing...';
          break;
        case CacheSyncStatus.failed:
          statusColor = Colors.red;
          statusText = 'Failed';
          break;
        case CacheSyncStatus.pending:
          statusColor = Colors.orange;
          statusText = 'Pending';
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
