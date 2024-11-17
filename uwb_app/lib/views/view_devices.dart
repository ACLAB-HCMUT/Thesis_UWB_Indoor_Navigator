
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
  late Future<List<Device>> devices;
  final DeviceService deviceService = DeviceService();
  final MqttService mqttService = MqttService();
  @override
  void initState() {
    super.initState();
    devices = deviceService.fetchAllDevices();
    mqttService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devices',
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
          child: FutureBuilder<List<Device>>(
            future: devices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No devices found'));
              }

              final devicesList = snapshot.data!;

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
                                  margin: const EdgeInsets.only(top: 10.0, left: 15.0),
                                  width: 10.0,
                                  height: 10.0,
                                  decoration: BoxDecoration(
                                    color: device.status == 'Active' ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    device.status == 'Active' ? 'Active' : 'Not Active',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: device.status == 'Active' ? Colors.green : Colors.red,
                                    ),
                                  )
                                )
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
                              padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                              child: Text(
                                device.name,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'BabasNee',
                                ),
                              ),
                            )
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
                            )
                          ),
                        ],
                      )
                    )
                  );
                },
              );
            },
          ),
        )
      ),
    );
  }
}