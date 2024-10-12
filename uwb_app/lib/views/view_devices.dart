import 'package:flutter/material.dart';

class Device {
  final String deviceName;
  final String deviceAcStatus;
  final String deviceLoStatus;
  final String deviceImagePath;

  Device ({
    required this.deviceName,
    required this.deviceAcStatus,
    required this.deviceLoStatus,
    required this.deviceImagePath,
  });
}

List<Device> devices = [
  Device(
    deviceName: 'Node 1',
    deviceAcStatus: 'Active',
    deviceLoStatus: 'In room',
    deviceImagePath: 'assets/images/node1.png',
  ),
  Device(
    deviceName: 'Node 2',
    deviceAcStatus: 'Not Active',
    deviceLoStatus: 'In room',
    deviceImagePath: 'assets/images/node2.png',
  ),
  Device(
    deviceName: 'Node 3',
    deviceAcStatus: 'Active',
    deviceLoStatus: 'Out room',
    deviceImagePath: 'assets/images/node3.png',
  ),
];

class ViewDevices extends StatefulWidget {
  const ViewDevices({super.key});

  @override
  State<ViewDevices> createState() => _ViewDevicesState();
}

class _ViewDevicesState extends State<ViewDevices> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devices',
      home: Scaffold(
        body: GridView.builder(
          itemCount: devices.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 3/4,
          ),
          itemBuilder: (context, index) {
            final device = devices[index];
            return Card (
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: const Image(
                      image: AssetImage('uwb.png'),
                      height: 120.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],)
            );
          },
        )
      ),
    );
  }
}
