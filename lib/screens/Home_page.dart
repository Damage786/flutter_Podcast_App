import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PodcastScreen extends StatefulWidget {
  @override
  _PodcastScreenState createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  List<dynamic> podcasts = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  Future<void> fetchPodcasts(String searchTerm) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String encodedSearchTerm = Uri.encodeComponent(searchTerm);
      final response = await http.get(Uri.parse(
          'https://itunes.apple.com/search?term=$encodedSearchTerm&media=podcast'));

      if (response.statusCode == 200) {
        setState(() {
          podcasts = json.decode(response.body)['results'];
        });
      } else {
        print('Failed to load podcasts. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Display an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load podcasts. Please try again later.'),
        ));
      }
    } catch (e) {
      print('Error fetching podcasts: $e');
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An unexpected error occurred. Please try again later.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch all podcasts initially
    fetchPodcasts('horror');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Podcasts',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              autocorrect: true,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusColor: Colors.blue,
                fillColor: Colors.black,
                hintText: 'Search your podcast',
                hintStyle: TextStyle(color: Colors.grey), // Hint text color
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    fetchPodcasts('');
                  },
                ),
              ),
              onChanged: (value) {
                fetchPodcasts(value);
              },
            ),
          ),
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: podcasts.length,
                    itemBuilder: (context, index) {
                      final podcast = podcasts[index];
                      return ListTile(
                        leading: Image.network(podcast['artworkUrl60'] ??
                            ''), // Use a placeholder if artwork URL is null
                        title: Text(
                          podcast['trackName'] ?? '',
                          style: TextStyle(color: Colors.white), // Text color
                        ),
                        subtitle: Text(
                          podcast['artistName'] ?? '',
                          style: TextStyle(color: Colors.white), // Text color
                        ),
                        // Update the onTap method in PodcastScreen
                        onTap: () {
                          final trackName = podcast['trackName'] ?? '';
                          final artistName = podcast['artistName'] ?? '';
                          final searchTerm = Uri.encodeComponent(
                              '$trackName $artistName podcast');
                          final youtubeUrl =
                              'https://www.youtube.com/results?search_query=$searchTerm';

                          // Launch the YouTube URL
                          launch(youtubeUrl);
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
