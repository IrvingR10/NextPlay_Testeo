import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/avatar_model.dart';
import '../../models/game_model.dart';
import '../../models/user_model.dart';
import '../../services/avatar_service.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';

// Los escapes Unicode conservan las tildes y simbolos al copiar desde PowerShell.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  final AvatarService _avatarService = AvatarService();

  UserModel? _user;
  AvatarModel? _avatar;
  List<GameModel> _games = const [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception(
          'No encontramos la sesi\u00F3n del jugador. Inicia sesi\u00F3n nuevamente.',
        );
      }

      final user = await _userService.getUserById(userId);

      AvatarModel? avatar;

      if (user.idAvatar != null) {
        final avatars = await _avatarService.getAvatars();

        for (final currentAvatar in avatars) {
          if (currentAvatar.idAvatar == user.idAvatar) {
            avatar = currentAvatar;
            break;
          }
        }
      }

      final games = await ApiService.getJuegos();

      if (!mounted) return;

      setState(() {
        _user = user;
        _avatar = avatar;
        _games = games;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _openGames() {
    Navigator.of(context).pushNamed(AppRoutes.games);
  }

  void _openProfile() {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _showComingSoon(String module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$module estar\u00E1 disponible pr\u00F3ximamente.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _errorMessage != null
            ? _HomeError(message: _errorMessage!, onRetry: _loadHome)
            : _HomeContent(
                user: _user!,
                avatar: _avatar,
                games: _games,
                onGames: _openGames,
                onComingSoon: _showComingSoon,
                onProfile: _openProfile,
              ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.user,
    required this.avatar,
    required this.games,
    required this.onGames,
    required this.onComingSoon,
    required this.onProfile,
  });

  final UserModel user;
  final AvatarModel? avatar;
  final List<GameModel> games;
  final VoidCallback onGames;
  final ValueChanged<String> onComingSoon;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final rank = RankProgress.fromXp(user.xpTotal);

    final nickname = user.apodo?.trim().isNotEmpty == true
        ? user.apodo!.trim()
        : user.nombreCompleto;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final horizontalPadding = width < 380 ? 16.0 : 22.0;
        final compact = width < 390;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  final state = context
                      .findAncestorStateOfType<_HomeScreenState>();

                  await state?._loadHome();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _NexPlayHeader(),

                          const SizedBox(height: 28),

                          _PlayerHeader(
                            nickname: nickname,
                            avatar: avatar,
                            compact: compact,
                            onNotificationTap: () {
                              onComingSoon('Notificaciones');
                            },
                          ),

                          const SizedBox(height: 22),

                          _CoinsCard(monedas: user.monedas),

                          const SizedBox(height: 18),

                          _RankCard(rank: rank, totalXp: user.xpTotal),

                          const SizedBox(height: 32),

                          _SectionTitle(
                            icon: Icons.local_fire_department_rounded,
                            title: 'JUEGOS DESTACADOS',
                            actionText: 'VER TODOS',
                            onAction: onGames,
                          ),

                          const SizedBox(height: 14),

                          _FeaturedGames(
                            compact: compact,
                            games: games,
                            onGames: onGames,
                          ),

                          const SizedBox(height: 34),

                          const _SectionTitle(
                            icon: Icons.bolt_rounded,
                            title: 'ACCESOS R\u00C1PIDOS',
                          ),

                          const SizedBox(height: 14),

                          _QuickActions(
                            onGames: onGames,
                            onRanking: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.ranking);
                            },
                            onChallenges: () {
                              Navigator.of(context).pushNamed(AppRoutes.retos);
                            },
                            onAchievements: () {
                              Navigator.of(context).pushNamed(AppRoutes.logros);
                            },
                          ),

                          const SizedBox(height: 34),

                          _DailyChallenge(onPlay: onGames),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            _BottomNavigation(
              onGames: onGames,
              onRanking: () =>
                  Navigator.of(context).pushNamed(AppRoutes.ranking),
              onProfile: onProfile,
            ),
          ],
        );
      },
    );
  }
}

class _NexPlayHeader extends StatelessWidget {
  const _NexPlayHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(children: [_NexPlayLogo()]);
  }
}

