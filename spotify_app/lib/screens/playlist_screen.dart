import 'package:flutter/material.dart';
import 'package:spotify_app/screens/track_screen.dart';
import 'package:spotify_app/utils/constants.dart';

// A screen to display the details of the chosen playlist
// including track list
class PlaylistScreen extends StatelessWidget {
  final Map<String, dynamic> playlist;

  const PlaylistScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    // Extract the track items from the playlist
    final tracks = playlist['tracks']['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Display the name of the playlist which is opened
          playlist['name'] ?? 'Playlist',
          style: TextStyle(color: white),
        ),
        backgroundColor: black,
        iconTheme: IconThemeData(color: white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (playlist['images']?.isNotEmpty ?? false)
            Center(
              child: Image.network(
                playlist['images'][0]['url'],
                width: 200,
                height: 200,
              ),
            ),
          SizedBox(height: 20),
          Text(
            'Tracks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          SizedBox(height: 10),
          // Loop through all track items on the playlis t and display them in a ListTile
          ...tracks.map<Widget>((trackItem) {
            final track = trackItem['track'];
            return ListTile(
              leading:
                  track['album']?['images']?.isNotEmpty == true
                      ? Image.network(
                        track['album']['images'][0]['url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                      : Icon(Icons.music_note, color: white),
              title: Text(track['name'], style: TextStyle(color: white)),
              subtitle: Text(
                // Join multiple artist names and seperating them with a coma
                track['artists'].map((a) => a['name']).join(', '),
                style: TextStyle(color: grey),
              ),
              // Navigate to the TrackScreen passing the track id
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrackScreen(trackId: track['id']),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
