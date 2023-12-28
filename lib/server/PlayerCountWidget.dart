// // PlayerCountWidget.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'matchmaking_service.dart';
//
// class PlayerCountWidget extends StatefulWidget {
//   @override
//   _PlayerCountWidgetState createState() => _PlayerCountWidgetState();
// }
//
// class _PlayerCountWidgetState extends State<PlayerCountWidget> {
//   late MatchmakingService matchmakingService;
//
//   @override
//   void initState() {
//     super.initState();
//     matchmakingService = Provider.of<MatchmakingService>(context, listen: false);
//     matchmakingService.addListener(updatePlayerCount);
//   }
//
//   @override
//   void dispose() {
//     matchmakingService.removeListener(updatePlayerCount);
//     super.dispose();
//   }
//
//   void updatePlayerCount() {
//     // This method is called whenever there is a change in available or online players
//     // You can use matchmakingService.availablePlayers and matchmakingService.onlinePlayers to get the lists
//     // of available and online players, and update the UI accordingly.
//     // For example, you can display the lists in a ListView.
//     // Also, you may want to refresh these lists by sending requests to the server periodically.
//     setState(() {}); // Trigger a rebuild to update the UI
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Available Players: ${matchmakingService.availablePlayers.length}'),
//         Expanded(
//           child: ListView.builder(
//             itemCount: matchmakingService.availablePlayers.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(matchmakingService.availablePlayers[index]),
//                 trailing: ElevatedButton(
//                   onPressed: () {
//                     // Handle inviting the selected player
//                   },
//                   child: Text('Invite'),
//                 ),
//               );
//             },
//           ),
//         ),
//         Text('Online Players: ${matchmakingService.onlinePlayers.length}'),
//         Expanded(
//           child: ListView.builder(
//             itemCount: matchmakingService.onlinePlayers.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(matchmakingService.onlinePlayers[index]),
//                 // Add more details or actions as needed
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
