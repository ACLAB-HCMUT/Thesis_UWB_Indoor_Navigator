import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class Device {
  final String deviceId;
  final String deviceName;
  final String deviceAcStatus;
  final String deviceLoStatus;
  final String deviceImagePath;

  Device ({
    required this.deviceId,
    required this.deviceName,
    required this.deviceAcStatus,
    required this.deviceLoStatus,
    required this.deviceImagePath,
  });
}

List<Device> devices = [
  Device(
    deviceId: '01',
    deviceName: 'Tag 1',
    deviceAcStatus: 'Active',
    deviceLoStatus: 'In room',
    deviceImagePath: 'uwb.png',
  ),
  Device(
    deviceId: '02',
    deviceName: 'Tag 2',
    deviceAcStatus: 'Not Active',
    deviceLoStatus: 'In room',
    deviceImagePath: 'uwb.png',
  ),
  Device(
    deviceId: '03',
    deviceName: 'Tag 3',
    deviceAcStatus: 'Active',
    deviceLoStatus: 'Out room',
    deviceImagePath: 'uwb.png',
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
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
          child: GridView.builder(
            itemCount: devices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 7/6,
            ),
            itemBuilder: (context, index) {
              final device = devices[index];
              return Card (
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                      onTap: () {
                        context.goNamed('DeviceInfo', extra: device.deviceId);
                      },
                      child: Column(children: [
                        // Device Status
                        Align(
                          alignment: Alignment.topLeft,
                          child: Row (children:[
                            Container(
                              margin: const EdgeInsets.only(top: 10.0, left: 15.0),
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                color: device.deviceAcStatus == 'Active' ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Container(
                                margin: const EdgeInsets.only(top: 10.0),
                                child: Text (
                                  device.deviceAcStatus == 'Active' ? 'Active' : 'Not Active',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: device.deviceAcStatus == 'Active' ? Colors.green : Colors.red,
                                  ),
                                )
                            )
                          ],),
                        ),
                        // Device Image
                        Image(
                          image: AssetImage(device.deviceImagePath),
                          height: 80,
                        ),
                        // Device Name
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                            child: Text(
                              device.deviceName,
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
                              device.deviceLoStatus,
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ),
                      ],)
                  )
              );
            },
          )
        )
      ),
    );
  }
}
