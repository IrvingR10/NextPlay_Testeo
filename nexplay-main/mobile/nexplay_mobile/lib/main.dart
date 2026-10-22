import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/games/games_screen.dart';
import 'features/home/home_screen.dart';
import 'features/login/login_screen.dart';
import 'features/logros/achievement_detail_screen.dart';
import 'features/logros/logros_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile_creation/profile_creation_screen.dart';
import 'features/ranking/ranking_screen.dart';
import 'features/ranking/ranking_user_detail_screen.dart';
import 'features/register/register_screen.dart';
import 'features/retos/challenge_detail_screen.dart';
import 'features/retos/retos_screen.dart';
import 'features/splash/splash_screen.dart';
import 'models/achievement_model.dart';
import 'models/challenge_model.dart';
import 'models/ranking_user_model.dart';

void main() {
  runApp(const NexPlayApp());
}

class NexPlayApp extends StatelessWidget {
  const NexPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXPLAY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.games: (_) => const GamesScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.retos: (_) => const RetosScreen(),
        AppRoutes.logros: (_) => const LogrosScreen(),
        AppRoutes.ranking: (_) => const RankingScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.profileCreation) {
          final arguments = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(
            builder: (_) => ProfileCreationScreen(
              userData: arguments ?? const <String, dynamic>{},
            ),
          );
        }

        if (settings.name == AppRoutes.rankingUserDetail) {
          final arguments = settings.arguments as Map<String, dynamic>?;
          final user = arguments?['user'] as RankingUserModel?;
          final tipo = arguments?['tipo'] as String? ?? 'Global';

          if (user != null) {
            return MaterialPageRoute(
              builder: (_) =>
                  RankingUserDetailScreen(user: user, tipoRanking: tipo),
            );
          }
        }

        if (settings.name == AppRoutes.challengeDetail) {
          final challenge = settings.arguments as ChallengeModel?;

          if (challenge != null) {
            return MaterialPageRoute(
              builder: (_) => ChallengeDetailScreen(challenge: challenge),
            );
          }
        }

        if (settings.name == AppRoutes.achievementDetail) {
          final achievement = settings.arguments as AchievementModel?;

          if (achievement != null) {
            return MaterialPageRoute(
              builder: (_) => AchievementDetailScreen(achievement: achievement),
            );
          }
        }

        return null;
      },
    );
  }
}
