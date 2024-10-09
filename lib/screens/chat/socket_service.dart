import 'dart:ffi';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:slush/constants/LocalHandler.dart';

class SocketService {

  // late IO.Socket socket;
  IO.Socket? socket; // Nullable variable
  void connect() {
    socket = IO.io(
      'http://dev-api.slushdating.com:3000', // Replace with your server address and port
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .enableAutoConnect() // optional
          .setAuth({'userId': LocaleHandler.userId}) // Pass userId for authentication
          .build(),
    );

    socket!.onConnect((_) {
      print('Connected');
    });

    socket!.onDisconnect((_) {
      print('Disconnected');
    });

    socket!.on('error', (data) {
      print('Error: $data');
    });

    socket!.onConnectError((data) {
      print('Connect Error: $data');
    });

    socket!.on('private message', (data) {
      print('RECEIVED MSG: $data');
    });
  }

  void sendMessage(String content, String from, String to) {
    socket!.emit('private message', {
      'content': content, 'from': from, 'to': to,
    });
  }

  void disconnect() {
    socket!.disconnect();
  }
}
