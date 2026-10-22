import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/avatar_model.dart';
import '../../models/game_model.dart';
import '../../models/user_model.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({
    super.key,
    required this.game,
    required this.user,
    required this.avatar,
    required this.onPlay,
  });

  final GameModel game;
  final UserModel user;
  final AvatarModel? avatar;
  final VoidCallback onPlay;

  String get _nickname {
    final apodo = user.apodo?.trim() ?? '';
    return apodo.isNotEmpty ? apodo : user.nombreCompleto;
  }

  String get _categories {
    if (game.categorias.isEmpty) {
      return 'SIN CATEGOR\u00CDA';
    }

    return game.categorias
        .map((item) => item.nombre.toUpperCase())
        .join('  /  ');
  }

  int get _difficultyLevel {
    switch (game.dificultad.trim().toUpperCase()) {
      case 'FACIL':
        return 1;
      case 'MEDIA':
        return 2;
      case 'DIFICIL':
        return 3;
      case 'EXPERTO':
        return 4;
      default:
        return 1;
    }
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = avatar?.resolvedImageUrl ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 390 ? 16.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                14,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopHeader(
                        avatarUrl: avatarUrl,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 24),
                      _ActionRow(
                        onBack: () => Navigator.of(context).pop(),
                        onShare: () => _showMessage(
                          context,
                          'Compartir estar\u00E1 disponible pr\u00F3ximamente.',
                        ),
                        onFavorite: () => _showMessage(
                          context,
                          'Favoritos estar\u00E1 disponible pr\u00F3ximamente.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      _HeroCard(game: game, categories: _categories),
                      const SizedBox(height: 18),
                      _StatsRow(game: game, difficultyLevel: _difficultyLevel),
                      const SizedBox(height: 16),
                      _PlayerCard(nickname: _nickname),
                      const SizedBox(height: 16),
                      _RewardsCard(game: game),
                      const SizedBox(height: 24),
                      const _SectionTitle(
                        icon: Icons.emoji_events_outlined,
                        title: 'HITOS DESBLOQUEABLES',
                      ),
                      const SizedBox(height: 12),
                      const _EmptyAchievementCard(),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: onPlay,
                          icon: const Icon(Icons.bolt_rounded, size: 25),
                          label: const Text(
                            'JUGAR AHORA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => _showMessage(
                            context,
                            'No hay clasificaci\u00F3n global disponible todav\u00EDa.',
                          ),
                          icon: const Icon(
                            Icons.bar_chart_rounded,
                            color: AppColors.secondary,
                          ),
                          label: const Text(
                            'Ver Clasificaci\u00F3n Global',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceCard,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.avatarUrl, required this.onBack});

  final String avatarUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 30,
          ),
        ),
        const SizedBox(width: 6),
        const _MiniLogo(),
        const SizedBox(width: 14),
        const Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              'DETALLE JUEGO',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _AvatarFallback(),
                  )
                : const _AvatarFallback(),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onBack,
    required this.onShare,
    required this.onFavorite,
  });

  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          label: const Text(
            'JUEGOS',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceCard,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _RoundButton(icon: Icons.share_outlined, onTap: onShare),
        const SizedBox(width: 10),
        _RoundButton(icon: Icons.favorite_border_rounded, onTap: onFavorite),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.game, required this.categories});

  final GameModel game;
  final String categories;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 0.88,
            child: game.imagenUrl != null
                ? Image.network(
                    game.imagenUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _HeroFallback(),
                  )
                : const _HeroFallback(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    AppColors.background.withValues(alpha: 0.96),
                  ],
                  stops: const [0.25, 0.58, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Badge(text: categories, accent: AppColors.primarySoft),
                    _Badge(
                      text: game.dificultad.toUpperCase(),
                      accent: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(
                  game.nombre.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 31,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  game.descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.game, required this.difficultyLevel});

  final GameModel game;
  final int difficultyLevel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;

        final difficulty = _DifficultyCard(
          difficulty: game.dificultad.toUpperCase(),
          level: difficultyLevel,
        );

        const record = _RecordCard();

        if (narrow) {
          return Column(
            children: [difficulty, const SizedBox(height: 12), record],
          );
        }

        return const Row(children: []);
      },
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.difficulty, required this.level});

  final String difficulty;
  final int level;

  @override
  Widget build(BuildContext context) {
    return _StatShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DIFICULTAD', style: _Styles.label),
          const SizedBox(height: 14),
          Text(difficulty, style: _Styles.bigValue),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Container(
                  height: 7,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index < level
                        ? AppColors.primary
                        : AppColors.backgroundSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard();

  @override
  Widget build(BuildContext context) {
    return const _StatShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('R\u00C9CORD GLOBAL', style: _Styles.label),
          SizedBox(height: 14),
          Text(
            'SIN REGISTRO',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'A\u00FAn no hay puntuaciones registradas',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.nickname});

  final String nickname;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.backgroundSoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primarySoft,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TU MEJOR MARCA', style: _Styles.label),
                SizedBox(height: 5),
                Text(
                  'SIN REGISTRO',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primarySoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sin ranking disponible',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
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

class _RewardsCard extends StatelessWidget {
  const _RewardsCard({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.stars_rounded,
            title: 'Recompensas por Partida',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _RewardTile(
                  icon: Icons.bolt_rounded,
                  value: '+${game.recompensaXpBase} XP',
                  subtitle: 'Experiencia base',
                  color: AppColors.primarySoft,
                ),
                _RewardTile(
                  icon: Icons.monetization_on_rounded,
                  value: '+${game.recompensaMonedasBase} ORO',
                  subtitle: 'Monedas base',
                  color: AppColors.secondary,
                ),
                _RewardTile(
                  icon: Icons.diamond_outlined,
                  value: '+${game.recompensaGemasBase} GEMAS',
                  subtitle: 'Gemas base',
                  color: AppColors.primary,
                ),
              ];

              if (constraints.maxWidth < 420) {
                return Column(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      cards[i],
                      if (i < cards.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                );
              }

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: (constraints.maxWidth - 10) / 2,
                        child: card,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.icon,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
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

class _EmptyAchievementCard extends StatelessWidget {
  const _EmptyAchievementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.secondary,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A\u00FAN NO HAY HITOS CONFIGURADOS',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Los hitos aparecer\u00E1n aqu\u00ED cuando existan datos reales disponibles.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
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

class _StatShell extends StatelessWidget {
  const _StatShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.primarySoft),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primarySoft, size: 22),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniLogo extends StatelessWidget {
  const _MiniLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'NEXPLAY',
      style: TextStyle(
        color: AppColors.secondary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.panelAlt,
      child: const Icon(Icons.person_rounded, color: AppColors.textPrimary),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.sports_esports_rounded,
        size: 70,
        color: AppColors.primarySoft,
      ),
    );
  }
}

class _Styles {
  static const TextStyle label = TextStyle(
    color: AppColors.primarySoft,
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.7,
  );

  static const TextStyle bigValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w900,
  );
}
