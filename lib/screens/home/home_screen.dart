import 'package:flutter/material.dart';
import 'package:clothes_app/screens/shop/shop_screen.dart';
import 'package:clothes_app/screens/cart/cart_screen.dart';
import 'package:clothes_app/screens/profile/profile_screen.dart';
import 'package:clothes_app/screens/add/add_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    ShopScreen(userId: widget.userId),
    CartScreen(userId: widget.userId),
    AddScreen(),
    ProfileScreen(userId: widget.userId),
  ];

  static const _navItems = [
    (icon: Icons.home_outlined,      activeIcon: Icons.home_rounded,         label: 'Accueil'),
    (icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Panier'),
    (icon: Icons.add_circle_outline, activeIcon: Icons.add_circle_rounded,   label: 'Ajouter'),
    (icon: Icons.person_outline,     activeIcon: Icons.person_rounded,       label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = _currentIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 16 : 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          color: selected ? Colors.white : const Color(0xFFAAAAAA),
                          size: 22,
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
