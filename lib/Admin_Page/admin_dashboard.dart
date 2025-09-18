import 'package:flutter/material.dart';
import '../Screens/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {"title": "Dashboard", "icon": Icons.dashboard},
    {"title": "Teachers", "icon": Icons.person},
    {"title": "Students", "icon": Icons.group},
    {"title": "Class Routine", "icon": Icons.schedule},
    {"title": "Exams", "icon": Icons.assignment},
    {"title": "Settings", "icon": Icons.settings},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      // ✅ Mobile Drawer with background color
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
              child: _buildSidebar(context), // ✅ Sidebar
            ),

          // ✅ Main Area
          Expanded(
            child: Column(
              children: [
                // Top Header
                Container(
                  height: 60,
                  color: Colors.white,
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
                  child: Center(
                    child: Text(
                      "Content for ${_menuItems[_selectedIndex]["title"]}",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // ✅ Bottom Bar
                Container(
                  height: 40,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: Text(
                    "© 2025 Darul Hidayah Admin Panel",
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
        // Sidebar Header
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

        // Sidebar Menu List
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
                  if (Navigator.canPop(context)) Navigator.pop(context); // ✅ Mobile Drawer close
                },
              );
            },
          ),
        ),

        Divider(color: Colors.white54),

        // ✅ Logout Button (Bottom)
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
}
