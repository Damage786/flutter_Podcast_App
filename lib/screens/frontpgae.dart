import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HighPopularityPodcastScreen extends StatefulWidget {
  @override
  _HighPopularityPodcastScreenState createState() =>
      _HighPopularityPodcastScreenState();
}

class _HighPopularityPodcastScreenState
    extends State<HighPopularityPodcastScreen> {
  List<dynamic> podcasts = [];
  bool _isLoading = false;

  Future<void> fetchPopularPodcasts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
          Uri.parse('https://itunes.apple.com/us/rss/toppodcasts/limit=10/json'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          podcasts = jsonData['feed']['entry'];
          podcasts.shuffle(); // Shuffle the list of podcasts
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
    // Fetch popular podcasts initially
    fetchPopularPodcasts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Popular Podcasts',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black, // Dark background color
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Recommended for You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: min(podcasts.length, 10),
                    itemBuilder: (context, index) {
                      final podcast = podcasts[index];
                      return GestureDetector(
                        onTap: () {
                          final trackName = podcast['im:name']['label'] ?? '';
                          final artistName =
                              podcast['im:artist']['label'] ?? '';
                          final searchTerm = Uri.encodeComponent(
                              '$trackName $artistName podcast');
                          final youtubeUrl =
                              'https://www.youtube.com/results?search_query=$searchTerm';

                          // Launch the YouTube URL
                          launch(youtubeUrl);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              podcast['im:image'][0]['label'],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'All Podcasts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
         Expanded(
  child: ListView.builder(
    itemCount: podcasts.length,
    itemBuilder: (context, index) {
      final podcast = podcasts[index];
      return ListTile(
        onTap: () {
          final trackName = podcast['im:name']['label'] ?? '';
          final artistName = podcast['im:artist']['label'] ?? '';
          final searchTerm = Uri.encodeComponent('$trackName $artistName podcast');
          final youtubeUrl = 'https://www.youtube.com/results?search_query=$searchTerm';

          // Launch the YouTube URL
          launch(youtubeUrl);
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(podcast['im:image'][0]['label']),
        ),
        title: Text(
          podcast['im:name']['label'],
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          podcast['category']['attributes']['label'],
          style: const TextStyle(color: Colors.grey),
        ),
      );
    },
  ),
),

        ],
      ),
    );
  }

  Future<void> _launchPodcast(dynamic podcast) async {
    final url = podcast['link'][0]['attributes']['href'];
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

