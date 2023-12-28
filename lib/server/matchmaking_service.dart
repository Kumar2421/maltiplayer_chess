// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:provider/provider.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// class MatchmakingService with ChangeNotifier {
//   late WebSocketChannel channel;
//   final TextEditingController playerNameController = TextEditingController();
//   String matchStatus = '';
//   bool isConnected = false;
//
//   bool get isWebSocketConnected => isConnected;
//
//   MatchmakingService(String serverUrl) {
//     channel = IOWebSocketChannel.connect(serverUrl);
//     channel.stream.listen(
//       handleMatchmakingResponse,
//       onDone: () {
//         isConnected = false;
//         print('WebSocket disconnected');
//         notifyListeners();
//       },
//       onError: (error) {
//         isConnected = false;
//         print('WebSocket error: $error');
//         notifyListeners();
//       },
//     );
//
//     channel.sink.done.then((_) {
//       isConnected = false;
//       print('WebSocket disconnected');
//       notifyListeners();
//     });
//
//     isConnected = true;
//     print('WebSocket connected');
//   }
//
//   void startMatchmaking() {
//     final playerName = playerNameController.text;
//     if (playerName.isNotEmpty) {
//       channel.sink.add(json.encode({'type': 'matchmaking_request', 'playerName': playerName}));
//     }
//   }
//
//   void handleMatchmakingResponse(dynamic data) {
//     try {
//       final decodedData = json.decode(data);
//       if (decodedData['type'] == 'match_found') {
//         String opponent = decodedData['opponent'];
//         matchStatus = 'Match found with $opponent';
//         print(matchStatus);
//         channel.sink.add(json.encode({'type': 'get_player_details', 'playerId': opponent}));
//       } else if (decodedData['type'] == 'player_details') {
//         print('Received player details: ${decodedData['details']}');
//       }
//     } catch (e) {
//       print('Error decoding server response: $e');
//     }
//
//     notifyListeners();
//   }
//
//   void dispose() {
//     channel.sink.close();
//   }
// }
//
// class MatchmakingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var matchmakingService = Provider.of<MatchmakingService>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Matchmaking Screen'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: matchmakingService.playerNameController,
//               decoration: InputDecoration(labelText: 'Enter your name'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 matchmakingService.startMatchmaking();
//               },
//               child: Text('Start Matchmaking'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               matchmakingService.matchStatus,
//               style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Connection Status: ${matchmakingService.isWebSocketConnected ? "Connected" : "Disconnected"}',
//               style: TextStyle(color: matchmakingService.isWebSocketConnected ? Colors.green : Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