class _NexPlayLogo extends StatelessWidget {
  const _NexPlayLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFFC928), Color(0xFFFF5E42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text(
            'N',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(width: 7),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEXPLAY',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.7,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'GAMING PLATFORM',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 6,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.nickname,
    required this.avatar,
    required this.compact,
    required this.onNotificationTap,
  });

  final String nickname;
  final AvatarModel? avatar;
  final bool compact;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AvatarCircle(avatar: avatar, size: compact ? 68 : 78),

        SizedBox(width: compact ? 12 : 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u00A1Hola, $nickname! \u26A1',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: compact ? 19 : 23,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Listo para competir hoy',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: compact ? 13 : 15,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: compact ? 46 : 54,
            height: compact ? 46 : 54,
            decoration: BoxDecoration(
              color: AppColors.panelAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
                Positioned(
                  right: 9,
                  top: 8,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.avatar, required this.size});

  final AvatarModel? avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.panel,
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: avatar != null && avatar!.resolvedImageUrl.isNotEmpty
            ? Image.network(
                avatar!.resolvedImageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    color: AppColors.secondary,
                    size: 40,
                  );
                },
              )
            : const Icon(
                Icons.person_rounded,
                color: AppColors.secondary,
                size: 40,
              ),
      ),
    );
  }
}

class _CoinsCard extends StatelessWidget {
  const _CoinsCard({required this.monedas});

  final int monedas;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.monetization_on_outlined,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Text(
              'MONEDAS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),

          Text(
            '$monedas',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.rank, required this.totalXp});

  final RankProgress rank;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final progress = rank.isLegend
        ? 1.0
        : (rank.pointsInCurrentLevel / RankProgress.pointsPerLevel).clamp(
            0.0,
            1.0,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: rank.color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: rank.color.withValues(alpha: 0.08), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: rank.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.military_tech_rounded,
                  color: rank.color,
                  size: 28,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RANGO COMPETITIVO',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rank.displayName.toUpperCase(),
                      style: TextStyle(
                        color: rank.color,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$totalXp PTS',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(
                  rank.isLegend
                      ? 'RANGO M\u00C1XIMO'
                      : '${rank.pointsInCurrentLevel} / ${RankProgress.pointsPerLevel} PTS',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!rank.isLegend)
                Text(
                  'SIGUIENTE: ${rank.nextRankName}',
                  style: const TextStyle(
                    color: AppColors.primarySoft,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(rank.color),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            rank.isLegend
                ? 'Has alcanzado la cima competitiva de NEXPLAY.'
                : 'Consigue ${RankProgress.pointsPerLevel - rank.pointsInCurrentLevel} puntos m\u00E1s para subir de rango.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 25),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText!,
              style: const TextStyle(
                color: AppColors.primarySoft,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeaturedGames extends StatelessWidget {
  const _FeaturedGames({
    required this.compact,
    required this.games,
    required this.onGames,
  });

  final bool compact;
  final List<GameModel> games;
  final VoidCallback onGames;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No hay juegos disponibles.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SizedBox(
      height: compact ? 290 : 310,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final game = games[index];

          return _GameCard(
            width: compact ? 285 : 325,
            game: game,
            onTap: onGames,
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.width,
    required this.game,
    required this.onTap,
  });

  final double width;
  final GameModel game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = game.categorias.isNotEmpty
        ? game.categorias.map((item) => item.nombre).join(' / ')
        : 'SIN CATEGORIA';

    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (game.imagenUrl != null)
                  Image.network(
                    game.imagenUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.background,
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        size: 72,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.sports_esports_rounded,
                      size: 72,
                      color: AppColors.primary,
                    ),
                  ),
                Positioned(
                  left: 13,
                  top: 13,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'DESTACADO',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primarySoft,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  game.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  game.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.sports_esports_rounded),
                    label: const Text('VER JUEGOS'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onGames,
    required this.onRanking,
    required this.onChallenges,
    required this.onAchievements,
  });

  final VoidCallback onGames;
  final VoidCallback onRanking;
  final VoidCallback onChallenges;
  final VoidCallback onAchievements;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 340;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickAction(
              width: itemWidth,
              icon: Icons.sports_esports_rounded,
              title: 'JUEGOS',
              onTap: onGames,
            ),
            _QuickAction(
              width: itemWidth,
              icon: Icons.flag_outlined,
              title: 'RETOS',
              onTap: onChallenges,
            ),
            _QuickAction(
              width: itemWidth,
              icon: Icons.emoji_events_outlined,
              title: 'RANKING',
              onTap: onRanking,
            ),
            _QuickAction(
              width: itemWidth,
              icon: Icons.workspace_premium_outlined,
              title: 'LOGROS',
              onTap: onAchievements,
            ),
          ],
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.width,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallenge extends StatelessWidget {
  const _DailyChallenge({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF271C21), AppColors.panel],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'RETO DIARIO',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'Demuestra tus habilidades',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Completa partidas y consigue puntos para avanzar en tu rango competitivo.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 17),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('JUGAR AHORA'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.onGames,
    required this.onRanking,
    required this.onProfile,
  });

  final VoidCallback onGames;
  final VoidCallback onRanking;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'INICIO',
                  selected: true,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.sports_esports_rounded,
                  label: 'JUEGOS',
                  onTap: onGames,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'RANKING',
                  onTap: onRanking,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.account_circle_outlined,
                  label: 'PERFIL',
                  onTap: onProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 52,
            ),
            const SizedBox(height: 16),
            const Text(
              'NO PUDIMOS CARGAR TU HOME',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }
}

