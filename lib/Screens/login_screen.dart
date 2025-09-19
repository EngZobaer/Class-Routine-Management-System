import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart'; // Home screen after login

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String verificationId = '';
  String errorMessage = '';

  // Function to handle phone authentication
  Future<void> _loginWithPhone() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+88${_phoneController.text.trim()}', // Include country code
        verificationCompleted: (PhoneAuthCredential credential) async {
          // If automatic verification is successful, sign in
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            errorMessage = e.message ?? 'Verification failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          // When SMS is sent, store verification ID
          setState(() {
            this.verificationId = verificationId;
          });
          // You can display a prompt to enter the OTP
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  // Function to verify the OTP entered by the user
  Future<void> _verifyOTP(String smsCode) async {
    try {
      // Create a PhoneAuthCredential with the code from the user
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid OTP, try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phone number input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Enter your phone number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithPhone,
              child: Text('Login with Phone'),
            ),
            // Error message if any
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
