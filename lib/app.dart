import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/config/theme_config.dart';
import 'package:flutter_rest_api/features/auth/presentation/login_screen.dart';
import 'package:flutter_rest_api/features/auth/providers/auth_provider.dart';
import 'package:flutter_rest_api/features/media/presentation/download_demo_screen.dart';
import 'package:flutter_rest_api/features/media/presentation/upload_demo_screen.dart';
import 'package:flutter_rest_api/features/pagination/presentation/pagination_demo_screen.dart';
import 'package:flutter_rest_api/features/theme/providers/theme_provider.dart';
import 'package:flutter_rest_api/features/users/presentation/user_list_screen.dart';

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    UserListScreen(),
    UploadDemoScreen(),
    DownloadDemoScreen(),
    PaginationDemoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Flutter REST API Example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.isAuthenticated
          ? Scaffold(
              appBar: AppBar(
                title: const Text('Flutter REST API Architecture'),
                actions: [
                  IconButton(
                    icon: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    tooltip: 'Toggle Theme Mode',
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Logout',
                    onPressed: () {
                      ref.read(authStateProvider.notifier).logout();
                    },
                  ),
                ],
              ),
              body: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people),
                    label: 'Users',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud_upload_outlined),
                    selectedIcon: Icon(Icons.cloud_upload),
                    label: 'Upload',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.cloud_download_outlined),
                    selectedIcon: Icon(Icons.cloud_download),
                    label: 'Download',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.numbers_outlined),
                    selectedIcon: Icon(Icons.numbers),
                    label: 'Pagination',
                  ),
                ],
              ),
            )
          : const LoginScreen(),
    );
  }
}
