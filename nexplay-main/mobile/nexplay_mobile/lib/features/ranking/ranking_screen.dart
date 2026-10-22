import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/ranking_user_model.dart';
import '../../services/api_service.dart';
import 'ranking_user_detail_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<RankingUserModel>> _rankingFuture;
  String _selectedClasificacion = 'Semanal'; // Semanal, Mensual, Global

  @override
  void initState() {
    super.initState();
    _loadRankingData();
  }

  void _loadRankingData() {
    if (_selectedClasificacion == 'Global') {
      _rankingFuture = ApiService.getRankingGlobal();
    } else if (_selectedClasificacion == 'Semanal') {
      _rankingFuture = ApiService.getRankingSemanal();
    } else {
      _rankingFuture = ApiService.getRankingMensual();
    }
  }

  void _navigateToDetail(RankingUserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RankingUserDetailScreen(
          user: user,
          tipoRanking: _selectedClasificacion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TABLA DE POSICIONES', style: AppTextStyles.title),
        centerTitle: true,
        backgroundColor: AppColors.panel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<RankingUserModel>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          // Estado de Carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Cargando la clasificación de NEXPLAY...', style: AppTextStyles.bodySecondary),
                ],
              ),
            );
          }

          // Estado de Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudo conectar con el servidor de ranking.\n${snapshot.error}',
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
                          _loadRankingData();
                        });
                      },
                      child: const Text('REINTENTAR'),
                    ),
                  ],
                ),
              ),
            );
          }

          final rankingList = snapshot.data ?? [];

          // Estado Sin Usuarios
          if (rankingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.leaderboard_outlined, size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('No hay jugadores registrados en esta clasificación', style: AppTextStyles.bodySecondary),
                ],
              ),
            );
          }

          final top1 = rankingList.isNotEmpty ? rankingList[0] : null;
          final top2 = rankingList.length > 1 ? rankingList[1] : null;
          final top3 = rankingList.length > 2 ? rankingList[2] : null;
          final restList = rankingList.length > 3 ? rankingList.sublist(3) : <RankingUserModel>[];

          final currentUser = rankingList.firstWhere(
            (u) => u.isCurrentUser,
            orElse: () => RankingUserModel(
              id: -1,
              username: 'Tu Usuario',
              puntos: 0,
              posicion: rankingList.length + 1,
              puntosParaSiguientePuesto: 100,
              isCurrentUser: true,
            ),
          );

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ENCABEZADO Y EXPLICACIÓN RÁPIDA
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.military_tech_rounded, color: AppColors.secondary, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'Ranking $_selectedClasificacion',
                                  style: AppTextStyles.headingMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Gana partidas, acumula puntos y domina la liga gamer de NEXPLAY',
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SELECTOR DE CLASIFICACIÓN (Semanal / Mensual / Global)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.panelAlt,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: ['Semanal', 'Mensual', 'Global'].map((opcion) {
                              final isSelected = _selectedClasificacion == opcion;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_selectedClasificacion != opcion) {
                                      setState(() {
                                        _selectedClasificacion = opcion;
                                        _loadRankingData();
                                      });
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.35),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          opcion.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // PODIO DE MEDALLISTAS (TOP 3)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildPodiumSection(context, top1, top2, top3),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // SECCIÓN DE CLASIFICACIÓN GENERAL
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.format_list_numbered_rounded, color: AppColors.primary, size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text('CLASIFICACIÓN GENERAL', style: AppTextStyles.label),
                              ],
                            ),
                            const Text(
                              'PUNTOS PTS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                    // LISTA DE JUGADORES (4º EN ADELANTE)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final user = restList[index];
                            return _buildRankingRowCard(context, user);
                          },
                          childCount: restList.length,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),

              // BARRA FIJA DE TU POSICIÓN PERSONAL
              _buildPersonalPositionBar(context, currentUser),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodiumSection(BuildContext context, RankingUserModel? top1, RankingUserModel? top2, RankingUserModel? top3) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.panelAlt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'MEDALLISTAS DE LIGA $_selectedClasificacion.toUpperCase()',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2º Lugar (Izquierda - Plata)
              if (top2 != null)
                Expanded(child: _buildPodiumStep(context, top2, 2, const Color(0xFFD1D5DB), 85))
              else
                const Expanded(child: SizedBox()),

              // 1º Lugar (Centro - Oro Supremo)
              if (top1 != null)
                Expanded(child: _buildPodiumStep(context, top1, 1, AppColors.secondary, 115))
              else
                const Expanded(child: SizedBox()),

              // 3º Lugar (Derecha - Bronce)
              if (top3 != null)
                Expanded(child: _buildPodiumStep(context, top3, 3, const Color(0xFFCD7F32), 70))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep(BuildContext context, RankingUserModel user, int rank, Color rankColor, double height) {
    return GestureDetector(
      onTap: () => _navigateToDetail(user),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Icono Corona / Medalla
          if (rank == 1)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.secondary, size: 28),
            )
          else
            Icon(
              Icons.military_tech_rounded,
              color: rankColor,
              size: 24,
            ),
          const SizedBox(height: 6),

          // Avatar con Borde Resplandeciente
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: rank == 1 ? 72 : 58,
                height: rank == 1 ? 72 : 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.panel,
                  border: Border.all(color: rankColor, width: rank == 1 ? 3.5 : 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : 'N',
                    style: TextStyle(
                      fontSize: rank == 1 ? 28 : 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '$rankº',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: rank == 1 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Username y Puntos
          Text(
            user.username,
            style: TextStyle(
              fontSize: rank == 1 ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: rankColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${user.puntos} PTS',
              style: TextStyle(
                fontSize: rank == 1 ? 11 : 10,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Pedestal del Podio
          Container(
            height: height,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  rankColor.withValues(alpha: 0.25),
                  rankColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border.all(color: rankColor.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: rank == 1 ? 26 : 20,
                  fontWeight: FontWeight.w900,
                  color: rankColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingRowCard(BuildContext context, RankingUserModel user) {
    return GestureDetector(
      onTap: () => _navigateToDetail(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: user.isCurrentUser ? AppColors.primary.withValues(alpha: 0.15) : AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: user.isCurrentUser ? AppColors.primary : AppColors.border,
            width: user.isCurrentUser ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Posición Número
            Container(
              width: 36,
              alignment: Alignment.centerLeft,
              child: Text(
                '#${user.posicion}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: user.isCurrentUser ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),

            // Indicador de Tendencia (Arriba, Abajo, Mantiene)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: (user.tendencia == 'up'
                        ? AppColors.success
                        : (user.tendencia == 'down' ? AppColors.error : AppColors.textSecondary))
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                user.tendencia == 'up'
                    ? Icons.arrow_drop_up_rounded
                    : (user.tendencia == 'down'
                        ? Icons.arrow_drop_down_rounded
                        : Icons.remove_rounded),
                color: user.tendencia == 'up'
                    ? AppColors.success
                    : (user.tendencia == 'down' ? AppColors.error : AppColors.textSecondary),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Avatar Circulo
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.panelLight,
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : 'N',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nombre de Usuario e Insignia "TÚ"
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: user.isCurrentUser ? AppColors.primary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isCurrentUser)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'TÚ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Puntos Totales
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.panelAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${user.puntos} PTS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalPositionBar(BuildContext context, RankingUserModel currentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.panelAlt,
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('TU POSICIÓN PERSONAL', style: AppTextStyles.label),
                      const SizedBox(width: 6),
                      Text(
                        '#${currentUser.posicion}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentUser.username,
                    style: AppTextStyles.body,
                  ),
                  if (currentUser.puntosParaSiguientePuesto != null && currentUser.posicion > 1)
                    Text(
                      'A solo ${currentUser.puntosParaSiguientePuesto} PTS del puesto #${currentUser.posicion - 1}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
              ),
              child: Text(
                '${currentUser.puntos} PTS',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