class RankProgress {
  const RankProgress({
    required this.displayName,
    required this.nextRankName,
    required this.pointsInCurrentLevel,
    required this.isLegend,
    required this.color,
  });

  static const int pointsPerLevel = 200;

  final String displayName;
  final String nextRankName;
  final int pointsInCurrentLevel;
  final bool isLegend;
  final Color color;

  static RankProgress fromXp(int rawXp) {
    final xp = rawXp < 0 ? 0 : rawXp;

    const rankedSteps = <_RankStep>[
      _RankStep('Bronce 1', Color(0xFFCD7F32)),
      _RankStep('Bronce 2', Color(0xFFCD7F32)),
      _RankStep('Bronce 3', Color(0xFFCD7F32)),
      _RankStep('Bronce 4', Color(0xFFCD7F32)),
      _RankStep('Bronce 5', Color(0xFFCD7F32)),
      _RankStep('Plata 1', Color(0xFFC0C0C0)),
      _RankStep('Plata 2', Color(0xFFC0C0C0)),
      _RankStep('Plata 3', Color(0xFFC0C0C0)),
      _RankStep('Plata 4', Color(0xFFC0C0C0)),
      _RankStep('Plata 5', Color(0xFFC0C0C0)),
      _RankStep('Oro 1', Color(0xFFF7C948)),
      _RankStep('Oro 2', Color(0xFFF7C948)),
      _RankStep('Oro 3', Color(0xFFF7C948)),
      _RankStep('Oro 4', Color(0xFFF7C948)),
      _RankStep('Oro 5', Color(0xFFF7C948)),
      _RankStep('Platino 1', Color(0xFF7DE2D1)),
      _RankStep('Platino 2', Color(0xFF7DE2D1)),
      _RankStep('Platino 3', Color(0xFF7DE2D1)),
      _RankStep('Platino 4', Color(0xFF7DE2D1)),
      _RankStep('Platino 5', Color(0xFF7DE2D1)),
      _RankStep('Diamante 1', Color(0xFF7FC8FF)),
      _RankStep('Diamante 2', Color(0xFF7FC8FF)),
      _RankStep('Diamante 3', Color(0xFF7FC8FF)),
      _RankStep('Diamante 4', Color(0xFF7FC8FF)),
      _RankStep('Diamante 5', Color(0xFF7FC8FF)),
    ];

    // La longitud de la lista se consulta al ejecutar este metodo.
    final legendThreshold = rankedSteps.length * pointsPerLevel;

    if (xp >= legendThreshold) {
      return const RankProgress(
        displayName: 'Leyenda',
        nextRankName: '',
        pointsInCurrentLevel: pointsPerLevel,
        isLegend: true,
        color: Color(0xFFFF5D73),
      );
    }

    final stepIndex = xp ~/ pointsPerLevel;
    final pointsInLevel = xp % pointsPerLevel;
    final currentStep = rankedSteps[stepIndex];
    final nextStep = stepIndex + 1 < rankedSteps.length
        ? rankedSteps[stepIndex + 1].name
        : 'Leyenda';

    return RankProgress(
      displayName: currentStep.name,
      nextRankName: nextStep,
      pointsInCurrentLevel: pointsInLevel,
      isLegend: false,
      color: currentStep.color,
    );
  }
}

class _RankStep {
  const _RankStep(this.name, this.color);

  final String name;
  final Color color;
}
