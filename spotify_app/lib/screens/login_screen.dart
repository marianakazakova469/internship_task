import 'package:flutter/material.dart';
import 'package:spotify_app/screens/profile_screen.dart';
import 'package:spotify_app/services/auth_service.dart';
import 'package:spotify_app/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: black, useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spotify Logo
                Image.asset(
                  'assets/images/Primary_Logo_White_CMYK.png',
                  width: 70,
                  height: 70,
                ),
                SizedBox(height: 20),

                // Tagline text
                Text(
                  "Millions of songs. Free on Spotify.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: green),
                  onPressed: () async {
                    await loginWithSpotifyPKCE();
                    final accessToken = await getAccessToken();

                    if (accessToken == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Login failed: No access token"),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProfileScreen(
                              profileFuture: getUserProfile(),
                              playlistsFuture: fetchUserPlaylists(accessToken),
                            ),
                      ),
                    );
                  },

                  child: Text(
                    "Login with Spotify",
                    style: TextStyle(color: white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
