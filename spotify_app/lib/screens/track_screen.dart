import 'package:flutter/material.dart';
import 'package:spotify_app/services/auth_service.dart';
import 'package:spotify_app/utils/constants.dart';

// A screen to display the detailed info of a chosen track
class TrackScreen extends StatelessWidget {
  final String trackId;

  const TrackScreen({super.key, required this.trackId});

  // Loads the track details
  Future<Map<String, dynamic>> _loadTrack() async {
    return await fetchTrackDetails(trackId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        title: Text('Track Information', style: TextStyle(color: white)),
        backgroundColor: black,
        iconTheme: IconThemeData(color: white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadTrack(),
        builder: (context, snapshot) {
          // This is to indicate that the application is busy and and avoid red screen error
          // https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: white));
          } else if (snapshot.hasError) { // If something goes wrong
            return Center(
              child: Text(
                'Error loading track',
                style: TextStyle(color: white),
              ),
            );
          }

          final track = snapshot.data!;
          final album = track['album'];
          // Since tracks are made by more than one artist sometimes
          // The names must be extracted and joined
          final artistNames = (track['artists'] as List)
              .map((a) => a['name'])
              .join(', ');
          // Convert duration from milliseconds to mm:ss format
          // this is to display the song lenght
          final durationMs = track['duration_ms'] as int;
          final durationMinSec = Duration(milliseconds: durationMs);
          final durationText =
              '${durationMinSec.inMinutes}:${(durationMinSec.inSeconds % 60).toString().padLeft(2, '0')}';

          return Center(
            child: Padding(
              // To ensure the text doesn't reach the ends of the screen
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Show album artwork if available
                  if (album['images']?.isNotEmpty ?? false)
                    Image.network(
                      album['images'][0]['url'],
                      width: 200,
                      height: 200,
                    ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        track['name'],
                        style: TextStyle(
                          color: white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Artist(s): $artistNames',
                        style: TextStyle(color: grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Album: ${album['name']}',
                        style: TextStyle(color: grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Duration: $durationText',
                        style: TextStyle(color: grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
