import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/ranking_user_model.dart';

class RankingUserDetailScreen extends StatelessWidget {
  const RankingUserDetailScreen({
    super.key,
    required this.user,
    required this.tipoRanking,
  });

  final RankingUserModel user;
  final String tipoRanking;

  Color get _rankBorderColor {
    if (user.posicion == 1) return AppColors.secondary;
    if (user.posicion == 2) return const Color(0xFFD1D5DB);
    if (user.posicion == 3) return const Color(0xFFCD7F32);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DETALLES DE JUGADOR', style: AppTextStyles.title),
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
          children: [
            // Tarjeta Principal del Perfil Gamer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.panelAlt,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _rankBorderColor.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _rankBorderColor.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar con insignia
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.panelLight,
                          border: Border.all(color: _rankBorderColor, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            user.username.isNotEmpty ? user.username[0].toUpperCase() : 'N',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _rankBorderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${user.posicion}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: user.posicion == 1 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Username y Rango Gamer
                  Text(user.username, style: AppTextStyles.headingMedium),
                  const SizedBox(height: 4),
                  Text(
                    user.rangoGamer,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Clasificación Activa Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'CLASIFICACIÓN $tipoRanking.toUpperCase()',
                      style: AppTextStyles.label,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Estadísticas del Jugador (Grid / Row)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PUNTOS TOTALES', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${user.puntos}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('POSICIÓN TABLA', style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.leaderboard_rounded, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'Puesto #${user.posicion}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Requisitos / Diferencia de Puntos si aplica
            if (user.puntosParaSiguientePuesto != null && user.posicion > 1) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A solo ${user.puntosParaSiguientePuesto} PTS de alcanzar la posición #${user.posicion - 1}',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Logros Destacados
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOGROS Y MEDALLAS DESTACADAS', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: user.logrosDestacados.map((logro) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.panelAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Text(
                              logro,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Botón Regresar al Ranking
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('VOLVER AL RANKING', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
