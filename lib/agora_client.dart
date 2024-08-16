// import 'package:agora_uikit/agora_uikit.dart';
//
// final AgoraClient client = AgoraClient(
//   agoraConnectionData: AgoraConnectionData(
//     appId: "5edabab50c05485c87c3f0cdccba838e",
//     channelName: "test",
//     tempToken: token,
//   ),
//   enabledPermission: [
//     Permission.camera,
//     Permission.microphone,
//   ],
// );
//
// @override
// void initState() {
//   super.initState();
//   initAgora();
// }
//
// void initAgora() async {
//   await client.initialize();
// }
//
// @override
// Widget build(BuildContext context) {
//   return MaterialApp(
//     home: Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             AgoraVideoViewer(client: client),
//             AgoraVideoButtons(client: client),
//           ],
//         ),
//       ),
//     ),
//   );
// }