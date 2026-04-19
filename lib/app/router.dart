import 'package:go_router/go_router.dart';

import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/category/category_screen.dart';
import '../presentation/screens/item_detail/item_detail_screen.dart';
import '../presentation/screens/item_form/item_form_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) => CategoryScreen(
        categoryId: state.pathParameters['id']!,
        categoryName: 'Категория ${state.pathParameters['id']}',
      ),
    ),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) =>
          ItemDetailScreen(itemId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/item/new',
      builder: (context, state) => const ItemFormScreen(),
    ),
    GoRoute(
      path: '/item/:id/edit',
      builder: (context, state) =>
          ItemFormScreen(itemId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) =>
          SearchScreen(query: state.uri.queryParameters['q']),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
