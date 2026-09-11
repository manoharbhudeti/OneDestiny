import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/device_info_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  List<Map<String, dynamic>> _sessions = [];
  DeviceDetails? _currentDevice;
  bool _loading = true;
  bool _revokingAll = false;
  int? _revokingSessionId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final deviceFuture = DeviceInfoService.instance.getDeviceDetails(forceRefresh: forceRefresh);
      final sessionsFuture = AuthService.instance.getSessions();

      final results = await Future.wait([
        deviceFuture,
        sessionsFuture,
      ]);

      if (mounted) {
        final device = results[0] as DeviceDetails;
        final res = results[1] as dynamic;

        setState(() {
          _currentDevice = device;
          if (res.success && res.data != null) {
            _sessions = List<Map<String, dynamic>>.from(res.data);
          } else {
            _errorMessage = res.message.isNotEmpty ? res.message : 'Could not load sessions.';
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load session details: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _revokeSession(int sessionId, String deviceName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Session?'),
        content: Text('Are you sure you want to log out from "$deviceName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _revokingSessionId = sessionId);
    final res = await AuthService.instance.revokeSession(sessionId);

    if (!mounted) return;
    setState(() => _revokingSessionId = null);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session for "$deviceName" revoked.'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message.isNotEmpty ? res.message : 'Failed to revoke session.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _revokeAllOthers() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out All Other Devices?'),
        content: const Text(
          'This will terminate all active login sessions on every device except this one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out Others'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _revokingAll = true);
    final res = await AuthService.instance.revokeAllSessions();

    if (!mounted) return;
    setState(() => _revokingAll = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All other active sessions have been logged out.'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message.isNotEmpty ? res.message : 'Failed to revoke other sessions.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  IconData _getDeviceIcon(String? os, String? name) {
    final combined = '${os ?? ''} ${name ?? ''}'.toLowerCase();
    if (combined.contains('ios') || combined.contains('iphone')) {
      return Icons.phone_iphone_rounded;
    } else if (combined.contains('ipad') || combined.contains('tablet')) {
      return Icons.tablet_mac_rounded;
    } else if (combined.contains('mac') || combined.contains('windows') || combined.contains('linux')) {
      return Icons.laptop_chromebook_rounded;
    } else if (combined.contains('web')) {
      return Icons.language_rounded;
    }
    return Icons.smartphone_rounded;
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'Recently';
    try {
      final date = DateTime.parse(dateStr.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final otherSessionsCount = _sessions.where((s) => s['isCurrent'] != true).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Active Sessions & Devices', style: AppTypography.heading(context)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => _loadData(forceRefresh: true),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(forceRefresh: true),
          color: AppColors.accentGold,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accentGold),
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Section 1: This Device Live Status Banner
                    Text(
                      'CURRENT DEVICE',
                      style: AppTypography.caption(context).copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: AppColors.accentGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getDeviceIcon(_currentDevice?.deviceOs, _currentDevice?.deviceName),
                                  color: AppColors.accentGold,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentDevice?.deviceName ?? 'This Device',
                                      style: AppTypography.subtitle(context).copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentDevice?.deviceOs ?? 'Mobile OS',
                                      style: AppTypography.description(context, isSecondary: true).copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Active Now',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(height: 1, color: borderColor),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.wifi_rounded, size: 16, color: AppColors.accentGold),
                              const SizedBox(width: 8),
                              Text(
                                'IP Address:',
                                style: AppTypography.caption(context).copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _currentDevice?.ipAddress ?? 'Resolving IP...',
                                  style: AppTypography.caption(context).copyWith(
                                    fontFamily: 'monospace',
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Section 2: All Active Sessions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LOGGED IN SESSIONS (${_sessions.length})',
                          style: AppTypography.caption(context).copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        if (otherSessionsCount > 0)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: _revokingAll
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                                  )
                                : const Icon(Icons.logout_rounded, size: 16),
                            label: const Text('Log Out All Others', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: _revokingAll ? null : _revokeAllOthers,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_errorMessage != null && _sessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _loadData(forceRefresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (_sessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text(
                            'No active session records found.',
                            style: AppTypography.description(context, isSecondary: true),
                          ),
                        ),
                      )
                    else
                      ..._sessions.map((s) {
                        final isCurrent = s['isCurrent'] == true;
                        final sessionId = s['id'] as int? ?? 0;
                        final deviceName = s['deviceName']?.toString() ?? 'Unknown Device';
                        final deviceOs = s['deviceOs']?.toString() ?? 'Mobile';
                        final ipAddress = s['ipAddress']?.toString();
                        final lastSeenAt = s['lastSeenAt'];
                        final isRevokingThis = _revokingSessionId == sessionId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrent ? AppColors.accentGold.withValues(alpha: 0.4) : borderColor,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.accentGold.withValues(alpha: 0.15)
                                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getDeviceIcon(deviceOs, deviceName),
                                  color: isCurrent ? AppColors.accentGold : (isDark ? Colors.white70 : Colors.black54),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            deviceName,
                                            style: AppTypography.subtitle(context).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        if (isCurrent)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentGold.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Current',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.accentGold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      deviceOs,
                                      style: AppTypography.description(context, isSecondary: true).copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.wifi_rounded,
                                          size: 13,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          ipAddress != null && ipAddress.isNotEmpty ? ipAddress : 'IP unavailable',
                                          style: AppTypography.caption(context).copyWith(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 13,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(lastSeenAt),
                                          style: AppTypography.caption(context).copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isCurrent)
                                IconButton(
                                  icon: isRevokingThis
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                                        )
                                      : const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                  tooltip: 'Revoke session',
                                  onPressed: isRevokingThis ? null : () => _revokeSession(sessionId, deviceName),
                                ),
                            ],
                          ),
                        );
                      }),

                    if (otherSessionsCount > 0) ...[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _revokingAll
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: Text(_revokingAll ? 'Logging out...' : 'Log Out All Other Devices'),
                        onPressed: _revokingAll ? null : _revokeAllOthers,
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
        ),
      ),
    );
  }
}
