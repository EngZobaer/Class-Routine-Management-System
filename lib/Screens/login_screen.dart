import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Admin_Page/admin_dashboard.dart';
import '../Teacher_page/teacher_dashboard.dart';
import 'registration_screen.dart';
import 'forgot_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';
  bool _isLoading = true; // 🔹 spinner overlay state

  @override
  void initState() {
    super.initState();

    // 🔹 Show spinner for 2 seconds when page opens
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "📌 Mobile number এবং Password দিতে হবে!";
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phone)
          .get();

      if (!doc.exists) {
        setState(() => errorMessage = "⚠️ No account found with this number!");
        return;
      }

      final data = doc.data()!;
      if (data['password'] == password) {
        final role = data['role'];
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminDashboard()),
          );
        } else if (role == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TeacherDashboard()),
          );
        } else {
          setState(() => errorMessage = "❓ কোথাও সমস্যা হয়েছে: $role");
        }
      } else {
        setState(() => errorMessage = "❌ ভূল তথ্য দিয়েছেন!");
      }
    } catch (e) {
      setState(() => errorMessage = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Main UI (always loads)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF2E3191),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: size.width < 600 ? size.width * 0.9 : 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ✅ Logo
                      Image.asset(
                        "lib/images/login_page_Logo.png",
                        height: 100,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 15),

                      // ✅ Madrasa Name
                      Text(
                        "আল জামি‘আতুল আরাবিয়া দারুল হিদায়াহ - পোরশা",
                        style: TextStyle(
                          fontSize: size.width < 600 ? 20 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // ✅ Login Card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Mobile
                              TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  prefixIcon:
                                  const Icon(Icons.phone, color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),

                              // Password
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                  const Icon(Icons.lock, color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),

                              // ✅ Buttons Row
                              Row(
                                children: [
                                  // Login
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E3191),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: _login,
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Register
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFF2E3191)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  RegistrationScreen()),
                                        );
                                      },
                                      child: const Text(
                                        "Register",
                                        style:
                                        TextStyle(color: Color(0xFF2E3191)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Forgot
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFF2E3191)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => ForgotScreen()),
                                        );
                                      },
                                      child: const Text(
                                        "Forgot",
                                        style:
                                        TextStyle(color: Color(0xFF2E3191)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Error Message
                              if (errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ Spinner Overlay (only visible while loading)
          if (_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.4), // transparent overlay
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
