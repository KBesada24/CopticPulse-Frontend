import 'package:flutter/material.dart';
import '../services/connection_service.dart';
import '../config/environment.dart';

/// Widget for displaying backend connection status and testing connectivity
class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({super.key});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  final ConnectionService _connectionService = ConnectionService();
  ConnectionResult? _lastResult;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    if (_isTestingConnection) return;
    
    setState(() {
      _isTestingConnection = true;
    });

    try {
      final result = await _connectionService.testConnection();
      setState(() {
        _lastResult = result;
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
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
                const Icon(Icons.cloud, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Backend Connection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isTestingConnection ? null : _testConnection,
                  icon: _isTestingConnection
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
            
            // Backend URL
            _buildInfoRow(
              'Backend URL',
              EnvironmentConfig.apiBaseUrl,
              Icons.link,
            ),
            
            // Environment
            _buildInfoRow(
              'Environment',
              EnvironmentConfig.currentEnvironment.name.toUpperCase(),
              Icons.settings,
            ),
            
            // Connection Status
            if (_lastResult != null) ...[
              const SizedBox(height: 8),
              _buildConnectionStatus(_lastResult!),
            ],
            
            // Server Info
            if (_lastResult?.serverInfo != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Server Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildServerInfo(_lastResult!.serverInfo!),
            ],
            
            const SizedBox(height: 16),
            
            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTestingConnection ? null : _testConnection,
                icon: _isTestingConnection
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find),
                label: Text(_isTestingConnection ? 'Testing...' : 'Test Connection'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(ConnectionResult result) {
    Color statusColor;
    IconData statusIcon;
    
    if (result.isConnected) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.isConnected ? 'Connected' : 'Connection Failed',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  result.message,
                  style: TextStyle(
                    color: statusColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerInfo(ServerInfo serverInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          if (serverInfo.version != null)
            _buildInfoRow('Version', serverInfo.version!, Icons.info),
          if (serverInfo.environment != null)
            _buildInfoRow('Server Environment', serverInfo.environment!, Icons.computer),
          if (serverInfo.database != null)
            _buildInfoRow('Database', serverInfo.database!, Icons.storage),
          if (serverInfo.timestamp != null)
            _buildInfoRow(
              'Server Time',
              _formatDateTime(serverInfo.timestamp!),
              Icons.access_time,
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}