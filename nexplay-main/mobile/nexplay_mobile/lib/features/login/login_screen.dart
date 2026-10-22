import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Evita enviar dos solicitudes mientras se comprueba el perfil.
    if (_isLoading || !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.login(
        _correoController.text.trim(),
        _contrasenaController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] != true) {
        setState(() {
          _errorMessage =
              result['message']?.toString() ?? 'Error al iniciar sesi\u00F3n';
        });
        return;
      }

      // El login identifica la cuenta; se conserva su manejo actual de sesión.
      final rawData = result['data'];
      if (rawData is! Map) {
        throw Exception(
          'El servidor respondi\u00F3 correctamente, pero faltan los datos del usuario.',
        );
      }

      final rawUsuario = rawData['usuario'];
      if (rawUsuario is! Map) {
        throw Exception(
          'No se recibi\u00F3 la informaci\u00F3n del usuario autenticado.',
        );
      }

      final usuario = Map<String, dynamic>.from(rawUsuario);
      final rawId = usuario['idUsuario'] ?? usuario['id_usuario'];
      final userId = int.tryParse(rawId?.toString() ?? '');
      if (userId == null || userId <= 0) {
        throw Exception(
          'No se recibi\u00F3 un identificador de usuario v\u00E1lido.',
        );
      }

      // Consulta la API para obtener el perfil guardado, incluso en otro celular.
      // Si falla la consulta, se muestra el error sin abrir la creación del perfil.
      final user = await _userService.getUserById(userId);
      if (!mounted) return;

      // La creación exige apodo y permite guardar sin avatar.
      final hasGamerProfile = user.apodo?.trim().isNotEmpty == true;

      if (hasGamerProfile) {
        // Quita el login y las pantallas anteriores del historial de navegación.
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
        return;
      }

      // Solo las cuentas sin apodo guardado deben completar el perfil gamer.
      // Se envían los datos actuales, no una copia anterior del login.
      final profileData = <String, dynamic>{
        ...usuario,
        'idUsuario': user.idUsuario,
        'nombreCompleto': user.nombreCompleto,
        'correo': user.correo,
        'apodo': user.apodo,
        'idAvatar': user.idAvatar,
        'xpTotal': user.xpTotal,
        'monedas': user.monedas,
        'gemas': user.gemas,
      };

      Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.profileCreation, arguments: profileData);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      // Mantiene el botón deshabilitado hasta terminar login y consulta de perfil.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icono gamer principal.
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceCard,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_esports_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'NEXPLAY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Inicia sesi\u00F3n para continuar tu aventura',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Contenedor del formulario.
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error de autenticación.
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Correo electrónico.
                          TextFormField(
                            controller: _correoController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Correo electr\u00F3nico',
                              labelStyle: TextStyle(color: AppColors.textGray),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa tu correo';
                              }

                              if (!value.contains('@')) {
                                return 'Ingresa un correo v\u00E1lido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Contraseña.
                          TextFormField(
                            controller: _contrasenaController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Contrase\u00F1a',
                              labelStyle: const TextStyle(
                                color: AppColors.textGray,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textGray,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contrase\u00F1a';
                              }

                              if (value.length < 4) {
                                return 'La contrase\u00F1a debe tener al menos 4 caracteres';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          // Botón de inicio de sesión.
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textWhite,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.textWhite,
                                    ),
                                  )
                                : const Text(
                                    'INGRESAR',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Acceso al registro.
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          '\u00BFNo tienes cuenta?',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.register);
                          },
                          child: const Text(
                            'Reg\u00EDstrate',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
      ),
    );
  }
}
