import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum PermissionType { location, photos, notification }

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _locationGranted = false;
  bool _photosGranted = false;
  bool _notificationGranted = false;
  bool _isLoading = false;
  String? _packageName;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadPackageName();
  }

  Future<void> _loadPackageName() async {
    if (kIsWeb) {
      return;
    }
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    _packageName = info.packageName;
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final photosStatus = await Permission.photos.status;
    final notificationStatus = await Permission.notification.status;

    setState(() {
      _locationGranted = locationStatus.isGranted;
      _photosGranted = photosStatus.isGranted;
      _notificationGranted = notificationStatus.isGranted;
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _locationGranted = status.isGranted;
    });

    if (status.isPermanentlyDenied || status.isRestricted) {
      _showSettingsDialog(PermissionType.location);
    }
  }

  Future<void> _requestPhotosPermission() async {
    final status = await Permission.photos.request();
    setState(() {
      _photosGranted = status.isGranted;
    });

    if (status.isLimited) {
      _showSettingsDialog(PermissionType.photos, isLimited: true);
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      _showSettingsDialog(PermissionType.photos);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationGranted = status.isGranted;
    });

    if (status.isPermanentlyDenied || status.isRestricted) {
      _showSettingsDialog(PermissionType.notification);
    }
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  String _permissionTitle(PermissionType type) {
    switch (type) {
      case PermissionType.location:
        return '위치';
      case PermissionType.photos:
        return '사진';
      case PermissionType.notification:
        return '알림';
    }
  }

  String _settingsPath(PermissionType type) {
    if (_isIOS) {
      switch (type) {
        case PermissionType.location:
          return '설정 > 앱 > 위치 > "앱 사용 중/항상"';
        case PermissionType.photos:
          return '설정 > 앱 > 사진 > "모든 사진"';
        case PermissionType.notification:
          return '설정 > 앱 > 알림 > "알림 허용"';
      }
    }

    if (_isAndroid) {
      switch (type) {
        case PermissionType.location:
          return '설정 > 앱 > 권한 > 위치 > 허용';
        case PermissionType.photos:
          return '설정 > 앱 > 권한 > 사진 및 동영상 > 허용';
        case PermissionType.notification:
          return '설정 > 앱 > 알림 > 허용';
      }
    }

    return '설정에서 권한을 허용해주세요.';
  }

  AndroidIntent? _buildAndroidIntent(PermissionType type) {
    if (!_isAndroid || _packageName == null) {
      return null;
    }

    switch (type) {
      case PermissionType.notification:
        return AndroidIntent(
          action: 'android.settings.APP_NOTIFICATION_SETTINGS',
          arguments: <String, dynamic>{
            'android.provider.extra.APP_PACKAGE': _packageName,
          },
        );
      case PermissionType.location:
      case PermissionType.photos:
        return AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:$_packageName',
        );
    }
  }

  Future<void> _openSettings(PermissionType type) async {
    if (_isAndroid) {
      final intent = _buildAndroidIntent(type);
      if (intent != null) {
        try {
          await intent.launch();
          return;
        } catch (_) {}
      }
    }
    await openAppSettings();
  }

  void _showSettingsDialog(PermissionType type, {bool isLimited = false}) {
    final l10n = AppLocalizations.of(context)!;
    final permissionTitle = _permissionTitle(type);
    final guide = _settingsPath(type);
    final message = isLimited
        ? '현재 제한된 접근 상태입니다.\n전체 허용으로 변경해주세요.\n\n설정 경로:\n$guide'
        : '앱 기능 사용을 위해 권한이 필요합니다.\n\n설정 경로:\n$guide';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('$permissionTitle 권한 필요'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openSettings(type);
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
    });

    // Request all permissions
    await _requestLocationPermission();
    await _requestPhotosPermission();
    await _requestNotificationPermission();

    setState(() {
      _isLoading = false;
    });

    // Check if all permissions are granted
    if (_locationGranted && _photosGranted && _notificationGranted) {
      if (mounted) {
        // Navigate to next screen (profile creation or main)
        context.go('/profile/create');
      }
    }
  }

  bool get _allPermissionsGranted =>
      _locationGranted && _photosGranted && _notificationGranted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                '앱 사용을 위해\n권한이 필요해요',
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '원활한 서비스 이용을 위해 아래 권한을 허용해주세요',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 48),

              // Permission Items
              Expanded(
                child: ListView(
                  children: [
                    _buildPermissionItem(
                      icon: Icons.location_on_rounded,
                      iconColor: AppColors.primary,
                      title: '위치',
                      description: '주변 매칭 상대를 찾기 위해 필요해요',
                      isGranted: _locationGranted,
                      onTap: _requestLocationPermission,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionItem(
                      icon: Icons.photo_library_rounded,
                      iconColor: AppColors.accent,
                      title: '사진',
                      description: '프로필 사진 등록을 위해 필요해요',
                      isGranted: _photosGranted,
                      onTap: _requestPhotosPermission,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionItem(
                      icon: Icons.notifications_rounded,
                      iconColor: AppColors.secondary,
                      title: '알림',
                      description: '새로운 매칭과 메시지 알림을 위해 필요해요',
                      isGranted: _notificationGranted,
                      onTap: _requestNotificationPermission,
                    ),
                    const SizedBox(height: 32),

                    // Battery optimization note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '원활한 매칭을 위해 배터리 최적화를 해제해주세요',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Continue Button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _allPermissionsGranted
                        ? AppColors.primaryGradient
                        : null,
                    color: _allPermissionsGranted
                        ? null
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _allPermissionsGranted
                          ? () => context.go('/profile/create')
                          : _isLoading
                              ? null
                              : _requestAllPermissions,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _allPermissionsGranted ? '시작하기' : '권한 허용하기',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isGranted
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted ? AppColors.success : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isGranted ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isGranted ? AppColors.success : AppColors.textSecondary,
              size: isGranted ? 28 : 20,
            ),
          ],
        ),
      ),
    );
  }
}
