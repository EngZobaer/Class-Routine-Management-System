import 'package:flutter/material.dart';
import 'login_screen.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _phoneController = TextEditingController();
  String errorMessage = '';

  void _sendOtp() {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        errorMessage = "মোবাইল নম্বর দিতে হবে!";
      });
      return;
    }

    // TODO: এখানে Firebase/Backend দিয়ে OTP পাঠাতে হবে
    setState(() {
      errorMessage = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("OTP sent to $phone")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Color(0xFF2E3191)),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isMobile ? size.width * 0.9 : 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    "lib/images/login_page_Logo.png",
                    height: 100,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 15),

                  // Madrasa Name
                  Text(
                    "Darul Hidayah-Porsha",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Forgot Password Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Mobile Number Input
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number (+88)',
                              prefixIcon: Icon(Icons.phone, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 20),

                          // Send OTP Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2E3191),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _sendOtp,
                              child: Text(
                                "Send OTP",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),

                          SizedBox(height: 12),

                          // ✅ Already have an account button (always visible)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xFF2E3191)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginScreen()),
                                );
                              },
                              child: Text(
                                "Already have an account? Login",
                                style: TextStyle(color: Color(0xFF2E3191)),
                              ),
                            ),
                          ),

                          if (errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: Colors.red),
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
    );
  }
}
