import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podcast/models/userdetail.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No data found'),
            );
          }
          var userProfile = UserProfile(
            userId: FirebaseAuth.instance.currentUser!.uid,
            username: snapshot.data!.get('username') ?? 'No Username',
            email: snapshot.data!.get('email'),
            profileImageUrl: snapshot.data!.get('profileImageUrl') ??
                'assets/profile_picture.png',
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userProfile.profileImageUrl),
              ),
              SizedBox(height: 20),
              Text(
                userProfile.username,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                userProfile.email,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfilePage(userProfile: userProfile),
                    ),
                  );
                },
                child: Text('Edit Profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  EditProfilePage({required this.userProfile});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late String _profileImageUrl;

  File? _imageFile;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userProfile.username);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _profileImageUrl = widget.userProfile.profileImageUrl;
  }

  Future<void> _updateProfile(BuildContext context) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      String? newProfileImageUrl;

      if (_imageFile != null) {
        newProfileImageUrl = await uploadImageToFirebase(_imageFile!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userProfile.userId)
          .update({
        'username': _usernameController.text,
        'email': _emailController.text,
        'profileImageUrl': newProfileImageUrl ?? _profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
      print('Error updating profile: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference =
        FirebaseStorage.instance.ref().child('profile_images').child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _getImageFromGallery,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider<Object>?
                          : NetworkImage(_profileImageUrl),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                          color: Colors.white), // Set text color to white
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                            color:
                                Colors.white), // Set label text color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white), // Set border color to white
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Set focused border color to white
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(
                          color: Colors.white), // Set text color to white
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color:
                                Colors.white), // Set label text color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white), // Set border color to white
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Set focused border color to white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all(Size(double.infinity, 50)),
                      animationDuration: const Duration(milliseconds: 500),
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 200, 191, 191),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    onPressed:
                        _isUpdating ? null : () => _updateProfile(context),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                        if (_isUpdating)
                          Positioned(
                            right: 12,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}