import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PodcastPlayerPage extends StatefulWidget {
  final String imageUrl;
  final String trackName;
  final String artistName;
  final String audioUrl;

  const PodcastPlayerPage({
    required this.imageUrl,
    required this.trackName,
    required this.artistName,
    required this.audioUrl,
  });

  @override
  _PodcastPlayerPageState createState() => _PodcastPlayerPageState();
}

class _PodcastPlayerPageState extends State<PodcastPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

@override
void initState() {
  super.initState();
  _initAudioPlayer();
  _playAudio(widget.audioUrl); // Call _playAudio here
}


  void _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position ?? Duration.zero;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trackName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(150),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.trackName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.artistName,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 30),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (double value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  iconSize: 50,
                  onPressed: () {
                    // Logic to play previous track
                  },
                ),
                IconButton(
                  icon: _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                  iconSize: 70,
                  onPressed: () => _togglePlaying(),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 50,
                  onPressed: () => _togglePlaying(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Update the _playAudio method in PodcastPlayerPage

Future<void> _playAudio(String url) async {
   print('Audio URL from widget: ${widget.audioUrl}');
    if (url.isEmpty) {
    print('Audio URL is empty. Podcast might not have audio.');
    return;
  }
  try {
    if (url.isEmpty) {
      print('Audio URL is empty');
      return;
    }

    print('Attempting to play audio: $url');
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
    print('Audio started playing');
  } catch (e) {
    // Handle any errors that occur during audio playback
    print('Error playing audio: $e');
  }
}



  void _togglePlaying() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _playAudio(widget.audioUrl);
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
