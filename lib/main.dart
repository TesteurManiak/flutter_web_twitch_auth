import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

const String clientId = "YOUR_CLIENT_ID";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showUserData = false;
  String _token;

  Future<String> _validateToken() async {
    final response = await http.get(
      Uri.parse('https://id.twitch.tv/oauth2/validate'),
      headers: {'Authorization': 'OAuth $_token'},
    );
    return (jsonDecode(response.body) as Map<String, dynamic>)['login']
        .toString();
  }

  @override
  void initState() {
    super.initState();

    final currentUrl = Uri.base;
    if (!currentUrl.fragment.contains('access_token=')) {
      // You are not connected so redirect to the Twitch authentication page.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        html.window.location.assign(
          'https://id.twitch.tv/oauth2/authorize?response_type=token&client_id=$clientId&redirect_uri=${currentUrl.origin}&scope=viewing_activity_read',
        );
      });
    } else {
      // You are connected, you can grab the code from the url.
      final fragments = currentUrl.fragment.split('&');
      _token = fragments
          .firstWhere((e) => e.startsWith('access_token='))
          .substring('access_token='.length);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => setState(() => _showUserData = true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Twitch web login')),
      body: Center(
        child: _showUserData
            ? FutureBuilder<String>(
                future: _validateToken(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return Container(child: Text('Welcome ${snapshot.data}'));
                },
              )
            : Container(),
      ),
    );
  }
}
