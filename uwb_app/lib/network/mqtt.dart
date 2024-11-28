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
  List<BaseStation> baseStations = [];
  DeviceService deviceService = DeviceService();
  BaseStationService baseStationService = BaseStationService();
  final StreamController<int> _messageController = StreamController.broadcast();

  MqttService() {
    fetchAllData();
    client = MqttServerClient(broker, '');
  }

  Future<void> fetchAllData() async {
    devices = await deviceService.fetchAllDevices();
    baseStations = await baseStationService.fetchAllBaseStations();
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
    client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
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
        print('Match: $match');
        if (match != null) {
          List<BaseStation> newBaseStations = [
            BaseStation(
                name: 'B1',
                x: double.parse(match.group(4)!),
                y: double.parse(match.group(5)!)),
            BaseStation(
                name: 'B2',
                x: double.parse(match.group(6)!),
                y: double.parse(match.group(7)!)),
            BaseStation(
                name: 'B3',
                x: double.parse(match.group(8)!),
                y: double.parse(match.group(9)!)),
          ];

          if (baseStations.isEmpty) {
            for (var base in newBaseStations) {
              BaseStation addedBase =
                  await baseStationService.addBaseByName(base.name);
              baseStations.add(addedBase);
            }
          }

          for (var newBase in newBaseStations) {
            for (var i = 0; i < baseStations.length; i++) {
              if (baseStations[i].name == newBase.name) {
                baseStations[i] = await baseStationService.updateBaseById(
                    baseStations[i].id, newBase.x, newBase.y);
              }
            }
          }

          for (var device in devices) {
            if (device.name == match.group(1)) {
              await deviceService.updateDeviceById(device.id,
                  double.parse(match.group(2)!), double.parse(match.group(3)!));
              return;
            }
          }

          final newDevice =
              await deviceService.addDeviceByName(match.group(1)!);
          await deviceService.updateDeviceById(newDevice.id,
              double.parse(match.group(2)!), double.parse(match.group(3)!));
              
          _messageController.add(1);
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

  Stream<int> get messageStream => _messageController.stream;
}
