import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mysql1/mysql1.dart';

class Player {
  late int id;
  late String playerName;
  WebSocketChannel? webSocket;

  Player(this.id, this.playerName, this.webSocket);
}

late MySqlConnection mySqlConnection;
Map<int, Player> connectedPlayers = {};
late List<Player> matchmakingQueue;
late WebSocketChannel currentWebSocket;

Future<void> main() async {
  await initDatabase();

  matchmakingQueue = [];

  var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_handler);

  var server = await io.serve(handler, 'localhost', 3000);
  print('Server running on port ${server.port}');

  // Handle shutdown gracefully
  ProcessSignal.sigint.watch().listen((_) async {
    print('Shutting down...');
    await closeDatabase();
    server.close(force: true);
  });
}

shelf.Response _handler(shelf.Request request) {
  if (request.url.path == '/ws') {
    return shelf.Response(101,
        body: 'WebSocket handshaking...',
        headers: {'Upgrade': 'WebSocket', 'Connection': 'Upgrade'},
        context: {'webSocket': true});
  } else if (request.url.path == '/') {
    return shelf.Response.ok('Welcome to the Chess Game Server!');
  } else {
    return shelf.Response.notFound('Not Found');
  }
}

void _handleWebSocket(WebSocketChannel webSocket) {
  currentWebSocket = webSocket;

  webSocket.stream.listen(
        (dynamic data) {
      handleClientMessage(webSocket, data);
    },
    onDone: () {
      print('Client disconnected');
      removeDisconnectedPlayer(webSocket);
    },
    onError: (error) {
      print('WebSocket error: $error');
      removeDisconnectedPlayer(webSocket);
    },
  );
}

void handleClientMessage(WebSocketChannel webSocket, dynamic data) async {
  if (data is! String) {
    print('Invalid message format');
    return;
  }

  final message = json.decode(data);

  if (message['type'] == 'matchmaking_request') {
    print('Received matchmaking request from ${webSocket.hashCode}');
    final playerName = message['playerName'];
    final playerId = connectedPlayers.length + 1;
    final newPlayer = Player(playerId, playerName, webSocket);
    connectedPlayers[playerId] = newPlayer;
    await storePlayerInDatabase(newPlayer);
    addToMatchmakingQueue(newPlayer);
    pairPlayersFromMatchmakingQueue();
  }
}

void addToMatchmakingQueue(Player player) {
  matchmakingQueue.add(player);
}

void removeDisconnectedPlayer(WebSocketChannel webSocket) {
  connectedPlayers.removeWhere((key, value) => value.webSocket == webSocket);
  matchmakingQueue.removeWhere((player) => player.webSocket == webSocket);
}

void pairPlayersFromMatchmakingQueue() {
  if (matchmakingQueue.length >= 2) {
    final player1 = matchmakingQueue.removeAt(0);
    final player2 = matchmakingQueue.removeAt(0);
    sendMatchFoundEvent(player1, player2);
  }
}

void sendMatchFoundEvent(Player player1, Player player2) {
  player1.webSocket?.sink.add(json.encode({
    'type': 'match_found',
    'opponent': player2.playerName,
    'message': 'Match found! You are playing against ${player2.playerName}',
  }));

  player2.webSocket?.sink.add(json.encode({
    'type': 'match_found',
    'opponent': player1.playerName,
    'message': 'Match found! You are playing against ${player1.playerName}',
  }));

  print('Match found between ${player1.playerName} and ${player2.playerName}');
}

WebSocketChannel? findWebSocketChannel(int playerId) {
  return connectedPlayers[playerId]?.webSocket!;
}

Future<void> initDatabase() async {
  try {
    final mySqlConfig = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      db: 'chess',
      user: 'root',
    );

    mySqlConnection = await MySqlConnection.connect(mySqlConfig);

    await mySqlConnection.query('''
      CREATE TABLE IF NOT EXISTS player_lobby (
        id INT AUTO_INCREMENT PRIMARY KEY,
        player_name VARCHAR(255)
      )
    ''');

    print('Connected to MySQL');
  } catch (e) {
    print('Error connecting to MySQL: $e');
  }
}

Future<void> storePlayerInDatabase(Player player) async {
  await mySqlConnection.query(
    'INSERT INTO player_lobby (player_name) VALUES (?)',
    [player.playerName],
  );
}

Future<void> closeDatabase() async {
  await mySqlConnection.close();
  print('Database connection closed');
}
