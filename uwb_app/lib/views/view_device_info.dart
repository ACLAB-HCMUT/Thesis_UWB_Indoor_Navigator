import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Device {
  final String deviceId;
  final String deviceName;
  final String deviceAcStatus;
  final String deviceLoStatus;
  final String deviceImagePath;
  final String deviceLastUpdated;

  Device({
    required this.deviceId,
    required this.deviceName,
    required this.deviceAcStatus,
    required this.deviceLoStatus,
    required this.deviceImagePath,
    required this.deviceLastUpdated,
  });
}

class Activity {
  final String x;
  final String y;
  final String updatedAt;

  Activity({
    required this.x,
    required this.y,
    required this.updatedAt,
  });
}

List<Activity> activities = [
  Activity(
    x: '1',
    y: '1',
    updatedAt: '2021-10-01 10:10:10',
  ),
  Activity(
    x: '2',
    y: '2',
    updatedAt: '2021-10-02 10:10:10',
  ),
  Activity(
    x: '3',
    y: '3',
    updatedAt: '2021-10-03 10:10:10',
  ),
  Activity(
    x: '4',
    y: '4',
    updatedAt: '2021-10-04 10:10:10',
  ),
  Activity(
    x: '5',
    y: '5',
    updatedAt: '2021-10-05 10:10:10',
  ),
];
List<Device> devices = [
  Device(
    deviceId: '01',
    deviceName: 'Tag 1',
    deviceAcStatus: 'Active',
    deviceLoStatus: 'In room',
    deviceImagePath: 'uwb.png',
    deviceLastUpdated: '2021-10-10 10:10:10',
  ),
  Device(
    deviceId: '02',
    deviceName: 'Tag 2',
    deviceAcStatus: 'Not Active',
    deviceLoStatus: 'In room',
    deviceImagePath: 'uwb.png',
    deviceLastUpdated: '2021-10-10 10:10:10',
  ),
  Device(
    deviceId: '03',
    deviceName: 'Tag 3',
    deviceAcStatus: 'Active',
    deviceLoStatus: 'Out room',
    deviceImagePath: 'uwb.png',
    deviceLastUpdated: '2021-10-10 10:10:10',
  ),
];

class ViewDeviceInfo extends StatefulWidget {
  final String deviceId;
  const ViewDeviceInfo({super.key, required this.deviceId});

  @override
  State<ViewDeviceInfo> createState() => _ViewDeviceInfoState();
}

class _ViewDeviceInfoState extends State<ViewDeviceInfo> {
  @override
  Widget build(BuildContext context) {
    final device =
    devices.firstWhere((element) => element.deviceId == widget.deviceId);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
            top: 20.0, bottom: 20, left: 10.0, right: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              // Device Image
              Align(
                alignment: Alignment.topCenter,
                child: Image(
                  image: AssetImage('assets/${device.deviceImagePath}'),
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 20),
              // Device Name
              Text(
                device.deviceName,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'lemon_milk',
                ),
              ),
              const SizedBox(height: 20),
              // Device General Information
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0, right: 20.0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'General',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Sandra',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  device.deviceAcStatus,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Last Updated',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  device.deviceLastUpdated,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Location',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  device.deviceLoStatus,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Device Activity History (Last 30 Days)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Activity History',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Sandra',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Table(
                              border: TableBorder.all(),
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(2),
                              },
                              children: [
                                const TableRow(
                                  children: [
                                    TableCell(
                                      child: Center(
                                        child: SizedBox(
                                          height: 30,
                                          child: Center(
                                            child: Text(
                                              'X',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: SizedBox(
                                          height: 30,
                                          child: Center(
                                            child: Text(
                                              'Y',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Center(
                                        child: SizedBox(
                                          height: 30,
                                          child: Center(
                                            child: Text(
                                              'Updated at',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (var activity in activities)
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Center(
                                          child: SizedBox(
                                            height: 30,
                                            child: Center(
                                              child: Text(activity.x),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: SizedBox(
                                            height: 30,
                                            child: Center(
                                              child: Text(activity.y),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: SizedBox(
                                            height: 30,
                                            child: Center(
                                              child: Text(activity.updatedAt),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.goNamed('MapOfRoom', queryParameters: {'deviceId': device.deviceId});
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Device Location on Map',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Sandra',
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
