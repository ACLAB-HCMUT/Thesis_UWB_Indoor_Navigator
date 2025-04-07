import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uwb_app/network/device.dart';

class MqttService {
  final String broker = 'io.adafruit.com';
  final int port = 1883;
  final String username = '';
  final String aioKey = '';
  final Logger logger = Logger('MqttService');
  final List<String> topics = ['coordinate'];
  late MqttServerClient client;
  List<Device> devices = [];
  DeviceService deviceService = DeviceService();
  final StreamController<int> _messageController = StreamController.broadcast();

  MqttService() {
    // fetchAllData();
    client = MqttServerClient(broker, '');
  }

  Future<void> fetchAllData() async {
    devices = await deviceService.fetchAllDevices();
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
    // listenFromFeeds();
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

  void listenFromFeeds(Function(Map<String, dynamic>) onDataUpdate) {
    print('Listening for messages from subscribed feeds...');
    client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
      for (var message in messages) {
        final topic = message.topic;
        final MqttPublishMessage payloadMessage =
            message.payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(
            payloadMessage.payload.message);
        print('Message received: Topic = $topic, Payload = $payload');

        // Parse the payload to extract the data
        final regex = RegExp(
            r'Name: (\w+); Coordinate: ([\d.]+) ([\d.]+); Device_type: ([\d.]+); Location: (.+)');
        final match = regex.firstMatch(payload);
        if (match == null) return;

        final name = match.group(1)!;
        final x = double.parse(match.group(2)!);
        final y = double.parse(match.group(3)!);
        final deviceType = int.parse(match.group(4)!);
        final location = match.group(5)!;

        final response = {
          'name': name,
          'x': x,
          'y': y,
          'deviceType': deviceType,
          'location': location,
        };

        onDataUpdate(response);
      }
    });
  }

  Future<void> disconnect() async {
    print('Disconnecting from Adafruit IO...');
    client.disconnect();
    _messageController.close();
    print('Disconnected from Adafruit IO');
  }

  Stream<int> get messageStream => _messageController.stream;
}
