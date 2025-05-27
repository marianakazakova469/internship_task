import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// Looked how to do it on https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow#code-challenge

String generateCodeVerifier() {
  final rand = Random.secure();
  final codeVerifier = List<int>.generate(64, (_) => rand.nextInt(256));
  return base64UrlEncode(codeVerifier).replaceAll('=', '');
}

String generateCodeChallenge(String codeVerifier) {
  final bytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}
