# flutter_web_twitch_auth

A Flutter Web project to illustrate OAuth2 authentication flow using Twitch's API.

The project on this branch is using an external popup window to manage the login with Twitch.

## Getting Started

To grab the response code in the callback URL I've added a `static.html` page in the `web/` folder. Its purpose is to send a message containing the URL with the access token to the parent window which would be the initial window of the Flutter application.

```html
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>Connexion Succeeded</title>
    <meta name="description"
        content="Simple, quick, standalone responsive placeholder without any additional resources">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>

<body>
</body>
<script>
    window.opener.postMessage(window.location.href, '*');
</script>

</html>
```

As for the Flutter code I've added a listener for incoming message to trigger the login when received a correct response.

```dart
// Listen to message send with `postMessage`.
html.window.onMessage.listen((event) {
  // The event contains the token which means the user is connected.
  if (event.data.toString().contains('access_token=')) {
    _login(event.data);
  }
});
```

Also opening the login page in an external window and using our `static.html` page as the redirect_uri.

```dart
// Open the Twitch authentication page.
WidgetsBinding.instance.addPostFrameCallback((_) {
  final currentUri = Uri.base;
  final redirectUri = Uri(
    host: currentUri.host,
    scheme: currentUri.scheme,
    port: currentUri.port,
    path: '/static.html',
  );
  final authUrl =
    'https://id.twitch.tv/oauth2/authorize?response_type=token&client_id=$clientId&redirect_uri=$redirectUri&scope=viewing_activity_read';
  
  // Keeping a reference to the popup window so you can close it after login is completed
  _popupWin = html.window.open(
    authUrl, "Twitch Auth", "width=800, height=900, scrollbars=yes");
});
```
