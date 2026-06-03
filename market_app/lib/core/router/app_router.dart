import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/order/checkout_screen.dart';
import '../../screens/order/order_detail_screen.dart';
import '../../screens/order/orders_screen.dart';
import '../../screens/product/product_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    final protectedRoutes = ['/cart', '/checkout', '/orders'];
    final isProtected = protectedRoutes.any((r) => state.matchedLocation.startsWith(r));
    if (isProtected && !isLoggedIn) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/',                    builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/login',               builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register',            builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/products/:slug',      builder: (_, s) => ProductDetailScreen(slug: s.pathParameters['slug']!)),
    GoRoute(path: '/cart',                builder: (_, __) => const CartScreen()),
    GoRoute(path: '/checkout',            builder: (_, __) => const CheckoutScreen()),
    GoRoute(path: '/orders',              builder: (_, __) => const OrdersScreen()),
    GoRoute(path: '/orders/:id',          builder: (_, s) => OrderDetailScreen(orderId: int.parse(s.pathParameters['id']!))),
  ],
);
