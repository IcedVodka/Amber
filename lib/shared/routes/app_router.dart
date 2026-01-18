import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/data_manage/views/data_manage_page.dart';
import '../widgets/main_tab_scaffold.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainTabScaffold(),
      ),
      GoRoute(
        path: AppRoutes.dataManage,
        name: 'data-manage',
        builder: (context, state) => const DataManagePage(),
      ),
    ],
  );
});
