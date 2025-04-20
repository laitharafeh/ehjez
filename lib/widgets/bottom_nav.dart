import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/bookings_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomeScreen(onGoToSearch: _goToSearchScreen), // Pass the callback
      const SearchScreen(selectedCategory: 'All'),
      const BookingsScreen(),
      // ProfileScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Reset SearchScreen to 'All' when navigating via bottom nav
      setState(() {
        _pages[1] = const SearchScreen(selectedCategory: 'All');
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to navigate to the SearchScreen
  void _goToSearchScreen(String category) {
    _onItemTapped(1); // Navigate to the Search Screen (index 1)
    // Pass the category to the SearchScreen
    setState(() {
      _pages[1] = SearchScreen(
          selectedCategory:
              category); // Update the SearchScreen with the new category
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
