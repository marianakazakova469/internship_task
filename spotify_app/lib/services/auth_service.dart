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
final storage = FlutterSecureStorage();

Future<void> loginWithSpotifyPKCE() async {
  final codeVerifier = generateCodeVerifier();
  final codeChallenge = generateCodeChallenge(codeVerifier);

  final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
    'response_type': 'code',
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'scope': scopes,
    'code_challenge_method': 'S256',
    'code_challenge': codeChallenge,
  });

  final result = await FlutterWebAuth2.authenticate(
    url: authUrl.toString(),
    callbackUrlScheme: 'spotifyapp',
  );

  final code = Uri.parse(result).queryParameters['code'];

  if (code == null) {
    throw Exception('Authorization code not returned');
  }

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

  final tokenData = jsonDecode(tokenResponse.body);
  final accessToken = tokenData['access_token'];
  final refreshToken = tokenData['refresh_token'];

  await storage.write(key: 'access_token', value: accessToken);
  if (refreshToken != null) {
    await storage.write(key: 'refresh_token', value: refreshToken);
  }
}

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

Future<String?> getAccessToken() async {
  return await storage.read(key: 'access_token');
}

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
