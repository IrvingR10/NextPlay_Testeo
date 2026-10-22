import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/avatar_model.dart';
import '../../models/category_model.dart';
import '../../models/game_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/avatar_service.dart';
import '../../services/user_service.dart';
import '../game_webview/game_webview_screen.dart';
import '../game_detail/game_detail_screen.dart';

const _playableGameSlugs = <String, String>{
  'spike sprint': 'spike-sprint',
  'pixel racer': 'pixel-racer',
  'neon circuit': 'neon-circuit-racer',
};

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final UserService _userService = UserService();
  final AvatarService _avatarService = AvatarService();
  final TextEditingController _searchController = TextEditingController();

  UserModel? _user;
  AvatarModel? _avatar;

  List<GameModel> _games = [];
  List<CategoryModel> _categories = [];

  int? _selectedCategoryId;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshFilters);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_refreshFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception(
          'No encontramos la sesi\u00F3n del jugador. '
          'Inicia sesi\u00F3n nuevamente.',
        );
      }

      final user = await _userService.getUserById(userId);

      AvatarModel? avatar;

      if (user.idAvatar != null) {
        final avatars = await _avatarService.getAvatars();

        for (final item in avatars) {
          if (item.idAvatar == user.idAvatar) {
            avatar = item;
            break;
          }
        }
      }

      final results = await Future.wait<dynamic>([
        ApiService.getJuegos(),
        ApiService.getCategorias(),
      ]);

      if (!mounted) return;

      setState(() {
        _user = user;
        _avatar = avatar;
        _games = results[0] as List<GameModel>;
        _categories = results[1] as List<CategoryModel>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _refreshFilters() {
    if (mounted) {
      setState(() {});
    }
  }

  List<GameModel> get _filteredGames {
    final query = _searchController.text.trim().toLowerCase();

    return _games.where((game) {
      final matchesCategory =
          _selectedCategoryId == null ||
          game.categorias.any((category) => category.id == _selectedCategoryId);

      final matchesSearch =
          query.isEmpty ||
          game.nombre.toLowerCase().contains(query) ||
          game.descripcion.toLowerCase().contains(query) ||
          game.dificultad.toLowerCase().contains(query) ||
          game.categorias.any(
            (category) => category.nombre.toLowerCase().contains(query),
          );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  GameModel? get _featuredGame {
    if (_games.isEmpty) return null;
    return _games.reduce((first, next) => next.id < first.id ? next : first);
  }

  String? _gameUrl(GameModel game) {
    final slug = _playableGameSlugs[game.nombre.trim().toLowerCase()];
    return slug == null
        ? null
        : '${ApiConstants.baseUrl}/games/$slug/index.html';
  }

  void _openGame(GameModel game) {
    final url = _gameUrl(game);

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este juego todav\u00EDa no tiene una versi\u00F3n jugable integrada.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameWebViewScreen(title: game.nombre, url: url),
      ),
    );
  }

  void _openDetails(GameModel game) {
    final currentUser = _user;
    if (currentUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameDetailScreen(
          game: game,
          user: currentUser,
          avatar: _avatar,
          onPlay: () => _openGame(game),
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _openProfile() {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _comingSoon(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name estar\u00E1 disponible pr\u00F3ximamente.'),
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
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _error != null
            ? _ErrorState(message: _error!, onRetry: _loadData)
            : _CatalogContent(
                user: _user!,
                avatar: _avatar,
                games: _filteredGames,
                featuredGame: _featuredGame,
                totalGames: _games.length,
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                searchController: _searchController,
                onCategorySelected: (id) {
                  setState(() {
                    _selectedCategoryId = id;
                  });
                },
                onRefresh: _loadData,
                onPlay: _openGame,
                onDetail: _openDetails,
                onHome: _goHome,
                onRanking: () => _comingSoon('Ranking'),
                onProfile: _openProfile,
              ),
      ),
    );
  }
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({
    required this.user,
    required this.avatar,
    required this.games,
    required this.featuredGame,
    required this.totalGames,
    required this.categories,
    required this.selectedCategoryId,
    required this.searchController,
    required this.onCategorySelected,
    required this.onRefresh,
    required this.onPlay,
    required this.onDetail,
    required this.onHome,
    required this.onRanking,
    required this.onProfile,
  });

  final UserModel user;
  final AvatarModel? avatar;
  final List<GameModel> games;
  final GameModel? featuredGame;
  final int totalGames;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final TextEditingController searchController;
  final ValueChanged<int?> onCategorySelected;
  final Future<void> Function() onRefresh;
  final ValueChanged<GameModel> onPlay;
  final ValueChanged<GameModel> onDetail;
  final VoidCallback onHome;
  final VoidCallback onRanking;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final nickname = user.apodo?.trim().isNotEmpty == true
        ? user.apodo!.trim()
        : user.nombreCompleto;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding = width < 390 ? 16.0 : 20.0;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(avatar: avatar, nickname: nickname),
                          const SizedBox(height: 26),
                          _TitleBlock(totalGames: totalGames),
                          const SizedBox(height: 22),
                          _SearchField(controller: searchController),
                          const SizedBox(height: 16),
                          _CategoryList(
                            categories: categories,
                            selectedId: selectedCategoryId,
                            onSelected: onCategorySelected,
                          ),
                          const SizedBox(height: 28),
                          const _SectionTitle(
                            icon: Icons.star_rounded,
                            text: 'JUEGO DESTACADO',
                          ),
                          const SizedBox(height: 14),
                          if (featuredGame != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _GameCard(
                                game: featuredGame!,
                                isFeatured: true,
                                onPlay: () => onPlay(featuredGame!),
                                onDetail: () => onDetail(featuredGame!),
                              ),
                            )
                          else
                            const _FeaturedEmptyState(),
                          const SizedBox(height: 14),
                          const _SectionTitle(
                            icon: Icons.sports_esports_rounded,
                            text: 'CAT\u00C1LOGO DE JUEGOS',
                          ),
                          const SizedBox(height: 14),
                          if (games.isEmpty)
                            const _EmptyState()
                          else
                            ...games.map(
                              (game) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _GameCard(
                                  game: game,
                                  onPlay: () => onPlay(game),
                                  onDetail: () => onDetail(game),
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
            _BottomNavigation(
              onHome: onHome,
              onRanking: onRanking,
              onProfile: onProfile,
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.avatar, required this.nickname});

  final AvatarModel? avatar;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatar?.resolvedImageUrl ?? '';

    return Row(
      children: [
        const _NexPlayLogo(),
        const Spacer(),
        Flexible(
          child: Text(
            nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSoft, width: 2),
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
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

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.totalGames});

  final int totalGames;

  @override
  Widget build(BuildContext context) {
    final gameText = totalGames == 1 ? 'JUEGO' : 'JUEGOS';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAT\u00C1LOGO OFICIAL',
                style: TextStyle(
                  color: AppColors.primarySoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'JUEGOS',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: AppColors.secondary,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                '$totalGames $gameText',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primarySoft),
          hintText: 'Buscar por t\u00EDtulo o categor\u00EDa...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            label: 'TODOS',
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          ...categories.map(
            (category) => _CategoryChip(
              label: category.nombre.toUpperCase(),
              selected: selectedId == category.id,
              onTap: () => onSelected(category.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFFFF6558), Color(0xFFFF8A2F)],
                  )
                : null,
            color: selected ? null : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primarySoft, size: 22),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.onPlay,
    required this.onDetail,
    this.isFeatured = false,
  });

  final GameModel game;
  final VoidCallback onPlay;
  final VoidCallback onDetail;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final category = game.categorias.isNotEmpty
        ? game.categorias.map((c) => c.nombre).join(' / ')
        : 'SIN CATEGOR\u00CDA';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFeatured ? AppColors.primary : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: game.imagenUrl != null
                ? Image.network(
                    game.imagenUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _GameImageFallback(),
                  )
                : const _GameImageFallback(),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primarySoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.descripcion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(icon: Icons.speed_rounded, text: game.dificultad),
                    _InfoChip(
                      icon: Icons.person_rounded,
                      text:
                          '${game.maxJugadores} ${game.maxJugadores == 1 ? 'JUGADOR' : 'JUGADORES'}',
                    ),
                    _InfoChip(
                      icon: Icons.bolt_rounded,
                      text: '${game.recompensaXpBase} XP',
                    ),
                    _InfoChip(
                      icon: Icons.monetization_on_rounded,
                      text: '${game.recompensaMonedasBase}',
                    ),
                    _InfoChip(
                      icon: Icons.diamond_rounded,
                      text: '${game.recompensaGemasBase}',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: onDetail,
                    icon: const Icon(Icons.info_outline_rounded),
                    label: const Text(
                      'VER DETALLE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primarySoft,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'JUGAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondary, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.sports_esports_outlined,
            color: AppColors.primary,
            size: 54,
          ),
          SizedBox(height: 16),
          Text(
            'NO HAY JUEGOS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No hay juegos que coincidan con la b\u00FAsqueda o categor\u00EDa seleccionada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedEmptyState extends StatelessWidget {
  const _FeaturedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.sports_esports_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No hay juegos disponibles para destacar.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.onHome,
    required this.onRanking,
    required this.onProfile,
  });

  final VoidCallback onHome;
  final VoidCallback onRanking;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _NavButton(
                icon: Icons.home_filled,
                text: 'INICIO',
                selected: false,
                onTap: onHome,
              ),
            ),
            const Expanded(
              child: _NavButton(
                icon: Icons.sports_esports_rounded,
                text: 'JUEGOS',
                selected: true,
              ),
            ),
            Expanded(
              child: _NavButton(
                icon: Icons.emoji_events_outlined,
                text: 'RANKING',
                selected: false,
                onTap: onRanking,
              ),
            ),
            Expanded(
              child: _NavButton(
                icon: Icons.person_outline_rounded,
                text: 'PERFIL',
                selected: false,
                onTap: onProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.text,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            ).createShader(bounds);
          },
          child: const Text(
            'N',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'NEXPLAY',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
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

class _GameImageFallback extends StatelessWidget {
  const _GameImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSoft,
      child: const Center(
        child: Icon(
          Icons.sports_esports_rounded,
          color: AppColors.primarySoft,
          size: 52,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'NO PUDIMOS CARGAR EL CAT\u00C1LOGO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
