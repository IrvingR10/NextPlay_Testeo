import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/achievement_model.dart';
import '../../services/api_service.dart';
import 'achievement_detail_screen.dart';

class LogrosScreen extends StatefulWidget {
  const LogrosScreen({super.key});

  @override
  State<LogrosScreen> createState() => _LogrosScreenState();
}

class _LogrosScreenState extends State<LogrosScreen> {
  late Future<List<AchievementModel>> _logrosFuture;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadLogros();
  }

  void _loadLogros() {
    _logrosFuture = ApiService.getLogros();
  }

  List<AchievementModel> _filterLogros(List<AchievementModel> logros) {
    if (_selectedFilter == 'Desbloqueados') {
      return logros.where((l) => l.desbloqueado).toList();
    } else if (_selectedFilter == 'Bloqueados') {
      return logros.where((l) => !l.desbloqueado).toList();
    }
    return logros;
  }

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

  void _navigateToDetail(AchievementModel logro) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AchievementDetailScreen(achievement: logro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LOGROS Y MEDALLAS', style: AppTextStyles.title),
        centerTitle: true,
        backgroundColor: AppColors.panel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<AchievementModel>>(
        future: _logrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar los logros:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _loadLogros();
                        });
                      },
                      child: const Text('REINTENTAR'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allLogros = snapshot.data ?? [];
          final filteredLogros = _filterLogros(allLogros);
          final desbloqueadosCount = allLogros.where((l) => l.desbloqueado).length;
          final totalXp = allLogros.fold<int>(0, (sum, l) => sum + (l.desbloqueado ? l.recompensaXp : 0));

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Banner de Resumen de Progreso
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.panelAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.secondary.withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: AppColors.secondary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PROGRESO DE LOGROS', style: AppTextStyles.title),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Desbloqueados $desbloqueadosCount de ${allLogros.length} insignias',
                                    style: AppTextStyles.bodySecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Barra de Progreso General
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: allLogros.isEmpty ? 0 : desbloqueadosCount / allLogros.length,
                            minHeight: 10,
                            backgroundColor: AppColors.panelLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Estadísticas de Recompensas de Logros
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 4),
                                Text('+$totalXp XP Obtenidos', style: AppTextStyles.body),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 18),
                                const SizedBox(width: 4),
                                Text('${(allLogros.isEmpty ? 0 : (desbloqueadosCount / allLogros.length) * 100).toInt()}% Completado', style: AppTextStyles.bodySecondary),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filtros (Chips: Todos / Desbloqueados / Bloqueados)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['Todos', 'Desbloqueados', 'Bloqueados'].map((filtro) {
                      final isSelected = _selectedFilter == filtro;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ChoiceChip(
                          label: Text(filtro),
                          selected: isSelected,
                          selectedColor: AppColors.secondary,
                          backgroundColor: AppColors.panelAlt,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? AppColors.secondary : AppColors.border,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilter = filtro;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Lista de Logros / Estado Vacío Estilizado
              filteredLogros.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.panelAlt,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                                ),
                                child: const Icon(
                                  Icons.military_tech_outlined,
                                  size: 48,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'GALERÍA DE MEDALLAS EN ESPERA',
                                style: AppTextStyles.title,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tus medallas y trofeos se desbloquearán automáticamente cuando acumules tus primeras victorias en la plataforma.',
                                style: AppTextStyles.bodySecondary,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.panel,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.secondary),
                                    SizedBox(width: 6),
                                    Text(
                                      'SISTEMA DE LOGROS CONECTADO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final logro = filteredLogros[index];
                            return _buildLogroCard(context, logro);
                          },
                          childCount: filteredLogros.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogroCard(BuildContext context, AchievementModel logro) {
    final isUnlocked = logro.desbloqueado;

    return GestureDetector(
      onTap: () => _navigateToDetail(logro),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.panel : AppColors.panelAlt.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? AppColors.secondary.withValues(alpha: 0.6)
                : AppColors.border,
            width: isUnlocked ? 1.5 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isUnlocked ? AppColors.secondary : AppColors.panelLight)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? AppColors.secondary.withValues(alpha: 0.6)
                      : AppColors.border,
                ),
              ),
              child: Icon(
                isUnlocked ? _getIconData(logro.icono) : Icons.lock_rounded,
                color: isUnlocked ? AppColors.secondary : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          logro.nombre,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnlocked)
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    logro.descripcion,
                    style: AppTextStyles.bodySecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  if (!isUnlocked) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: logro.progreso,
                              minHeight: 6,
                              backgroundColor: AppColors.panelLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(logro.progreso * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Text(
                        '+${logro.recompensaXp} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '+${logro.recompensaMonedas} Monedas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.secondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
