import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

final _authorizationEndpoint = Uri.parse(
  'https://github.com/login/oauth/authorize',
);
final _tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

class GithubLoginWidget extends StatefulWidget {
  const GithubLoginWidget({
    required this.builder,
    required this.githubClientId,
    required this.githubClientSecret,
    required this.githubScopes,
    super.key,
  });

  final Widget Function(BuildContext context, oauth2.Client client) builder;
  final String githubClientId;
  final String githubClientSecret;
  final List<String> githubScopes;

  @override
  State<GithubLoginWidget> createState() => _GithubLoginState();
}

class _GithubLoginState extends State<GithubLoginWidget> {
  HttpServer? _redirectServer;
  oauth2.Client? _client;

  @override
  Widget build(BuildContext context) {
    if (_client != null) {
      return widget.builder(context, _client!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('GitHub Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _login,
          child: const Text('Login to GitHub'),
        ),
      ),
    );
  }

  Future<void> _login() async {
    await _redirectServer?.close();
    _redirectServer = await HttpServer.bind('localhost', 0);
    final redirectUrl = Uri.parse(
      'http://localhost:${_redirectServer!.port}/auth',
    );
    final client = await _getOAuth2Client(redirectUrl);
    setState(() => _client = client);
  }

  Future<oauth2.Client> _getOAuth2Client(Uri redirectUrl) async {
    final grant = oauth2.AuthorizationCodeGrant(
      widget.githubClientId,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: widget.githubClientSecret,
      httpClient: _JsonAcceptingHttpClient(),
    );

    final authorizationUrl = grant.getAuthorizationUrl(
      redirectUrl,
      scopes: widget.githubScopes,
    );
    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl);
    } else {
      throw Exception('Could not launch $authorizationUrl');
    }

    final request = await _redirectServer!.first;
    final params = request.uri.queryParameters;
    request.response
      ..statusCode = 200
      ..headers.set('content-type', 'text/plain')
      ..write('Authenticated! You can close this tab.');
    await request.response.close();
    await _redirectServer!.close();
    _redirectServer = null;

    return grant.handleAuthorizationResponse(params);
  }
}

class _JsonAcceptingHttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return _httpClient.send(request);
  }
}
