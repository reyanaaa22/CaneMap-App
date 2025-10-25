import 'package:flutter/material.dart';
import 'dashboard_models.dart';

class DynamicBottomNav extends StatelessWidget {
  final UserRole role;
  final bool hasField;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DynamicBottomNav({
    super.key,
    required this.role,
    required this.hasField,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = _itemsFor(role, hasField);

    // Responsive: use a rail-like layout on wide screens
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;
    final addIndex = items.indexWhere(
      (item) => (item.label ?? '').toLowerCase() == 'add',
    );
    final hasFloatingAdd = !isWide && addIndex != -1;

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final selected = i == currentIndex;
                return _NavItem(
                  icon: item.icon,
                  label: item.label ?? '',
                  selected: selected,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      );
    }

    final navContainer = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: hasFloatingAdd
            ? const BorderRadius.vertical(top: Radius.circular(28))
            : null,
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 16, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        minimum: EdgeInsets.only(bottom: hasFloatingAdd ? 12 : 6),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: hasFloatingAdd ? 18 : 8,
            vertical: hasFloatingAdd ? 12 : 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == currentIndex;
              if (hasFloatingAdd && i == addIndex) {
                return const Expanded(child: SizedBox());
              }
              return Expanded(
                child: _NavItem(
                  icon: item.icon,
                  label: item.label ?? '',
                  selected: selected,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );

    if (!hasFloatingAdd) return navContainer;

    return SizedBox(
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: navContainer,
          ),
          Positioned(
            bottom: 52,
            child: _FloatingAddButton(
              selected: currentIndex == addIndex,
              onTap: () => onTap(addIndex),
            ),
          ),
        ],
      ),
    );
  }

  List<BottomNavigationBarItem> _itemsFor(UserRole role, bool hasField) {
    switch (role) {
      case UserRole.handler:
        if (!hasField) {
          return const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Add',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ];
        }
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ];
      case UserRole.worker:
        if (!hasField) {
          return const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ];
        }
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ];
      case UserRole.driver:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ];
    }
  }
}

class _FloatingAddButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _FloatingAddButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF2F8F46);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        height: selected ? 72 : 64,
        width: selected ? 72 : 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2F8F46), Color(0xFF3BAA5B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.35),
              blurRadius: 26,
              spreadRadius: 2,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: selected ? 2.5 : 2,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF2F8F46) : Colors.grey.shade400;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF8EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconTheme(
          data: IconThemeData(color: color, size: selected ? 28 : 24),
          child: icon,
        ),
      ),
    );
  }
}
