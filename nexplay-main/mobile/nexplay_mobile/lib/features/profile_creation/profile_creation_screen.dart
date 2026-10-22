import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/avatar_model.dart';
import '../../services/avatar_service.dart';
import '../../services/user_service.dart';
import '../../widgets/primary_button.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen>
    with SingleTickerProviderStateMixin {
  final AvatarService _avatarService = AvatarService();
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nicknameController = TextEditingController();
  late final AnimationController _idleController;

  bool _isLoading = true;
  bool _isSubmitting = false;
  List<AvatarModel> _avatars = const [];
  AvatarModel? _selectedAvatar;
  Uint8List? _profilePhotoBytes;
  final Set<String> _selectedTags = <String>{'NEX'};
  String? _errorMessage;

  static const _suggestedTags = ['PRO', 'FIRE', 'NEX', 'APEX'];

  Animation<double> get _idleFloat => Tween<double>(
    begin: 0,
    end: -6,
  ).animate(CurvedAnimation(parent: _idleController, curve: Curves.easeInOut));

  Animation<double> get _idleScale => Tween<double>(
    begin: 1,
    end: 1.015,
  ).animate(CurvedAnimation(parent: _idleController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadAvatars();

    final nickname = widget.userData['apodo']?.toString();
    if (nickname != null && nickname.isNotEmpty) {
      _nicknameController.text = nickname;
    }
  }

  Future<void> _loadAvatars() async {
    try {
      final avatars = await _avatarService.getAvatars();
      if (!mounted) return;

      setState(() {
        _avatars = avatars;
        _selectedAvatar = _avatarMatchingUserData(avatars);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _avatars = const [];
        _isLoading = false;
        _errorMessage = 'No se pudieron cargar los avatares.';
      });
      await _showConnectionDialog(
        onRetry: () {
          _loadAvatars();
        },
      );
    }
  }

  AvatarModel? _avatarMatchingUserData(List<AvatarModel> avatars) {
    final rawAvatarId = widget.userData['idAvatar'];
    if (rawAvatarId is! num) return null;

    for (final avatar in avatars) {
      if (avatar.idAvatar == rawAvatarId.toInt()) {
        return avatar;
      }
    }
    return null;
  }

  Future<void> _pickProfilePhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 88,
    );
    if (pickedFile == null || !mounted) return;

    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _profilePhotoBytes = bytes;
      _errorMessage = null;
    });
  }

  Future<void> _openAvatarPreview(AvatarModel avatar) async {
    final imageUrl = avatar.resolvedImageUrl;
    debugPrint(
      'Avatar seleccionado para preview: ${avatar.nombre} -> $imageUrl',
    );

    final confirmedAvatar = await showDialog<AvatarModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (context) => _AvatarPreviewDialog(avatar: avatar),
    );

    if (confirmedAvatar == null || !mounted) return;

    debugPrint(
      'Avatar confirmado: ${confirmedAvatar.nombre} -> ${confirmedAvatar.resolvedImageUrl}',
    );
    setState(() {
      _selectedAvatar = confirmedAvatar;
      _profilePhotoBytes = null;
    });
  }

  Future<void> _saveProfile() async {
    final userId = widget.userData['idUsuario'];
    final nickname = _nicknameController.text.trim();

    if (userId == null || userId is! num) {
      setState(() {
        _errorMessage = 'Falta la información del usuario.';
      });
      return;
    }

    if (nickname.isEmpty) {
      setState(() {
        _errorMessage = 'El apodo gamer es obligatorio.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _userService.updateUser(
        userId: userId.toInt(),
        nombreCompleto: widget.userData['nombreCompleto']?.toString() ?? '',
        apodo: nickname,
        idAvatar: _selectedAvatar?.idAvatar,
      );

      if (!mounted) return;
      Navigator.of(context).pushNamed('/home');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
      if (error is ApiConnectionException) {
        await _showConnectionDialog(
          onRetry: () {
            _saveProfile();
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showConnectionDialog({required VoidCallback onRetry}) async {
    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('CONEXIÓN PERDIDA', style: AppTextStyles.title),
        content: const Text(
          'No pudimos conectar con NEXPLAY. Revisa tu conexión e inténtalo nuevamente.',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CERRAR', style: AppTextStyles.label),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('REINTENTAR', style: AppTextStyles.button),
          ),
        ],
      ),
    );
    if (retry == true && mounted) onRetry();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewName = _nicknameController.text.trim().isNotEmpty
        ? _nicknameController.text.trim()
        : 'GAMER';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _StepHeader(),
                        const SizedBox(height: 22),
                        const Text(
                          'CREA TU IDENTIDAD',
                          style: AppTextStyles.headingMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Elige la imagen que llevará tu nombre en cada partida.',
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: 24),
                        _FeaturedAvatar(
                          selectedAvatar: _selectedAvatar,
                          profilePhotoBytes: _profilePhotoBytes,
                          onPickPhoto: _pickProfilePhoto,
                          idleFloat: _idleFloat,
                          idleScale: _idleScale,
                        ),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AVATARES NEXPLAY',
                              style: AppTextStyles.label,
                            ),
                            Text(
                              '${_avatars.length} DISPONIBLES',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primarySoft,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 148,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _avatars.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final avatar = _avatars[index];
                              return _AvatarSlot(
                                avatar: avatar,
                                selected:
                                    _selectedAvatar?.idAvatar ==
                                    avatar.idAvatar,
                                onTap: () => _openAvatarPreview(avatar),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text('APODO GAMER', style: AppTextStyles.label),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _nicknameController,
                          style: AppTextStyles.body,
                          maxLength: 20,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu apodo',
                            counterText: '',
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                              color: AppColors.secondary,
                            ),
                            suffixIcon: const Icon(
                              Icons.verified_rounded,
                              color: AppColors.success,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'INSIGNIAS SUGERIDAS',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _suggestedTags.map((tag) {
                            final selected = _selectedTags.contains(tag);
                            return FilterChip(
                              label: Text('[$tag]'),
                              selected: selected,
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                              },
                              labelStyle: AppTextStyles.label.copyWith(
                                color: selected
                                    ? AppColors.background
                                    : AppColors.textSecondary,
                              ),
                              selectedColor: AppColors.secondary,
                              backgroundColor: AppColors.panel,
                              side: BorderSide(
                                color: selected
                                    ? AppColors.secondary
                                    : AppColors.borderSoft,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'VISTA PREVIA DEL PLAYER',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 12),
                        _PlayerCard(
                          nickname: previewName,
                          selectedAvatar: _selectedAvatar,
                          profilePhotoBytes: _profilePhotoBytes,
                          selectedTags: _selectedTags,
                          idleFloat: _idleFloat,
                          idleScale: _idleScale,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'GUARDAR IDENTIDAD',
                          onPressed: _saveProfile,
                          isLoading: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: const Text('PASO 2 DE 2: PERFIL', style: AppTextStyles.label),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.5),
            ),
          ),
          child: const Text('AVATAR ACTIVO', style: AppTextStyles.label),
        ),
      ],
    );
  }
}

