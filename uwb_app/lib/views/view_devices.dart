import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uwb_app/network/device.dart';
import 'package:uwb_app/network/mqtt.dart';
import 'package:provider/provider.dart';
import 'package:uwb_app/views/scatter_chart.dart';

class ViewDevices extends StatefulWidget {
  const ViewDevices({super.key});

  @override
  State<ViewDevices> createState() => _ViewDevicesState();
}

class _ViewDevicesState extends State<ViewDevices> {
  final DeviceService deviceService = DeviceService();
  final JsonBlob jsonBlob = JsonBlob(
    localIP: localIP,
    username: 'admin',
    password: 'admin',
  );
  late ValueNotifier<List<Device>> deviceList;
  late MqttService mqttService;
  late ValueNotifier<Map<String, Point>> points =
      ValueNotifier<Map<String, Point>>({});
  late ValueNotifier<String> newUrl;
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
    // Assign the provider to the variable
    mqttService = Provider.of<MqttService>(context, listen: false);
    deviceList =
        Provider.of<ValueNotifier<List<Device>>>(context, listen: false);
    newUrl = Provider.of<ValueNotifier<String>>(context,
        listen:
            false); // Fetch data from the database and connect to the MQTT server

    await jsonBlob.getJsonFromBlob().then((value) {
      if (value != null) {
        localIP = value.localIP;
        newUrl.value = 'http://${value.localIP}:3000/device';
      }
    });

    // Fetch all devices from the database
    loadData();

    mqttService.connect(localIP).then((_) {
      mqttService.listenFromFeeds((data) {
        Device device = deviceList.value.firstWhere((device) {
          return device.name == data['name'];
        });
        device.updateDeviceStatus(data);

        // Reassign the value to notify listeners
        deviceList.value = List.from(deviceList.value);
      });
    });
  }

  /*
    Check if two lists are not equal then refresh the page
  */
  Future<void> loadData() async {
    deviceList.value = await deviceService.fetchAllDevices(newUrl.value);
  }

  /*
    Refresh UI every 5 seconds
  */
  Future<void> startPeriodFetch() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      deviceList.value = List.from(deviceList.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devices',
      home: RefreshIndicator(
        onRefresh: () async {
          loadData();
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
            child: ValueListenableBuilder<List<Device>>(
              valueListenable: deviceList,
              builder: (context, deviceList, _) {
                // List<Device> tagDevices = deviceList
                //     .where((device) => device.deviceType == 0)
                //     .toList();
                if (deviceList.isEmpty) {
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
                  itemCount: deviceList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 7 / 8,
                  ),
                  itemBuilder: (context, index) {
                    final device = deviceList[index];
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String name = '';
                  String tempX = '';
                  String tempY = '';
                  return AlertDialog(
                    title: const Text(
                      "Adding new anchor",
                      style: const TextStyle(
                        fontSize: 17,
                        fontFamily: 'Sandra',
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration:
                              const InputDecoration(labelText: 'Device Name'),
                          onChanged: (value) => name = value,
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          decoration:
                              const InputDecoration(labelText: 'X Coordinate'),
                          onChanged: (value) => tempX = value,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          decoration:
                              const InputDecoration(labelText: 'Y Coordinate'),
                          onChanged: (value) => tempY = value,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          mqttService.publish(
                            'edit_anchors',
                            'Create',
                            name,
                            tempX,
                            tempY,
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Create'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
