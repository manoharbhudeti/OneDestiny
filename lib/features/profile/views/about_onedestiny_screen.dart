import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/app_version_info.dart';
import '../../../core/services/app_version_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AboutOneDestinyScreen extends StatefulWidget {
  final AppVersionService? versionService;

  const AboutOneDestinyScreen({
    super.key,
    this.versionService,
  });

  @override
  State<AboutOneDestinyScreen> createState() => _AboutOneDestinyScreenState();
}

class _AboutOneDestinyScreenState extends State<AboutOneDestinyScreen> {
  late final AppVersionService _service;
  late Future<AppVersionInfo> _versionFuture;

  @override
  void initState() {
    super.initState();
    _service = widget.versionService ?? AppVersionService();
    _loadVersionInfo();
  }

  void _loadVersionInfo() {
    setState(() {
      _versionFuture = _service.loadVersionInfo();
    });
  }

  Future<void> _openDeveloperUrl(String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link: $urlString'),
          backgroundColor: AppColors.darkPrimaryBurgundy,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('About OneDestiny', style: AppTypography.heading(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<AppVersionInfo>(
        future: _versionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(context);
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState(context);
          }

          final info = snapshot.data!;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Logo & Brand Header
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentGold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/one_destiny_logo_transparent.png',
                        height: 56,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/one_destiny_logo.png',
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'OneDestiny',
                      style: AppTypography.heading(context).copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Luxury Event & Wedding Marketplace',
                      style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    // Version Tag Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        info.version,
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Application Information Section
              Text(
                'Application Information',
                style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      context,
                      label: 'Version',
                      value: info.version,
                      icon: Icons.numbers_rounded,
                      borderColor: borderColor,
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildInfoTile(
                      context,
                      label: 'Build',
                      value: '${info.build}',
                      icon: Icons.build_circle_outlined,
                      borderColor: borderColor,
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildInfoTile(
                      context,
                      label: 'Released on',
                      value: info.formattedReleaseDate,
                      icon: Icons.calendar_today_rounded,
                      borderColor: borderColor,
                    ),
                    Divider(height: 1, color: borderColor),
                    _buildInfoTile(
                      context,
                      label: 'Developed By',
                      value: info.developedBy,
                      icon: Icons.code_rounded,
                      borderColor: borderColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Developers & Credits Card
              Row(
                children: [
                  const Icon(Icons.people_alt_rounded, color: AppColors.accentGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Development Team',
                    style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: info.developers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dev = entry.value;
                    return Column(
                      children: [
                        if (index > 0) Divider(height: 20, color: borderColor),
                        InkWell(
                          onTap: dev.hasLink ? () => _openDeveloperUrl(dev.url) : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryBurgundy,
                                  radius: 20,
                                  child: Text(
                                    dev.name.isNotEmpty ? dev.name[0].toUpperCase() : 'D',
                                    style: const TextStyle(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dev.name,
                                        style: AppTypography.subtitle(context).copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (dev.role != null)
                                        Text(
                                          dev.role!,
                                          style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                                if (dev.hasLink)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A66C2).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFF0A66C2).withValues(alpha: 0.4)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.link_rounded, size: 14, color: Color(0xFF0A66C2)),
                                        SizedBox(width: 4),
                                        Text(
                                          'LinkedIn',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0A66C2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Update Status Management Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Up to Date',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'You are running the latest version of OneDestiny.',
                            style: AppTypography.description(context).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // What's New Section (Release Notes)
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.accentGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'What\'s New',
                    style: AppTypography.subtitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${info.version} • Released on ${info.formattedReleaseDate}',
                style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: info.releaseNotes.isEmpty
                    ? Text(
                        'No release notes available for this version.',
                        style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 13),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: info.releaseNotes.map((note) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: AppTypography.description(context).copyWith(fontSize: 13.5, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 36),

              // Bottom Footer Note
              Center(
                child: Text(
                  '© 2026 OneDestiny Inc. All rights reserved.',
                  style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accentGold),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            value,
            style: AppTypography.subtitle(context).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: label == 'Version' ? AppColors.accentGold : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accentGold),
          const SizedBox(height: 16),
          Text('Loading...', style: AppTypography.description(context, isSecondary: true)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Unable to load application information.',
              style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Please try again.',
              style: AppTypography.description(context, isSecondary: true),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadVersionInfo,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
