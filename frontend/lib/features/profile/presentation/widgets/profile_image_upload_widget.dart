import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marriage_matching_app/generated/l10n/app_localizations.dart';
import 'dart:io';
import '../../../../core/utils/url_utils.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/image_upload_provider.dart';

class ProfileImageUploadWidget extends ConsumerStatefulWidget {
  final List<String> initialImages;
  final Function(List<String>) onImagesUploaded;
  final int maxImages;
  final int? mainImageIndex;
  final ValueChanged<int?>? onMainImageIndexChanged;

  const ProfileImageUploadWidget({
    super.key,
    this.initialImages = const [],
    required this.onImagesUploaded,
    this.maxImages = 6,
    this.mainImageIndex,
    this.onMainImageIndexChanged,
  });

  @override
  ConsumerState<ProfileImageUploadWidget> createState() =>
      _ProfileImageUploadWidgetState();
}

class _ProfileImageUploadWidgetState
    extends ConsumerState<ProfileImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];

  @override
  void initState() {
    super.initState();
    _uploadedImageUrls = widget.initialImages.toList();
  }

  @override
  void didUpdateWidget(covariant ProfileImageUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImages != widget.initialImages) {
      _uploadedImageUrls = widget.initialImages.toList();
      final adjustedMainIndex = _clampMainIndex(widget.mainImageIndex);
      if (adjustedMainIndex != widget.mainImageIndex) {
        widget.onMainImageIndexChanged?.call(adjustedMainIndex);
      }
    }
  }

  bool _ensureAuthenticated() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      return true;
    }
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginRequired)),
      );
      context.go('/login');
    }
    return false;
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (_selectedImages.length + _uploadedImageUrls.length >=
        widget.maxImages) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.maxImagesSelectLimit(widget.maxImages)),
          ),
        );
      }
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await _uploadImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageSelectionFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _pickAndUploadMultipleImages() async {
    final remaining =
        widget.maxImages - _selectedImages.length - _uploadedImageUrls.length;
    if (remaining <= 0) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.maxImagesSelectLimit(widget.maxImages)),
          ),
        );
      }
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty && mounted) {
        final List<File> newImages =
            images.take(remaining).map((xFile) => File(xFile.path)).toList();
        await _uploadImages(newImages);

        if (images.length > remaining && mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.maxImagesSelected(widget.maxImages)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageSelectionFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _uploadImage(File image) async {
    if (!_ensureAuthenticated()) {
      return;
    }
    try {
      final url =
          await ref.read(imageUploadProvider.notifier).uploadSingleImage(image);
      setState(() {
        _uploadedImageUrls.add(url);
      });
      widget.onImagesUploaded(_uploadedImageUrls);
      if (widget.mainImageIndex == null && _uploadedImageUrls.isNotEmpty) {
        widget.onMainImageIndexChanged?.call(0);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageUploadCompleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageUploadFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImages(List<File> images) async {
    if (!_ensureAuthenticated()) {
      return;
    }
    try {
      final urls =
          await ref.read(imageUploadProvider.notifier).uploadImages(images);
      setState(() {
        _uploadedImageUrls.addAll(urls);
      });
      widget.onImagesUploaded(_uploadedImageUrls);
      if (widget.mainImageIndex == null && _uploadedImageUrls.isNotEmpty) {
        widget.onMainImageIndexChanged?.call(0);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imagesUploadCompleted(urls.length))),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageUploadFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImageUrls.removeAt(index);
    });
    widget.onImagesUploaded(_uploadedImageUrls);
    widget.onMainImageIndexChanged?.call(_nextMainIndexAfterRemove(index));
  }

  int? _clampMainIndex(int? index) {
    if (index == null) return null;
    if (index < 0) return null;
    if (index >= _uploadedImageUrls.length) return null;
    return index;
  }

  int? _nextMainIndexAfterRemove(int removedIndex) {
    final currentMainIndex = widget.mainImageIndex;
    if (_uploadedImageUrls.isEmpty) return null;
    if (currentMainIndex == null) return null;
    if (removedIndex == currentMainIndex) return null;
    if (removedIndex < currentMainIndex) return currentMainIndex - 1;
    return currentMainIndex;
  }

  void _setMainImage(int index) {
    if (index < 0 || index >= _uploadedImageUrls.length) return;
    widget.onMainImageIndexChanged?.call(index);
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.selectFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(l10n.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.selectMultiplePhotos),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMultipleImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uploadState = ref.watch(imageUploadProvider);
    final totalImages = _uploadedImageUrls.length;
    final colorScheme = Theme.of(context).colorScheme;
    final mainIndex = _clampMainIndex(widget.mainImageIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.profilePhotos,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '$totalImages / ${widget.maxImages}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (uploadState.isUploading)
          const LinearProgressIndicator()
        else
          const SizedBox(height: 4),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalImages + 1,
            itemBuilder: (context, index) {
              if (index == totalImages) {
                return _buildAddButton();
              }
              return _buildImageCard(index);
            },
          ),
        ),
        const SizedBox(height: 8),
        if (totalImages > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              l10n.selectMainPhoto,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mainIndex == null
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                    fontWeight: mainIndex == null ? FontWeight.w600 : null,
                  ),
            ),
          ),
        Text(
          l10n.profilePhotoGuidelines(widget.maxImages),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo,
                size: 32, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(
              l10n.addPhoto,
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(int index) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isMain = widget.mainImageIndex == index;
    return Stack(
      children: [
        InkWell(
          onTap: () => _setMainImage(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isMain
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              image: DecorationImage(
                image: NetworkImage(
                  resolveNetworkUrl(_uploadedImageUrls[index]) ??
                      _uploadedImageUrls[index],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: () => _setMainImage(index),
              radius: 24,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isMain ? Icons.star : Icons.star_border,
                  color: isMain ? Colors.amber : Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        if (isMain)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                l10n.mainPhoto,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
