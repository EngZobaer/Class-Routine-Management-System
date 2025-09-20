import 'package:flutter/material.dart';
import '../Left_Menu/Dashboard.dart';
import '../Left_Menu/Days.dart';
import '../Left_Menu/settings.dart';
import '../Screens/login_screen.dart';
import '../Left_Menu/Shift.dart';    // 🔹 Shift Page
import '../Left_Menu/classes.dart'; // 🔹 Class Page
import '../Left_Menu/Books.dart';   // 🔹 Books Page
import '../Left_Menu/Teacher.dart'; // 🔹 Teacher Page
import '../Left_Menu/assign_class_routing.dart'; // 🔹 Assign Class Routine Page

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {"title": "Dashboard", "icon": Icons.dashboard},
    {"title": "Shift", "icon": Icons.settings_system_daydream },
    {"title": "Teachers", "icon": Icons.person},
    {"title": "Classes", "icon": Icons.class_},
    {"title": "Assign Class Routine", "icon": Icons.schedule},
    {"title": "Days", "icon": Icons.calendar_today}, // ✅ নতুন যোগ
    {"title": "Books", "icon": Icons.menu_book},
    {"title": "Settings", "icon": Icons.settings},
  ];


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isMobile
          ? Drawer(
        child: Container(
          color: Color(0xFF2E3191),
          child: _buildSidebar(context),
        ),
      )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 220,
              color: Color(0xFF2E3191),
              child: _buildSidebar(context),
            ),

          // ✅ Main Area
          Expanded(
            child: Column(
              children: [
                // 🔹 Header Section
                Container(
                  height: 60,
                  color: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isMobile)
                            Builder(
                              builder: (context) => IconButton(
                                icon: Icon(Icons.menu, color: Colors.black),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                            ),
                          Text(
                            _menuItems[_selectedIndex]["title"],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.notifications, color: Colors.black),
                          SizedBox(width: 16),
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ✅ Body Content
                Expanded(
                  child: _getSelectedPage(),
                ),

                // 🔹 Bottom Bar
                Container(
                  height: 40,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text("© ${DateTime.now().year} All Rights Reserved || Darul Hidayah" ,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Sidebar Widget
  Widget _buildSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            "Menus",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(color: Colors.white54),

        Expanded(
          child: ListView.builder(
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return ListTile(
                leading: Icon(item["icon"], color: Colors.white),
                title: Text(
                  item["title"],
                  style: TextStyle(color: Colors.white),
                ),
                selected: _selectedIndex == index,
                selectedTileColor: Colors.blueAccent,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              );
            },
          ),
        ),
        Divider(color: Colors.white54),

        ListTile(
          leading: Icon(Icons.logout, color: Colors.white),
          title: Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          },
        ),
      ],
    );
  }

  // ✅ Body Content Switcher
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return TeacherRoutineDashboard();
      case 1:
        return ShiftPage();
      case 2:
        return TeacherPage();
      case 3:
        return ClassPage();
      case 4:
        return AssignClassRoutinePage();
      case 5:
        return DaysPage(); // ✅ নতুন Days Page
      case 6:
        return BooksPage();
      case 7:
        return SettingsPage();
      default:
        return Center(
          child: Text(
            "Content for ${_menuItems[_selectedIndex]["title"]}",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

}
