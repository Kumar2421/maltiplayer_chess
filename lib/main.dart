import 'package:chess/server/MatchmakingScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchmakingService()),
        // Add other providers if needed
      ],
      child: MyApp(),
    ),
  );
}


void callServerFunction() async {
  final uri = Uri.parse('http://localhost:3000');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    print('Server response: ${response.body}');
  } else {
    print('Failed to connect to the server. Status code: ${response.statusCode}');
  }
}
