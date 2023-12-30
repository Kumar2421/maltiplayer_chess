import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

final Map<String, WebSocketChannel> rooms = {};

void main() async {
  final server = await HttpServer.bind('192.168.1.18', 3000); // Use your local IP address here  print('Server running on port ${server.port}');
  server.listen((HttpRequest request) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      handleWebSocket(request);
    } else {
      handleHttpRequest(request);
    }
  });
}

void handleWebSocket(HttpRequest request) {
  WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
    webSocket.listen(
          (data) {
        try {
          final message = json.decode(data);
          handleWebSocketConnection(webSocket, message);
        } catch (e) {
          print('Error decoding message: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket disconnected');
        // Handle disconnection (remove from room, show a message, etc.)
      },
    );
  });
}

void handleWebSocketConnection(WebSocket webSocket, Map<String, dynamic> message) {
  switch (message['type']) {
    case 'create_room':
      handleCreateRoom(webSocket);
      break;
    case 'join_room':
      handleJoinRoom(webSocket, message['roomCode']);
      break;
    default:
      print('Unknown message type: ${message['type']}');
  }
}

void handleCreateRoom(WebSocket webSocket) {
  final roomCode = generateRoomCode();
  final webSocketChannel = IOWebSocketChannel(webSocket);
  rooms[roomCode] = webSocketChannel;
  webSocketChannel.sink.add(json.encode({'type': 'room_created', 'roomCode': roomCode}));
  print('Room created: $roomCode');
}

void handleJoinRoom(WebSocket webSocket, String roomCode) {
  final webSocketChannel = rooms[roomCode];
  if (webSocketChannel != null) {
    webSocketChannel.sink.add(json.encode({'type': 'player_joined'}));
    print('Player joined room: $roomCode');
  } else {
    webSocket.add(json.encode({'type': 'room_not_found', 'roomCode': roomCode}));
    print('Room not found: $roomCode');
  }
}

String generateRoomCode() {
  // Generate a unique room code (you can implement your logic)
  return 'room${rooms.length + 1}';
}

void handleHttpRequest(HttpRequest request) {
  request.response.write('Welcome to the server!');
  request.response.close();
}
