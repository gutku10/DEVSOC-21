import 'package:AppU/Screens/dashboard_Screen.dart';
import 'package:AppU/Screens/new_trip_screen.dart';
import 'package:AppU/Screens/ongoin_trip_screen.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  TabsScreen({
    Key key,
  }) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, dynamic>> pages;

  int selectedPageIndex = 0;

  @override
  void initState() {
    pages = [
      {'page': DashboardScreen(), 'title': 'Sathi'},
      {'page': OngoingTripScreen(), 'title': 'Ongoing Trip'},
      {
        'page': NewTripScreen(changePageCallback: _changePageCallback),
        'title': 'New Trip'
      },
    ];

    super.initState();
  }

  void _changePageCallback(int pageNumber) {
    _changePage(pageNumber);
  }

  void _changePage(index) => setState(() {
        selectedPageIndex = index;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: MainDrawer(),
      body: pages[selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _changePage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white54,
        currentIndex: selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Ongoing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New Trip',
          ),
        ],
      ),
    );
  }
}
