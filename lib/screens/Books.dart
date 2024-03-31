import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['volumeInfo']['title'],
      author: json['volumeInfo']['authors'] != null
          ? json['volumeInfo']['authors'].join(', ')
          : 'Unknown',
      description:
          json['volumeInfo']['description'] ?? 'No description available',
    );
  }
}

class BookSearchPage extends StatefulWidget {
  @override
  _BookSearchPageState createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  List<Book> books = [];
  TextEditingController searchController = TextEditingController();

  Future<void> searchBooks(String query) async {
    final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query'));
    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        final bookList = data['items'] as List<dynamic>;
        books = bookList.map<Book>((bookJson) => Book.fromJson(bookJson)).toList();
      });
    } else {
      // Handle error
      print('Failed to search books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Books',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchBooks(searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () async {
  final url = 'https://www.google.com'; // Try launching a different URL
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
},

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

