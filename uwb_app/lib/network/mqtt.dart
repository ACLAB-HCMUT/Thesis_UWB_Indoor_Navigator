import 'dart:async';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uwb_app/network/device.dart';

class MqttService {
  final String broker = 'io.adafruit.com';
  final int port = 1883;
  final String username = 'aclab241';
  final String aioKey = '';
  final Logger logger = Logger('MqttService');
  final List<String> topics = ['coordinate', 'edit_anchors'];
  late MqttServerClient client;
  List<Device> devices = [];
  DeviceService deviceService = DeviceService();
  final StreamController<int> _messageController = StreamController.broadcast();

  MqttService() {
    // fetchAllData();
  }

  Future<void> fetchAllData() async {
    devices = await deviceService.fetchAllDevices();
  }

  Future<void> connect(String broker) async {
    client = MqttServerClient(broker, '');
    client.port = port;
    client.secure = false;
    client.logging(on: true);
    client.keepAlivePeriod = 30;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(
            'flutter_mqtt_client') // Unique identifier for the client
        // .withWillTopic('willtopic') // Optional last-will topic
        // .withWillMessage('Connection closed')
        .startClean() // Clean session
        // .authenticateAs(username, aioKey) // Authentication
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

  // Listen on feed coordinate (no edit_anchors)
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
            r'Name: (\w+); Coordinate: ([\d.]+) ([\d.]+); Device_type: ([\d.]+); Location: (.+); Status: (.+)');
        // Example payload: "Name: Device1; Coordinate: 12.34 56.78; Device_type: 1; Location: Room1; Status: Active"
        final match = regex.firstMatch(payload);
        if (match == null) return;

        final name = match.group(1)!;
        final x = double.parse(match.group(2)!);
        final y = double.parse(match.group(3)!);
        final deviceType = int.parse(match.group(4)!);
        final location = match.group(5)!;
        final activeStatus = match.group(6)!;

        final response = {
          'name': name,
          'x': x,
          'y': y,
          'deviceType': deviceType,
          'location': location,
          'activeStatus': activeStatus,
        };

        onDataUpdate(response);
      }
    });
  }

  // publish edit_anchors
  void publish(String topic, String method, String deviceName, String x_value,
      String y_value) {
    if (topic.isEmpty) {
      print('Topic or payload is empty. Cannot publish.');
      return;
    }
    if (topic == 'edit_anchors') {
      final String fullTopic = '$username/feeds/$topic';
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      String payload =
          "Method: $method; Device_name: $deviceName; x-value: ${x_value}; y-value: ${y_value}";

      builder.addString(payload);
      client.publishMessage(fullTopic, MqttQos.atLeastOnce, builder.payload!);
      print('Published message to $fullTopic: $payload');
    }
  }

  Future<void> disconnect() async {
    print('Disconnecting from Adafruit IO...');
    client.disconnect();
    _messageController.close();
    print('Disconnected from Adafruit IO');
  }

  Stream<int> get messageStream => _messageController.stream;
}
