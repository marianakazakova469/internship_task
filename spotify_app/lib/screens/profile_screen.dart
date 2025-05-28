import 'package:flutter/material.dart';
import 'package:spotify_app/screens/playlist_screen.dart';
import 'package:spotify_app/services/auth_service.dart';
import 'package:spotify_app/utils/constants.dart';

// Used this site to help with what I can display on the page https://developer.spotify.com/documentation/web-api/howtos/web-app-profile
// A screen to display the profile of
// the logged in user and their playlists
class ProfileScreen extends StatelessWidget {
  final Future<Map<String, dynamic>> profileFuture; // load user profile data
  final Future<Map<String, dynamic>> playlistsFuture; // load user;s playlists

  const ProfileScreen({
    super.key,
    required this.profileFuture,
    required this.playlistsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" "),
        backgroundColor: black,
        iconTheme: IconThemeData(color: white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: profileFuture,
        // This is to indicate that the application is busy and and avoid red screen error
        // https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text("Error: ${profileSnapshot.error}"));
          }

          final profile = profileSnapshot.data!;

          return FutureBuilder<Map<String, dynamic>>(
            future: playlistsFuture,
            // This is to indicate that the application is busy and and avoid red screen error
            // https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html
            builder: (context, playlistsSnapshot) {
              if (playlistsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (playlistsSnapshot.hasError) { // If something goes wrong
                return Center(child: Text("Error: ${playlistsSnapshot.error}"));
              }

              final playlists = playlistsSnapshot.data!['items'] as List;

              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      if (profile['images'].isNotEmpty)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            profile['images'][0]['url'],
                          ),
                        ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile['display_name'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 24,
                              color: white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "${profile['followers']['total']} follower · ",
                                style: TextStyle(fontSize: 16, color: grey),
                              ),
                              Text(
                                "From ${profile['country']}",
                                style: TextStyle(fontSize: 16, color: grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Playlists",
                    style: TextStyle(fontSize: 22, color: white),
                  ),
                  ...playlists.map((playlist) {
                    return ListTile(
                      onTap: () async {
                        // Load full playlist details on tap
                        final fullPlaylist = await fetchPlaylistDetails(
                          playlist['id'],
                        );
                        print(fullPlaylist);

                        // Go to the PlaylistScreen with the fetched data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PlaylistScreen(playlist: fullPlaylist),
                          ),
                        );
                      },
                      leading:
                          playlist['images'].isNotEmpty
                              ? Image.network(
                                playlist['images'][0]['url'],
                                width: 50,
                                height: 50,
                              )
                              : Icon(Icons.music_note, color: white),
                      title: Text(
                        playlist['name'],
                        style: TextStyle(color: white),
                      ),
                      subtitle: Text(
                        "${playlist['tracks']['total']} tracks",
                        style: TextStyle(color: grey),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
