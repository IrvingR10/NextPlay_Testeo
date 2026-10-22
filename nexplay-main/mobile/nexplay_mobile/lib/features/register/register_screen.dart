import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/user_service.dart';
import '../../widgets/gamer_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  int _passwordStrength = 0;
  String? _serverError;

  final UserService _userService = UserService();

  Color get _strengthColor {
    if (_passwordStrength <= 1) return AppColors.error;
    if (_passwordStrength == 2) return AppColors.secondary;
    return AppColors.success;
  }

  String get _strengthLabel {
    if (_passwordStrength <= 1) return 'INICIAL';
    if (_passwordStrength == 2) return 'EN PROGRESO';
    return 'LISTA PARA COMPETIR';
  }

  int _getPasswordStrength(String value) {
    var score = 0;
    if (value.length >= 8) {
      score++;
    }
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(value) ||
        RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      score++;
    }
    return score;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_acceptTerms) {
      setState(() {
        _serverError = 'Debes aceptar los términos y condiciones.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    try {
      await _userService.createUser(
        nombreCompleto: _fullNameController.text.trim(),
        correo: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } catch (error) {
      if (!mounted) return;
      if (error is ApiConnectionException) {
        setState(() {
          _serverError = error.message;
        });
        final retry = await _showConnectionDialog();
        if (retry && mounted) await _submit();
        return;
      }
      setState(() {
        _serverError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showConnectionDialog() async {
    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('CONEXIÓN PERDIDA', style: AppTextStyles.title),
        content: const Text(
          'No pudimos conectar con el servidor NEXPLAY. Inténtalo nuevamente.',
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
    return retry == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.borderSoft,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'PASO 1 DE 2: CREDENCIALES',
                        style: AppTextStyles.label,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Crea tu Cuenta',
                      style: AppTextStyles.headingMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completa tus datos para entrar al ecosistema NEXPLAY.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 26),
                    GamerTextField(
                      controller: _fullNameController,
                      label: 'NOMBRE COMPLETO',
                      hintText: 'Tu nombre completo',
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.secondary,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'El nombre completo es obligatorio.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GamerTextField(
                      controller: _emailController,
                      label: 'CORREO ELECTRÓNICO',
                      hintText: 'ejemplo@correo.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        color: AppColors.secondary,
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'El correo es obligatorio.';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(text)) {
                          return 'Ingresa un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GamerTextField(
                      controller: _passwordController,
                      label: 'CONTRASEÑA',
                      hintText: '••••••••',
                      obscureText: !_passwordVisible,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.secondary,
                      ),
                      suffixIcon: IconButton(
                        tooltip: _passwordVisible
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onChanged: (value) => setState(() {
                        _passwordStrength = _getPasswordStrength(value);
                      }),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'La contraseña es obligatoria.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _strengthColor.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: _strengthColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'SEGURIDAD DE CONTRASEÑA',
                                  style: AppTextStyles.label,
                                ),
                              ),
                              Text(
                                _strengthLabel,
                                style: AppTextStyles.label.copyWith(
                                  color: _strengthColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(3, (index) {
                              return Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  height: 5,
                                  margin: EdgeInsets.only(
                                    right: index == 2 ? 0 : 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index < _passwordStrength
                                        ? _strengthColor
                                        : AppColors.border,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GamerTextField(
                      controller: _confirmPasswordController,
                      label: 'CONFIRMAR CONTRASEÑA',
                      hintText: '••••••••',
                      obscureText: !_confirmPasswordVisible,
                      prefixIcon: const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.secondary,
                      ),
                      suffixIcon: IconButton(
                        tooltip: _confirmPasswordVisible
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        onPressed: () => setState(
                          () => _confirmPasswordVisible =
                              !_confirmPasswordVisible,
                        ),
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty) {
                          return 'Debes confirmar la contraseña.';
                        }
                        if ((value ?? '') != _passwordController.text) {
                          return 'Las contraseñas no coinciden.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderSoft,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Acepto los términos y condiciones.',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_serverError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _serverError!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'CREAR CUENTA',
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          '¿Ya tienes cuenta? Iniciar sesión',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
