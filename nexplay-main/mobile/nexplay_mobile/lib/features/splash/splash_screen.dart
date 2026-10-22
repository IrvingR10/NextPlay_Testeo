import 'dart:async';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum _ServerStatus { checking, online, serverUnavailable, offline }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _introController;
  Timer? _connectionTimer;
  bool _buttonHovering = false;
  double _progress = 0;
  String _progressLabel = 'INICIALIZANDO PLATFORM...';
  _ServerStatus _serverStatus = _ServerStatus.checking;
  String _connectionType = 'Comprobando red';
  int? _latencyMs;
  bool _initializationRunning = true;
  bool _connectionCheckRunning = false;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    unawaited(_refreshConnection());
    _initializePlatform();
    _connectionTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshConnection(),
    );
  }

  Future<void> _initializePlatform() async {
    _setProgress(0.15, 'INICIALIZANDO PLATFORM...');
    _setProgress(0.6, 'PREPARANDO RECURSOS...');
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    _setProgress(0.82, 'CARGANDO INTERFAZ...');
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    _setProgress(1, 'NEXPLAY READY');
    setState(() => _initializationRunning = false);
  }

  Future<void> _refreshConnection() async {
    if (_connectionCheckRunning) return;
    _connectionCheckRunning = true;

    try {
      final networkResults = await Connectivity().checkConnectivity();
      final hasNetwork = networkResults.any(
        (result) => result != ConnectivityResult.none,
      );
      final networkType = _networkType(networkResults);

      if (!hasNetwork) {
        if (!mounted) return;
        setState(() {
          _serverStatus = _ServerStatus.offline;
          _connectionType = 'Sin conexión';
          _latencyMs = null;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _connectionType = networkType;
          _serverStatus = _ServerStatus.checking;
          _latencyMs = null;
        });
      }

      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.avatarsEndpoint}'),
          )
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();

      if (!mounted) return;
      setState(() {
        _connectionType = networkType;
        _latencyMs = stopwatch.elapsedMilliseconds;
        _serverStatus = response.statusCode >= 200 && response.statusCode < 300
            ? _ServerStatus.online
            : _ServerStatus.serverUnavailable;
      });
    } on TimeoutException {
      _setServerUnavailable();
    } on http.ClientException {
      _setServerUnavailable();
    } catch (_) {
      _setServerUnavailable();
    } finally {
      _connectionCheckRunning = false;
    }
  }

  String _networkType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
    if (results.contains(ConnectivityResult.mobile)) return 'Datos móviles';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    return 'Red disponible';
  }

  void _setServerUnavailable() {
    if (!mounted) return;
    setState(() {
      _serverStatus = _ServerStatus.serverUnavailable;
      _latencyMs = null;
    });
  }

  void _setProgress(double value, String label) {
    if (!mounted) return;
    setState(() {
      _progress = value.clamp(0, 1);
      _progressLabel = label;
    });
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _motionController.dispose();
    _introController.dispose();
    super.dispose();
  }

  String get _statusLabel {
    switch (_serverStatus) {
      case _ServerStatus.online:
        return 'NEX//CORE ONLINE';
      case _ServerStatus.serverUnavailable:
        return 'SERVIDOR SIN RESPUESTA';
      case _ServerStatus.offline:
        return 'OFFLINE';
      case _ServerStatus.checking:
        return 'COMPROBANDO...';
    }
  }

  Color get _statusColor {
    switch (_serverStatus) {
      case _ServerStatus.online:
        return AppColors.success;
      case _ServerStatus.serverUnavailable:
        return AppColors.secondary;
      case _ServerStatus.offline:
        return AppColors.error;
      case _ServerStatus.checking:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(fade);
    final percent = (_progress * 100).round();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF070A0F), Color(0xFF111923), Color(0xFF1B1012)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _motionController,
                builder: (context, child) => CustomPaint(
                  painter: _ParticleFieldPainter(
                    progress: _motionController.value,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 470),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    child: FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: slide,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxHeight < 720;
                            return SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _StatusRow(
                                    statusLabel: _statusLabel,
                                    statusColor: _statusColor,
                                    connectionType: _connectionType,
                                    latencyMs: _latencyMs,
                                  ),
                                  SizedBox(height: compact ? 14 : 26),
                                  _LogoHud(
                                    controller: _motionController,
                                    compact: compact,
                                  ),
                                  SizedBox(height: compact ? 12 : 18),
                                  const Text(
                                    'UN PERFIL. JUEGOS SIN LÍMITES.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.headingLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Competencia sin fricción en el ecosistema e-sports definitivo.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                  SizedBox(height: compact ? 18 : 26),
                                  _EntryButton(
                                    hovering: _buttonHovering,
                                    onHover: (value) =>
                                        setState(() => _buttonHovering = value),
                                    onPressed: () =>
                                        Navigator.of(context)
                                            .pushNamed(AppRoutes.login),
                                  ),
                                  SizedBox(height: compact ? 18 : 24),
                                  _ProgressStatus(
                                    progress: _progress,
                                    percent: percent,
                                    label: _initializationRunning
                                        ? _progressLabel
                                        : 'NEXPLAY READY',
                                    motionController: _motionController,
                                  ),
                                ],
                              ),
                            );
                          },
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
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.statusLabel,
    required this.statusColor,
    required this.connectionType,
    required this.latencyMs,
  });

  final String statusLabel;
  final Color statusColor;
  final String connectionType;
  final int? latencyMs;

  @override
  Widget build(BuildContext context) {
    final rightLabel = connectionType == 'Sin conexión'
        ? 'SIN CONEXIÓN'
        : '$connectionType  •  ${latencyMs ?? '--'} ms';
    return Row(
      children: [
        Expanded(
          child: _StatusPill(
            icon: Icons.hub_rounded,
            label: statusLabel,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusPill(
            icon: connectionType == 'Sin conexión'
                ? Icons.signal_wifi_connected_no_internet_4_rounded
                : Icons.network_check_rounded,
            label: rightLabel,
            color: AppColors.secondary,
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: alignEnd
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: color, fontSize: 9.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoHud extends StatelessWidget {
  const _LogoHud({required this.controller, required this.compact});

  final AnimationController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 226.0 : 276.0;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulse = 1 + math.sin(controller.value * math.pi * 2) * 0.025;
        return SizedBox(
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _OrbitalRing(
                size: size,
                progress: controller.value,
                color: AppColors.primary,
                dashCount: 18,
              ),
              _OrbitalRing(
                size: size - 42,
                progress: -controller.value * 0.7,
                color: AppColors.secondary,
                dashCount: 14,
                opacity: 0.58,
              ),
              Transform.rotate(
                angle: controller.value * math.pi * 2,
                child: Container(
                  width: size - 70,
                  height: size - 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primarySoft.withValues(alpha: 0.36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        blurRadius: 42,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: compact ? 132 : 154,
                  height: compact ? 132 : 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFFD9C0),
                        Color(0xFFFF775C),
                        Color(0xFF542027),
                      ],
                      stops: [0, 0.48, 1],
                    ),
                    border: Border.all(
                      color: AppColors.primarySoft,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.44),
                        blurRadius: 34,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: compact ? 94 : 108,
                      height: compact ? 94 : 108,
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_esports_rounded,
                            size: compact ? 34 : 42,
                            color: AppColors.primarySoft,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'NEXPLAY',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.secondary,
                              fontSize: compact ? 8 : 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EntryButton extends StatelessWidget {
  const _EntryButton({
    required this.hovering,
    required this.onHover,
    required this.onPressed,
  });

  final bool hovering;
  final ValueChanged<bool> onHover;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          hovering ? 1.018 : 1,
          hovering ? 1.018 : 1,
          1,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: hovering ? 0.42 : 0.22,
              ),
              blurRadius: hovering ? 28 : 18,
              spreadRadius: hovering ? 2 : 0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOCA PARA INGRESAR', style: AppTextStyles.button),
              Icon(
                hovering
                    ? Icons.arrow_forward_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStatus extends StatelessWidget {
  const _ProgressStatus({
    required this.progress,
    required this.percent,
    required this.label,
    required this.motionController,
  });

  final double progress;
  final int percent;
  final String label;
  final AnimationController motionController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motionController,
      builder: (context, child) {
        final shimmer = (motionController.value * 1.7) % 1;
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label,
                  ),
                ),
                Text('$percent%', style: AppTextStyles.button),
              ],
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                  Positioned.fill(
                    left: shimmer * 100 - 18,
                    child: IgnorePointer(
                      child: Container(
                        width: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.28),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'NEXPLAY SYSTEM // SECURE SESSION',
              style: AppTextStyles.label,
            ),
          ],
        );
      },
    );
  }
}

class _OrbitalRing extends StatelessWidget {
  const _OrbitalRing({
    required this.size,
    required this.progress,
    required this.color,
    required this.dashCount,
    this.opacity = 1,
  });

  final double size;
  final double progress;
  final Color color;
  final int dashCount;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: progress * math.pi * 2,
      child: CustomPaint(
        size: Size.square(size),
        painter: _DashedRingPainter(
          color: color.withValues(alpha: opacity),
          dashCount: dashCount,
        ),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({required this.color, required this.dashCount});

  final Color color;
  final int dashCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final dashAngle = math.pi * 2 / dashCount;

    for (var index = 0; index < dashCount; index++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        index * dashAngle + 0.08,
        dashAngle * 0.52,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashCount != dashCount;
  }
}

class _ParticleFieldPainter extends CustomPainter {
  _ParticleFieldPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var index = 0; index < 34; index++) {
      final seed = index * 37.17;
      final x = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final baseY = (math.cos(seed * 0.73) * 0.5 + 0.5) * size.height;
      final y = (baseY + progress * (18 + index % 5 * 9)) % size.height;
      final radius = 0.8 + (index % 3) * 0.45;
      final opacity = 0.12 + (index % 4) * 0.04;
      paint.color = (index.isEven ? AppColors.primarySoft : AppColors.secondary)
          .withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
