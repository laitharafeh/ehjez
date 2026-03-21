import 'package:ehjez/providers/providers.dart';
import 'package:ehjez/screens/bookings_screen.dart';
import 'package:ehjez/screens/home_screen.dart';
import 'package:ehjez/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNav extends ConsumerStatefulWidget {
  const BottomNav({super.key});

  @override
  ConsumerState<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends ConsumerState<BottomNav> {
  int _selectedIndex = 0;

  // Pages are created once and never recreated.
  // IndexedStack keeps them all alive in the widget tree so scroll
  // positions, loaded data, and UI state are all preserved.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onGoToSearch: _navigateToSearchWithCategory),
      const SearchScreen(),
      const BookingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    // When the user taps the Search tab directly, reset category to 'All'.
    if (index == 1 && _selectedIndex != 1) {
      ref.read(searchProvider.notifier).setCategory('All');
    }
    setState(() => _selectedIndex = index);
  }

  // Called by HomeScreen category buttons.
  // Updates the search provider (so SearchScreen reacts) then switches tabs.
  void _navigateToSearchWithCategory(String category) {
    ref.read(searchProvider.notifier).setCategory(category);
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack renders all children but shows only the selected one.
      // This means screens are never destroyed — no re-fetching on tab switch.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAF8F5),
          boxShadow: [
            BoxShadow(
              color: Color(0x26B0A090), // warm-tinted shadow, ~15% opacity
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFFAF8F5),
          elevation: 0, // shadow comes from the Container, not Flutter's default
          iconSize: 22,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF068631),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Bookings'),
          ],
        ),
      ),
    );
  }
}
