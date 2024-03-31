import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podcast/models/authentication.dart';
import 'package:podcast/models/userdetail.dart';
import 'package:podcast/screens/deleteCount.dart';
import 'package:podcast/screens/profile.dart';

class UserProfilePage extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var data = snapshot.data!.data() as Map<String, dynamic>?;

                var userProfile = UserProfile(
                  userId: snapshot.data!.id,
                  username: data != null && data.containsKey('username')
                      ? data['username']
                      : getRandomUsername(),
                  email: data != null && data.containsKey('email')
                      ? data['email']
                      : 'No Email',
                  profileImageUrl: data != null &&
                          data.containsKey('profileImageUrl')
                      ? data['profileImageUrl']
                      : 'https://media.istockphoto.com/id/610003972/vector/vector-businessman-black-silhouette-isolated.jpg?s=612x612&w=0&k=20&c=Iu6j0zFZBkswfq8VLVW8XmTLLxTLM63bfvI6uXdkacM=',
                );
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                userProfile.profileImageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userProfile.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userProfile.email,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  userProfile: userProfile,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          // Implement navigation to edit profile page
                        },
                      ),
                      Divider(
                        color: Colors.white,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Settings',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeleteAccountPage(),
                            ),
                          );
                          // Implement navigation to settings page
                        },
                      ),
                      Divider(
                        color: Colors.white,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          _auth.signOut();
                          // Implement logout functionality
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            // User is not logged in, navigate to login page
            return Center(
              child: Text('Please login to view your profile'),
            );
          }
        },
      ),
    );
  }

  String getRandomUsername() {
    List<String> usernames = [
      'John',
      'Alice',
      'Bob',
      'Emma',
      'Michael',
      'Olivia',
      'William',
      'Sophia',
      'James',
      'Charlotte',
    ];
    return usernames[Random().nextInt(usernames.length)];
  }
}
