import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';

import '../../screens/home/home_screen.dart';
import '../../screens/order/checkout_screen.dart';
import '../../screens/order/order_detail_screen.dart';
import '../../screens/order/orders_screen.dart';
import '../../screens/product/product_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    final protectedRoutes = ['/checkout', '/orders'];
    final isProtected = protectedRoutes.any((r) => state.matchedLocation.startsWith(r));
    if (isProtected && !isLoggedIn) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/',                    builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/login',               builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register',            builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/products/:id',        builder: (_, s) => ProductDetailScreen(id: s.pathParameters['id']!)),

    GoRoute(path: '/checkout',            builder: (_, s) {
      final extra = s.extra as Map<String, dynamic>? ?? {};
      return CheckoutScreen(
        product: extra['product'],
        rental: extra['rental'],
        startDate: extra['startDate'],
        endDate: extra['endDate'],
        days: extra['days'] ?? 0,
        totalPrice: extra['totalPrice'] ?? 0.0,
      );
    }),
    GoRoute(path: '/orders',              builder: (_, __) => const OrdersScreen()),
    GoRoute(path: '/orders/:id',          builder: (_, s) => OrderDetailScreen(orderId: int.parse(s.pathParameters['id']!))),
  ],
);
