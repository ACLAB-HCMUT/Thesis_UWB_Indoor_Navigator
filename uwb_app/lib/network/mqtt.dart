import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  final String username = '';
  final String aioKey = '';
  final Logger logger = Logger('MqttService');

  MqttService();

  Future<void> connect() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    client =
        MqttServerClient.withPort('io.adafruit.com', 'flutter_client_$now', 1883);
    client.secure = false;
    client.setProtocolV311();
    // client.connectTimeoutPeriod = 10000;
    client.keepAlivePeriod = 200;
    client.onDisconnected = onDisconnected;
    client.logging(on: true);
    client.autoReconnect = true;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    try {
      logger.info('Starting connection attempt...');
      final connMessage = MqttConnectMessage()
          .withClientIdentifier('flutter_client_$now')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce)
          .authenticateAs(username, aioKey);
      client.connectionMessage = connMessage;
      await client.connect(username, aioKey);

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        logger.info('Connected to Adafruit IO!');
        subscribe('$username/feeds/coordinate/json');
      } else {
        logger.severe(
            'Connection failed - status is ${client.connectionStatus?.state}');
        logger.severe('Return code: ${client.connectionStatus?.returnCode}');
      }
    } on NoConnectionException catch (e) {
      logger.severe('Failed to connect: $e');
      logger.severe('Connection status: ${client.connectionStatus}');
      logger.severe('Client state: ${client.connectionStatus?.state}');
      client.disconnect();
    } catch (e) {
      logger.severe('Error occurred: $e');
      logger.severe('Connection status: ${client.connectionStatus}');
      logger.severe('Client state: ${client.connectionStatus?.state}');
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    logger.info('Subscribing to $topic...');
    client.subscribe(topic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      logger.info('Received message from topic: ${c[0].topic}');
      logger.info('Raw payload: $payload');

      try {
        final Map<String, dynamic> data = jsonDecode(payload);

        final String createdAt = data['created_at'] ?? 'No created_at';
        final dynamic value = data['value'];
        final String location = data['location'] ?? 'No location';

        logger.info('----------------------------------------');
        logger.info('Created at: $createdAt');
        logger.info('Value: $value');
        logger.info('Location: $location');
        logger.info('----------------------------------------');
      } catch (e) {
        logger.severe('Error parsing message: $e');
        logger.severe('Raw message that failed to parse: $payload');
      }
    });
  }

  void disconnect() {
    logger.info('Disconnecting from Adafruit IO');
    client.disconnect();
  }

  void onConnected() {
    logger.info('Connected to Adafruit IO');
  }

  void onDisconnected() {
    logger.info('Disconnected from Adafruit IO');
  }

  void onSubscribed(String topic) {
    logger.info('Successfully subscribed to topic: $topic');
  }

  void onSubscribeFail(String topic) {
    logger.info('Failed to subscribe to topic: $topic');
  }
}
