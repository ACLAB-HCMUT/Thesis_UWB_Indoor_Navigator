import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ParsedMessage {
  final String name;
  final double tx;
  final double ty;
  final double b1x;
  final double b1y;
  final double b2x;
  final double b2y;
  final double b3x;
  final double b3y;

  ParsedMessage({
    required this.name,
    required this.tx,
    required this.ty,
    required this.b1x,
    required this.b1y,
    required this.b2x,
    required this.b2y,
    required this.b3x,
    required this.b3y,
  });
}

class MqttService {
  final String broker = 'io.adafruit.com';
  final int port = 1883;
  final String username = '';
  final String aioKey = '';
  final Logger logger = Logger('MqttService');
  final List<String> topics = ['coordinate'];
  late MqttServerClient client;
  final StreamController<ParsedMessage> _messageController =
      StreamController.broadcast();
  MqttService() {
    client = MqttServerClient(broker, '');
  }

  Future<void> connect() async {
    client.port = port;
    client.secure = false;
    client.logging(on: true);
    client.keepAlivePeriod = 30;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(
            'flutter_mqtt_client') // Unique identifier for the client
        .withWillTopic('willtopic') // Optional last-will topic
        .withWillMessage('Connection closed')
        .startClean() // Clean session
        .authenticateAs(username, aioKey) // Authentication
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      print('Connecting to Adafruit IO...');
      await client.connect();
    } on NoConnectionException catch (e) {
      print('MQTT client exception - $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
    } else {
      print('Connection failed - ${client.connectionStatus!.state}');
      client.disconnect();
      return;
    }

    subscribeToFeeds();
    listenFromFeeds();
    print('Finished connecting to Adafruit IO');
  }

  void subscribeToFeeds() {
    print('Subscribing to feed...');
    for (var topic in topics) {
      final String fullTopic = '$username/feeds/$topic';
      client.subscribe(fullTopic, MqttQos.atLeastOnce);
      print('Subscribed to feed: $topic');
    }
  }

  void listenFromFeeds() {
    print('Listening for messages from subscribed feeds...');
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        final topic = message.topic;
        final MqttPublishMessage payloadMessage =
            message.payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(
            payloadMessage.payload.message);
        print('Message received: Topic = $topic, Payload = $payload');

        final regex = RegExp(
            r'Name: (\w+); Coordinate T: ([\d.]+) ([\d.]+); B1: ([\d.]+) ([\d.]+); B2: ([\d.]+) ([\d.]+); B3: ([\d.]+) ([\d.]+)');
        final match = regex.firstMatch(payload);
        print ('Match: $match');
        if (match != null) {
          _messageController.add(ParsedMessage(
            name: match.group(1)!,
            tx: double.parse(match.group(2)!),
            ty: double.parse(match.group(3)!),
            b1x: double.parse(match.group(4)!),
            b1y: double.parse(match.group(5)!),
            b2x: double.parse(match.group(6)!),
            b2y: double.parse(match.group(7)!),
            b3x: double.parse(match.group(8)!),
            b3y: double.parse(match.group(9)!),
          ));
        }
      }
    });
  }

  Future<void> disconnect() async {
    print('Disconnecting from Adafruit IO...');
    client.disconnect();
    _messageController.close();
    print('Disconnected from Adafruit IO');
  }

  Stream<ParsedMessage> get messageStream => _messageController.stream;
}
