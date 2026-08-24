import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HelpPoliciesScreen extends StatefulWidget {
  const HelpPoliciesScreen({super.key});

  @override
  State<HelpPoliciesScreen> createState() => _HelpPoliciesScreenState();
}

class _HelpPoliciesScreenState extends State<HelpPoliciesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final bool _isLoading = false;
  bool _hasError = false;

  static const String _phoneNumber = '6302594826';
  static const String _formattedPhone = '+91 63025 94826';
  static const String _supportEmail = 'onedestiny50@gmail.com';

  Future<void> _makePhoneCall() async {
    final Uri url = Uri.parse('tel:$_phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showToast('Could not launch phone dialer for $_formattedPhone');
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/91$_phoneNumber?text=Hello%20OneDestiny%20Support!%20I%20need%20assistance.');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showToast('Could not open WhatsApp for $_formattedPhone');
    }
  }

  Future<void> _sendEmail() async {
    final Uri url = Uri.parse('mailto:$_supportEmail?subject=OneDestiny%20Support%20Inquiry');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showToast('Could not open mail app for $_supportEmail');
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkPrimaryBurgundy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Help & Policies', style: AppTypography.heading(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          physics: const BouncingScrollPhysics(),
          indicatorColor: AppColors.accentGold,
          indicatorWeight: 3,
          labelColor: isDark ? AppColors.accentGold : primaryColor,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'FAQs & Support'),
            Tab(text: 'Cancellation Policy'),
            Tab(text: 'Dispute Handling'),
            Tab(text: 'Terms & Privacy'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState(context)
          : _hasError
              ? _buildErrorState(context)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFaqsAndSupportTab(context),
                    _buildCancellationPolicyTab(context),
                    _buildDisputeHandlingTab(context),
                    _buildTermsAndPrivacyTab(context),
                  ],
                ),
    );
  }

  // TAB 1: FAQs & Contact Support
  Widget _buildFaqsAndSupportTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final appState = AppStateScope.of(context);
    final faqs = appState.faqs;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        // CRITICAL SAFETY & FINANCIAL DISCLAIMER BANNER
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4), width: 1.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Important Payment & Safety Advisory',
                      style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• DO NOT pay any advance payment upfront without direct vendor booking confirmation.\n'
                '• OneDestiny is a bridge platform connecting customers & vendors. OneDestiny does NOT process or handle financial transactions directly and does NOT issue direct refunds.\n'
                '• All payments, deposits, and refunds are managed directly between you and the vendor according to the vendor\'s policy terms.',
                style: AppTypography.description(context).copyWith(fontSize: 12.5, height: 1.45),
              ),
            ],
          ),
        ),

        // Concierge Contact Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
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
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.headset_mic_rounded, color: AppColors.accentGold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Event Concierge',
                          style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Direct support line for urgent event needs',
                          style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openWhatsApp,
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('WhatsApp Chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentGold,
                        side: const BorderSide(color: AppColors.accentGold),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _makePhoneCall,
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                      label: const Text('Call Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBurgundy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: borderColor),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryBurgundy,
                  radius: 18,
                  child: Icon(Icons.phone_rounded, color: AppColors.accentGold, size: 18),
                ),
                title: const Text('Call Us Directly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text(_formattedPhone, style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.accentGold),
                onTap: _makePhoneCall,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF25D366),
                  radius: 18,
                  child: Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                ),
                title: const Text('WhatsApp Support Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Chat with concierge on WhatsApp ($_formattedPhone)', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.accentGold),
                onTap: _openWhatsApp,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryBurgundy,
                  radius: 18,
                  child: Icon(Icons.email_rounded, color: AppColors.accentGold, size: 18),
                ),
                title: const Text('Email Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text(_supportEmail, style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.accentGold),
                onTap: _sendEmail,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text('Frequently Asked Questions', style: AppTypography.subtitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        if (faqs.isEmpty)
          _buildEmptyState(context)
        else
          ...faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: ExpansionTile(
                title: Text(
                  faq.question,
                  style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                leading: const Icon(Icons.help_outline_rounded, color: AppColors.accentGold, size: 20),
                iconColor: AppColors.accentGold,
                collapsedIconColor: isDark ? Colors.white60 : Colors.black54,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    faq.answer,
                    style: AppTypography.description(context).copyWith(fontSize: 13, height: 1.45),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // TAB 2: Cancellation & Refund Policy
  Widget _buildCancellationPolicyTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final appState = AppStateScope.of(context);
    final tiers = appState.cancellationTiers;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.accentGold, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Vendor Refund & Cancellation Policy',
                    style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Platform Intermediary Notice:\n'
                'OneDestiny connects customers with event vendors but does NOT directly collect, process, hold, or refund payments. All refund claims and advance deposit returns are handled directly between the customer and vendor according to agreed vendor terms.',
                style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Text('Refund Tiers', style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...tiers.map((tier) {
          final isFullRefund = tier.refundPercentage.contains('100%');
          final isPartial = tier.refundPercentage.contains('50%');
          final badgeColor = isFullRefund ? AppColors.success : (isPartial ? AppColors.warning : AppColors.error);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.timeframe,
                        style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tier.description,
                        style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    tier.refundPercentage,
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // TAB 3: Dispute Handling
  Widget _buildDisputeHandlingTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final appState = AppStateScope.of(context);
    final policySections = appState.policySections;
    final disputeSection = policySections.firstWhere(
      (s) => s.title.contains('Dispute'),
      orElse: () => policySections.first,
    );

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppColors.accentGold, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    disputeSection.title,
                    style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                disputeSection.content,
                style: AppTypography.description(context).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...disputeSection.bulletPoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.accentGold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: AppTypography.description(context).copyWith(fontSize: 12.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Dispute Ticket Submission Form...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.report_problem_outlined, size: 18),
            label: const Text('File a Dispute Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 4: Terms & Privacy
  Widget _buildTermsAndPrivacyTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final appState = AppStateScope.of(context);
    final policySections = appState.policySections.where((s) => !s.title.contains('Dispute')).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        ...policySections.map((section) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  section.content,
                  style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                ...section.bulletPoints.map((point) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded, color: AppColors.accentGold, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            point,
                            style: AppTypography.description(context).copyWith(fontSize: 12.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text('No FAQs Available', style: AppTypography.subtitle(context)),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accentGold),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Failed to load help details', style: AppTypography.subtitle(context)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _hasError = false),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
