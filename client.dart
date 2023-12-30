// import 'dart:convert';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// void main() {
//   try {
//     final channel = IOWebSocketChannel.connect('ws://localhost:3000');
//
//     channel.stream.listen(
//           (data) {
//         try {
//           final message = json.decode(data);
//           handleServerResponse(message);
//         } catch (e) {
//           print('Error decoding server message: $e');
//         }
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//         // Handle the error gracefully (reconnect, show a message, etc.)
//       },
//       onDone: () {
//         print('WebSocket disconnected');
//         // Handle disconnection (reconnect, show a message, etc.)
//       },
//     );
//
//     // Example: Sending a message to create a room
//     final createRoomMessage = {'type': 'create_room'};
//     channel.sink.add(json.encode(createRoomMessage));
//
//     // Example: Sending a message to join a room
//     final joinRoomMessage = {'type': 'join_room', 'roomCode': 'room123'};
//     channel.sink.add(json.encode(joinRoomMessage));
//
//     // Note: The WebSocket connection will remain open until you explicitly close it.
//     // channel.sink.close();
//   } catch (e) {
//     print('Error connecting to the WebSocket server: $e');
//     // Handle connection error (show a message, retry, etc.)
//   }
// }
//
// void handleServerResponse(Map<String, dynamic> message) {
//   // Your implementation to handle the incoming server message
//   print('Received message from server: $message');
// }