class _FeaturedAvatar extends StatelessWidget {
  const _FeaturedAvatar({
    required this.selectedAvatar,
    required this.profilePhotoBytes,
    required this.onPickPhoto,
    required this.idleFloat,
    required this.idleScale,
  });

  final AvatarModel? selectedAvatar;
  final Uint8List? profilePhotoBytes;
  final VoidCallback onPickPhoto;
  final Animation<double> idleFloat;
  final Animation<double> idleScale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: idleFloat,
      builder: (context, child) {
        final glowAlpha = 0.25 + ((idleFloat.value + 6) / 6) * 0.2;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.panelAlt, AppColors.panel],
            ),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: glowAlpha),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IDENTIDAD SELECCIONADA',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primarySoft,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 176,
                      height: 176,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.65),
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([idleFloat, idleScale]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, idleFloat.value),
                            child: Transform.scale(
                              scale: idleScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            child: profilePhotoBytes != null
                                ? Image.memory(
                                    profilePhotoBytes!,
                                    key: const ValueKey('profile-photo'),
                                    fit: BoxFit.cover,
                                  )
                                : _RemoteAvatar(
                                    key: ValueKey(selectedAvatar?.idAvatar),
                                    avatar: selectedAvatar,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Material(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: onPickPhoto,
                          borderRadius: BorderRadius.circular(16),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.background,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: [
                    Text(
                      profilePhotoBytes != null
                          ? 'FOTO PERSONAL'
                          : selectedAvatar?.nombre ?? 'Selecciona un avatar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profilePhotoBytes != null
                          ? 'Toca la cámara para cambiarla.'
                          : 'Elige otra identidad desde el carrusel.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final AvatarModel avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 112,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: selected ? AppColors.panelAlt : AppColors.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderSoft,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.24),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: _RemoteAvatar(avatar: avatar, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                avatar.nombre.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(
                  color: selected
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPreviewDialog extends StatefulWidget {
  const _AvatarPreviewDialog({required this.avatar});

  final AvatarModel avatar;

  @override
  State<_AvatarPreviewDialog> createState() => _AvatarPreviewDialogState();
}

class _AvatarPreviewDialogState extends State<_AvatarPreviewDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _previewController;
  late final Animation<double> _previewScale;

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _previewScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _previewController, curve: Curves.easeOutBack),
    );
    _previewController.forward();
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.avatar.resolvedImageUrl;
    debugPrint('Render avatar preview: ${widget.avatar.nombre} -> $imageUrl');

    return FadeTransition(
      opacity: _previewController,
      child: ScaleTransition(
        scale: _previewScale,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 28,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('VISTA PREVIA', style: AppTextStyles.label),
                      IconButton(
                        tooltip: 'Volver',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 320,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _RemoteAvatar(
                        avatar: widget.avatar,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.avatar.nombre,
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Así se verá tu identidad en NEXPLAY.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.borderSoft),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'VOLVER',
                            style: AppTextStyles.label,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(widget.avatar),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'USAR ESTE AVATAR',
                            style: AppTextStyles.label,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoteAvatar extends StatelessWidget {
  const _RemoteAvatar({super.key, required this.avatar, required this.fit});

  final AvatarModel? avatar;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatar?.resolvedImageUrl ?? '';
    debugPrint('Render avatar: ${avatar?.nombre ?? 'ninguno'} -> $imageUrl');
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.person_rounded, size: 48, color: AppColors.secondary),
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      webHtmlElementStrategy: kIsWeb
          ? WebHtmlElementStrategy.prefer
          : WebHtmlElementStrategy.never,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('ERROR cargando avatar $imageUrl: $error');
        return const Center(
          child: Icon(
            Icons.person_rounded,
            size: 48,
            color: AppColors.secondary,
          ),
        );
      },
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.nickname,
    required this.selectedAvatar,
    required this.profilePhotoBytes,
    required this.selectedTags,
    required this.idleFloat,
    required this.idleScale,
  });

  final String nickname;
  final AvatarModel? selectedAvatar;
  final Uint8List? profilePhotoBytes;
  final Set<String> selectedTags;
  final Animation<double> idleFloat;
  final Animation<double> idleScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2026), Color(0xFF151A24)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'NEXPLAY // PLAYER CARD',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'ID: NX-2024-ALPHA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primarySoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 88,
                height: 88,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([idleFloat, idleScale]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, idleFloat.value * 0.55),
                        child: Transform.scale(
                          scale: idleScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      child: profilePhotoBytes != null
                          ? Image.memory(
                              profilePhotoBytes!,
                              key: const ValueKey('player-profile-photo'),
                              fit: BoxFit.cover,
                            )
                          : _RemoteAvatar(
                              key: ValueKey(selectedAvatar?.idAvatar),
                              avatar: selectedAvatar,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Pionero NexPlay',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: selectedTags.map((tag) {
                        return Text(
                          '[$tag]',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.secondary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LVL 1', style: AppTextStyles.button),
              Text(
                'XP 0 / 500',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.secondarySoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: 0.08,
              minHeight: 7,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
