// import 'dart:convert';
// import 'dart:io';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/io.dart';
//
// final Map<String, WebSocketChannel> rooms = {};
//
// void main() async {
//   final server = await HttpServer.bind('192.168.1.18', 3000); // Use your local IP address here  print('Server running on port ${server.port}');
//   server.listen((HttpRequest request) {
//     if (WebSocketTransformer.isUpgradeRequest(request)) {
//       handleWebSocket(request);
//     } else {
//       handleHttpRequest(request);
//     }
//   });
// }
//
// void handleWebSocket(HttpRequest request) {
//   WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
//     webSocket.listen(
//           (data) {
//         try {
//           final message = json.decode(data);
//           handleWebSocketConnection(webSocket, message);
//         } catch (e) {
//           print('Error decoding message: $e');
//         }
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         print('WebSocket disconnected');
//         // Handle disconnection (remove from room, show a message, etc.)
//       },
//     );
//   });
// }
//
// void handleWebSocketConnection(WebSocket webSocket, Map<String, dynamic> message) {
//   switch (message['type']) {
//     case 'create_room':
//       handleCreateRoom(webSocket);
//       break;
//     case 'join_room':
//       handleJoinRoom(webSocket, message['roomCode']);
//       break;
//     default:
//       print('Unknown message type: ${message['type']}');
//   }
// }
//
// void handleCreateRoom(WebSocket webSocket) {
//   final roomCode = generateRoomCode();
//   final webSocketChannel = IOWebSocketChannel(webSocket);
//   rooms[roomCode] = webSocketChannel;
//   webSocketChannel.sink.add(json.encode({'type': 'room_created', 'roomCode': roomCode}));
//   print('Room created: $roomCode');
// }
//
// void handleJoinRoom(WebSocket webSocket, String roomCode) {
//   final webSocketChannel = rooms[roomCode];
//   if (webSocketChannel != null) {
//     webSocketChannel.sink.add(json.encode({'type': 'player_joined'}));
//     print('Player joined room: $roomCode');
//   } else {
//     webSocket.add(json.encode({'type': 'room_not_found', 'roomCode': roomCode}));
//     print('Room not found: $roomCode');
//   }
// }
//
// String generateRoomCode() {
//   // Generate a unique room code (you can implement your logic)
//   return 'room${rooms.length + 1}';
// }
//
// void handleHttpRequest(HttpRequest request) {
//   request.response.write('Welcome to the server!');
//   request.response.close();
// }
//
//
//
//
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// void main() {
//   runApp(
//     MaterialApp(
//       home: ChessGameScreen(),
//     ),
//   );
// }
//
// class ChessGameScreen extends StatefulWidget {
//   @override
//   _ChessGameScreenState createState() => _ChessGameScreenState();
// }
//
// class _ChessGameScreenState extends State<ChessGameScreen> {
//   late WebSocketChannel channel;
//   TextEditingController roomController = TextEditingController();
//   TextEditingController playerNameController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     channel = IOWebSocketChannel.connect('ws://192.168.1.18:3000'); // Update with your server's IP
//     channel.stream.listen(
//           (data) {
//         try {
//           final message = json.decode(data as String);
//           handleServerResponse(message);
//         } catch (e) {
//           print('Error decoding server message: $e');
//         }
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         print('WebSocket disconnected');
//       },
//     );
//   }
//
//   void handleServerResponse(Map<String, dynamic> message) {
//     final messageType = message['type'] as String;
//     switch (messageType) {
//       case 'room_created':
//         handleRoomCreated(message);
//         break;
//       case 'room_joined':
//         handleRoomJoined(message);
//         break;
//       case 'room_not_found':
//         handleRoomNotFound(message);
//         break;
//     // Add more message types as needed
//       default:
//         print('Unknown message type: $messageType');
//     }
//   }
//
//   void handleRoomCreated(Map<String, dynamic> message) {
//     final roomCode = message['roomCode'] as String;
//     print('Room created with code: $roomCode');
//   }
//
//   void handleRoomJoined(Map<String, dynamic> message) {
//     final roomCode = message['roomCode'] as String;
//     print('Joined room with code: $roomCode');
//     // Navigate to your game screen or perform other actions
//   }
//
//   void handleRoomNotFound(Map<String, dynamic> message) {
//     final roomCode = message['roomCode'] as String;
//     print('Room not found: $roomCode');
//   }
//
//   void createRoom() {
//     final playerName = playerNameController.text;
//     if (playerName.isNotEmpty) {
//       channel.sink.add(json.encode({'type': 'create_room', 'playerName': playerName}));
//     }
//   }
//
//   void joinRoom() {
//     final roomCode = roomController.text;
//     final playerName = playerNameController.text;
//
//     if (roomCode.isNotEmpty && playerName.isNotEmpty) {
//       channel.sink.add(json.encode({
//         'type': 'join_room',
//         'roomCode': roomCode,
//         'playerName': playerName,
//       }));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chess Game'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: roomController,
//               decoration: InputDecoration(labelText: 'Enter Room Code'),
//             ),
//             TextField(
//               controller: playerNameController,
//               decoration: InputDecoration(labelText: 'Enter Your Name'),
//             ),
//             ElevatedButton(
//               onPressed: createRoom,
//               child: Text('Create Room'),
//             ),
//             ElevatedButton(
//               onPressed: joinRoom,
//               child: Text('Join Room'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     channel.sink.close();
//     super.dispose();
//   }
// }
