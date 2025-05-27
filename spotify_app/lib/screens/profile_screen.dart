import 'package:flutter/material.dart';
import 'package:spotify_app/utils/constants.dart';

// Used this site to help with what I can display on the page https://developer.spotify.com/documentation/web-api/howtos/web-app-profile

class ProfileScreen extends StatelessWidget {
  final Future<Map<String, dynamic>> profileFuture;
  final Future<Map<String, dynamic>> playlistsFuture;

  const ProfileScreen({
    super.key,
    required this.profileFuture,
    required this.playlistsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(" ")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text("Error: ${profileSnapshot.error}"));
          }

          final profile = profileSnapshot.data!;

          return FutureBuilder<Map<String, dynamic>>(
            future: playlistsFuture,
            builder: (context, playlistsSnapshot) {
              if (playlistsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (playlistsSnapshot.hasError) {
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
