import 'package:flutter/material.dart';

class BookReaderPage extends StatelessWidget {
  final String title;
  final String content; // Add content field

  const BookReaderPage({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          content,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
