import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/achievement_model.dart';

class AchievementDetailScreen extends StatelessWidget {
  const AchievementDetailScreen({
    super.key,
    required this.achievement,
  });

  final AchievementModel achievement;

  IconData _getIconData(String icono) {
    switch (icono) {
      case 'verified_user':
        return Icons.verified_user_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'leaderboard':
        return Icons.leaderboard_rounded;
      case 'ads_click':
        return Icons.ads_click_rounded;
      case 'stars':
        return Icons.stars_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.desbloqueado;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DETALLE DEL LOGRO', style: AppTextStyles.title),
        centerTitle: true,
        backgroundColor: AppColors.panel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header del Logro con Insignia
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.panelAlt,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isUnlocked ? AppColors.secondary.withValues(alpha: 0.6) : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isUnlocked ? AppColors.secondary : AppColors.panelLight).withValues(alpha: 0.15),
                      border: Border.all(
                        color: isUnlocked ? AppColors.secondary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isUnlocked ? _getIconData(achievement.icono) : Icons.lock_rounded,
                      size: 52,
                      color: isUnlocked ? AppColors.secondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    achievement.nombre,
                    style: AppTextStyles.headingMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isUnlocked ? AppColors.success : AppColors.panelLight).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUnlocked ? AppColors.success : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUnlocked ? Icons.verified_rounded : Icons.lock_rounded,
                          size: 14,
                          color: isUnlocked ? AppColors.success : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isUnlocked ? 'DESBLOQUEADO' : 'BLOQUEADO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tarjeta de Descripción y Requisitos
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DESCRIPCIÓN DEL LOGRO', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Text(achievement.descripcion, style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  const Text('REQUISITOS PARA DESBLOQUEAR', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  Text(achievement.requisitos, style: AppTextStyles.bodySecondary),
                  if (achievement.fechaDesbloqueo != null) ...[
                    const SizedBox(height: 16),
                    const Text('FECHA DE DESBLOQUEO', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    Text(
                      achievement.fechaDesbloqueo!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Barra de Progreso si está Bloqueado
            if (!isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PROGRESO DEL OBJETIVO', style: AppTextStyles.label),
                        Text(
                          '${(achievement.progreso * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: achievement.progreso,
                        minHeight: 10,
                        backgroundColor: AppColors.panelLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Tarjeta de Recompensas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RECOMPENSAS DE INSIGNIA', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 22),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PUNTOS XP', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  Text(
                                    '+${achievement.recompensaXp} XP',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: AppColors.secondary, size: 22),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('MONEDAS', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  Text(
                                    '+${achievement.recompensaMonedas}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Botón Volver a Logros
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('VOLVER A LOGROS', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}
