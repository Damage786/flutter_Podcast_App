import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podcast/screens/loginpage.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Delete Account',style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To delete your account, please enter your password:',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              
              
              style: TextStyle(color: Colors.white),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                fillColor: Colors.black,
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  style: ButtonStyle(
                     minimumSize: MaterialStateProperty.all(Size(
                    double.infinity, 50)), 
                  ),
                    onPressed: () {
                      _deleteAccount(context);
                    },
                    child: Text('Delete My Account'),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Re-authenticate the user to ensure they are the account owner
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Delete the user's account
      await user.delete();

      // Delete the user's data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // Navigate back to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password. Please try again.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  }
}
