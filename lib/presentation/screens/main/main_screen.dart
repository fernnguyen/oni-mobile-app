import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/locale/app_localizations.dart';
import '../../providers/main/main_notifier.dart';
import '../welcome/welcome_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const MainScreen({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(mainNotifierProvider.notifier).initMainProvider();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoaded = ref.watch(mainNotifierProvider.select((p) => p.isLoaded));
    final isHasInternet = ref.watch(mainNotifierProvider.select((p) => p.isHasInternet));
    final user = ref.watch(mainNotifierProvider.select((p) => p.user));

    // Display RootScreen when data is being load
    if (!isLoaded) {
      return const WelcomeScreen();
    }

    // User data might still null for the first time app open or login without internet connection
    // So, throw error with a first time internet error message then the [ErrorScreen] will be shown
    if (isLoaded && user == null && !isHasInternet) {
      throw Exception(
        'No Internet connection! Internet connection is required for the first time app open or user login',
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.maps_home_work_outlined),
            label: context.loc.navSales,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_customize_outlined),
            label: context.loc.navProducts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_rounded),
            label: context.loc.navTransactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle_outlined),
            label: context.loc.navAccount,
          ),
        ],
        currentIndex: _calculateSelectedIndex(),
        onTap: (int idx) => _onItemTapped(idx),
      ),
    );
  }

  int _calculateSelectedIndex() {
    final String location = widget.location;

    if (location.startsWith('/home')) {
      return 0;
    }

    if (location.startsWith('/products')) {
      return 1;
    }

    if (location.startsWith('/transactions')) {
      return 2;
    }

    if (location.startsWith('/account')) {
      return 3;
    }

    return 0;
  }

  void _onItemTapped(int index) {
    final router = ref.read(appRoutesProvider).router;

    switch (index) {
      case 0:
        router.go('/home');
      case 1:
        router.go('/products');
      case 2:
        router.go('/transactions');
      case 3:
        router.go('/account');
    }
  }
}
