import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_app/utils/pkce_util.dart';


// This is my personal cliendID which I got from the Spotify dashboard
// https://developer.spotify.com/dashboard
const clientId = '415d448cfaa446d3ac5d1cc5c58941a9';
// Personalised redirectUri
const redirectUri = 'spotifyapp://callback';
const scopes = 'user-read-private user-read-email';
final storage = FlutterSecureStorage(); // place to store access and refresh tokens

Future<void> loginWithSpotifyPKCE() async {
  // Generate the PKCE code verifier and code challenge as stated here 
  // https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow
  final codeVerifier = generateCodeVerifier();
  final codeChallenge = generateCodeChallenge(codeVerifier);

  // Build the auth url
  // https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow#request-user-authorization
  final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
    'response_type': 'code',
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'scope': scopes,
    'code_challenge_method': 'S256',
    'code_challenge': codeChallenge,
  });

  // Open the url and wait for the auth to be completed
  final result = await FlutterWebAuth2.authenticate(
    url: authUrl.toString(),
    callbackUrlScheme: 'spotifyapp',
  );

  /// Extract the authorization code from the redirect result
  final code = Uri.parse(result).queryParameters['code'];

  if (code == null) {
    throw Exception('Authorization code not returned');
  }

  // Exchange the auth code for an access token
  // https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow#request-an-access-token
  final tokenResponse = await http.post(
    Uri.parse('https://accounts.spotify.com/api/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'client_id': clientId,
      'code_verifier': codeVerifier,
    },
  );

  if (tokenResponse.statusCode != 200) {
    throw Exception('Failed to get access token: ${tokenResponse.body}');
  }

  // Decode and store the access and refresh tokens
  final tokenData = jsonDecode(tokenResponse.body);
  final accessToken = tokenData['access_token'];
  final refreshToken = tokenData['refresh_token'];

  await storage.write(key: 'access_token', value: accessToken);
  if (refreshToken != null) {
    await storage.write(key: 'refresh_token', value: refreshToken);
  }
}

// Refreshes the acces s token
Future<void> refreshAccessToken() async {
  final refreshToken = await storage.read(key: 'refresh_token');

  final response = await http.post(
    Uri.parse('https://accounts.spotify.com/api/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken!,
      'client_id': clientId,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await storage.write(key: 'access_token', value: data['access_token']);
  } else {
    throw Exception('Failed to refresh token: ${response.body}');
  }
}

// Gets the current access token from storage
Future<String?> getAccessToken() async {
  return await storage.read(key: 'access_token');
}

// Fetches the authorized users profile
Future<Map<String, dynamic>> getUserProfile() async {
  final token = await storage.read(key: 'access_token');

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load profile');
  }
}

// Fetching playlists
// https://developer.spotify.com/documentation/web-api/reference/get-a-list-of-current-users-playlists
Future<Map<String, dynamic>> fetchUserPlaylists(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/me/playlists'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load playlists');
  }
}

// Fetch information about a specific playlist
// https://developer.spotify.com/documentation/web-api/reference/get-playlist
Future<Map<String, dynamic>> fetchPlaylistDetails(String playlistId) async {
  // Check the access token before loading playlist
  final accessToken = await storage.read(key: 'access_token');

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/playlists/$playlistId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load playlist details: ${response.body}');
  }
}

// Fetch information about a specific track from one of the playlists
Future<Map<String, dynamic>> fetchTrackDetails(String trackId) async {
  // Check the access token before loading playlist
  final accessToken = await storage.read(key: 'access_token');

  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load track details: ${response.body}');
  }
}