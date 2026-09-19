import 'package:flutter/material.dart';
import 'package:leavelist/core/exports/app_exports.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _themes = ['System default', 'Light', 'Dark'];
  static const _languages = ['English', 'हिन्दी', 'বাংলা'];

  String _theme = _themes.first;
  String _language = _languages.first;
  bool _cloudSync = false;

  Future<void> _pickOption({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSizes.xlp),
              child: Text(title, style: AppTypography.titleMedium),
            ),
            for (final option in options)
              ListTile(
                title: Text(option, style: AppTypography.bodyLarge),
                trailing: option == selected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
            SizedBox(height: AppSizes.mp),
          ],
        ),
      ),
    );
    if (result != null) onSelected(result);
  }

  void _showManageStorage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.xlp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage Storage', style: AppTypography.titleMedium),
              SizedBox(height: AppSizes.mp),
              Text(
                'Your addresses and checklists are stored on this device.',
                style: AppTypography.bodyMedium,
              ),
              SizedBox(height: AppSizes.xxlp),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  label: Text(
                    'Clear all data',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error),
                    padding: EdgeInsets.symmetric(vertical: AppSizes.lp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'LeaveList',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 LeaveList',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(AppSizes.xlp),
            children: [
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Change Theme',
                    subtitle: _theme,
                    onTap: () => _pickOption(
                      title: 'Choose theme',
                      options: _themes,
                      selected: _theme,
                      onSelected: (v) => setState(() => _theme = v),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Change Language',
                    subtitle: _language,
                    onTap: () => _pickOption(
                      title: 'Choose language',
                      options: _languages,
                      selected: _language,
                      onSelected: (v) => setState(() => _language = v),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.storage_outlined,
                    title: 'Manage Storage',
                    subtitle: 'Saved addresses and checklists',
                    onTap: _showManageStorage,
                  ),
                  _SettingsTile(
                    icon: Icons.cloud_sync_outlined,
                    title: 'Cloud Sync',
                    subtitle: _cloudSync ? 'On' : 'Off',
                    trailing: Switch(
                      value: _cloudSync,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _cloudSync = v),
                    ),
                    onTap: () => setState(() => _cloudSync = !_cloudSync),
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'Version 1.0.0',
                    onTap: _showAbout,
                  ),
                ],
              ),
            ],
          ),
        ),
        const _SettingsFooter(),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.divider),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.xlp, vertical: AppSizes.lp),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSizes.r12),
              ),
              child: Icon(icon, size: AppSizes.s20, color: AppColors.primary),
            ),
            SizedBox(width: AppSizes.lp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleSmall),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSizes.s2),
                    Text(subtitle!, style: AppTypography.bodySmall),
                  ],
                ],
              ),
            ),
            trailing ?? Icon(AppIcons.navRight, size: AppSizes.s18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SettingsFooter extends StatelessWidget {
  const _SettingsFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xlp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Made with ', style: AppTypography.bodySmall),
              const FlutterLogo(size: 16),
              Text(' Flutter', style: AppTypography.bodySmall),
            ],
          ),
          SizedBox(height: AppSizes.s4),
          Text('LeaveList v1.0.0', style: AppTypography.caption),
        ],
      ),
    );
  }
}
