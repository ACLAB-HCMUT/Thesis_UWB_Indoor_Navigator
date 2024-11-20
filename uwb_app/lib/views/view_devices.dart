import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uwb_app/network/device.dart';
import 'package:uwb_app/network/mqtt.dart';

class ViewDevices extends StatefulWidget {
  const ViewDevices({super.key});

  @override
  State<ViewDevices> createState() => _ViewDevicesState();
}

class _ViewDevicesState extends State<ViewDevices> {
  ValueNotifier<List<Device>> devicesNotifier = ValueNotifier<List<Device>>([]);
  final DeviceService deviceService = DeviceService();
  final MqttService mqttService = MqttService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initialize();
    startPeriodFetch();
  }

  @override
  void dispose() {
    mqttService.disconnect();
    _timer?.cancel();
    super.dispose();
  }

  /*
    Fetch data from DB and connect to the MQTT server.
    Listen to Mqtt stream
  */
  Future<void> initialize() async {
    devicesNotifier.value = await deviceService.fetchAllDevices();
    mqttService.connect().then((_) {
      mqttService.messageStream.listen((message) async {
        await checkAndUpdateDevice(message.name, message.tx, message.ty);
        refreshPage();
      });
    });
  }

  /*
    Fetch data from DB every 5 seconds
  */
  Future<void> startPeriodFetch() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      refreshPage();
    });
  }

  /*
    Check if two lists are not equal then refresh the page
  */
  Future<void> refreshPage() async {
    final currentDevices = devicesNotifier.value;
    deviceService.fetchAllDevices().then((newDevices) {
      bool isSame = true;
      if (currentDevices.length != newDevices.length) {
        isSame = false;
      } else {
        for (int i = 0; i < currentDevices.length; i++) {
          if (currentDevices[i].id != newDevices[i].id ||
              currentDevices[i].name != newDevices[i].name ||
              currentDevices[i].status != newDevices[i].status ||
              currentDevices[i].histories.length !=
                  newDevices[i].histories.length) {
            isSame = false;
            break;
          }
        }
      }
      if (!isSame) {
        setState(() {
          devicesNotifier.value = newDevices;
        });
      }
    });
  }

  /*
    Check if device is already in DB or not. If it is, update the device's position. 
    If not, add the device to the DB and update the device's position.
  */
  Future<void> checkAndUpdateDevice(String name, double x, double y) async {
    final devicesList = devicesNotifier.value;
    for (var device in devicesList) {
      if (device.name == name) {
        final res = await deviceService.updateDeviceById(device.id, x, y);
        return;
      }
    }
    final newDevice = await deviceService.getDeviceById(name);
    final res = await deviceService.updateDeviceById(newDevice.id, x, y);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devices',
      home: RefreshIndicator(
        onRefresh: () async {
          refreshPage();
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
            child: ValueListenableBuilder<List<Device>>(
              valueListenable: devicesNotifier,
              builder: (context, devicesList, _) {
                if (devicesList.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: const Center(child: Text('No devices found')),
                    ),
                  );
                }

                return GridView.builder(
                  itemCount: devicesList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 7 / 7,
                  ),
                  itemBuilder: (context, index) {
                    final device = devicesList[index];
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.goNamed('DeviceInfo', extra: device.id);
                        },
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 10.0, left: 15.0),
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: BoxDecoration(
                                      color: device.status == 'Active'
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5.0),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      device.status,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: device.status == 'Active'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Device Image
                            Image(
                              image: AssetImage('assets/${device.img}'),
                              height: 80,
                            ),
                            // Device Name
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, left: 15.0),
                                child: Text(
                                  device.name,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'BabasNee',
                                  ),
                                ),
                              ),
                            ),
                            // Device Location
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Text(
                                  device.location,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
