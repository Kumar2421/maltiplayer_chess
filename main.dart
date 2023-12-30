import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(
    MaterialApp(
      home: ChessGameScreen(),
    ),
  );
}

class ChessGameScreen extends StatefulWidget {
  @override
  _ChessGameScreenState createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late WebSocketChannel channel;
  TextEditingController roomController = TextEditingController();
  TextEditingController playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://192.168.1.18:3000'); // Update with your server's IP
    channel.stream.listen(
          (data) {
        try {
          final message = json.decode(data as String);
          handleServerResponse(message);
        } catch (e) {
          print('Error decoding server message: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket disconnected');
      },
    );
  }

  void handleServerResponse(Map<String, dynamic> message) {
    final messageType = message['type'] as String;
    switch (messageType) {
      case 'room_created':
        handleRoomCreated(message);
        break;
      case 'room_joined':
        handleRoomJoined(message);
        break;
      case 'room_not_found':
        handleRoomNotFound(message);
        break;
    // Add more message types as needed
      default:
        print('Unknown message type: $messageType');
    }
  }

  void handleRoomCreated(Map<String, dynamic> message) {
    final roomCode = message['roomCode'] as String;
    print('Room created with code: $roomCode');
  }

  void handleRoomJoined(Map<String, dynamic> message) {
    final roomCode = message['roomCode'] as String;
    print('Joined room with code: $roomCode');
    // Navigate to your game screen or perform other actions
  }

  void handleRoomNotFound(Map<String, dynamic> message) {
    final roomCode = message['roomCode'] as String;
    print('Room not found: $roomCode');
  }

  void createRoom() {
    final playerName = playerNameController.text;
    if (playerName.isNotEmpty) {
      channel.sink.add(json.encode({'type': 'create_room', 'playerName': playerName}));
    }
  }

  void joinRoom() {
    final roomCode = roomController.text;
    final playerName = playerNameController.text;

    if (roomCode.isNotEmpty && playerName.isNotEmpty) {
      channel.sink.add(json.encode({
        'type': 'join_room',
        'roomCode': roomCode,
        'playerName': playerName,
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: roomController,
              decoration: InputDecoration(labelText: 'Enter Room Code'),
            ),
            TextField(
              controller: playerNameController,
              decoration: InputDecoration(labelText: 'Enter Your Name'),
            ),
            ElevatedButton(
              onPressed: createRoom,
              child: Text('Create Room'),
            ),
            ElevatedButton(
              onPressed: joinRoom,
              child: Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
