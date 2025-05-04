import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uwb_app/network/device.dart';
import 'package:intl/intl.dart';
import 'package:uwb_app/network/mqtt.dart';
import 'package:provider/provider.dart';

class ViewDeviceInfo extends StatefulWidget {
  final String id;
  const ViewDeviceInfo({super.key, required this.id});

  @override
  State<ViewDeviceInfo> createState() => _ViewDeviceInfoState();
}

class _ViewDeviceInfoState extends State<ViewDeviceInfo> {
  late MqttService mqttService;
  late ValueNotifier<List<Device>> deviceList;
  late ValueNotifier<String> newUrl;
  final DeviceService deviceService = DeviceService();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initialize();
    startPeriodFetch();
  }

  Future<void> initialize() async {
    // Assign the provider to the variable
    mqttService = Provider.of<MqttService>(context, listen: false);
    deviceList =
        Provider.of<ValueNotifier<List<Device>>>(context, listen: false);
    newUrl = Provider.of<ValueNotifier<String>>(context, listen: false);
  }

  /*
    Refresh UI every 5 seconds
  */
  Future<void> startPeriodFetch() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      deviceList.value = List.from(deviceList.value);
    });
  }

  /*
    Check if two lists are not equal then refresh the page
  */
  Future<void> loadData() async {
    deviceList.value = await deviceService.fetchAllDevices(newUrl.value);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Info',
      home: RefreshIndicator(
        onRefresh: () async {
          loadData();
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(
                top: 20.0, bottom: 20, left: 10.0, right: 10.0),
            child: ValueListenableBuilder<List<Device>>(
              valueListenable: deviceList,
              builder: (context, devicesList, _) {
                // Find the device with the matching ID
                final device = devicesList.firstWhere(
                  (device) => device.id == widget.id,
                );

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            context.goNamed('Devices');
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Image(
                          image: AssetImage('assets/${device.img}'),
                          width: 120,
                          height: 120,
                        ),
                      ),
                      if (device.deviceType == 1)
                        Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String tempX =
                                          device.histories[0].x.toString();
                                      String tempY =
                                          device.histories[0].y.toString();
                                      final xController =
                                          TextEditingController(text: tempX);
                                      final yController =
                                          TextEditingController(text: tempY);
                                      return AlertDialog(
                                        title: Text(
                                          "Editing device ${device.name}",
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontFamily: 'Sandra',
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: xController,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    "x-value (in meters)",
                                              ),
                                              onChanged: (value) {
                                                tempX = value;
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: yController,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'y-value (in meters)',
                                              ),
                                              onChanged: (value) {
                                                tempY = value;
                                              },
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              var newData = {
                                                'name': device.name,
                                                'x': double.tryParse(tempX) ??
                                                    device.histories[0].x,
                                                'y': double.tryParse(tempY) ??
                                                    device.histories[0].y,
                                                'deviceType': device.deviceType,
                                                'location': device.location,
                                                'status': device.status,
                                              };
                                              device
                                                  .updateDeviceStatus(newData);
                                              mqttService.publish(
                                                  'edit_anchors',
                                                  "Update",
                                                  newData['name'],
                                                  newData['x'].toString(),
                                                  newData['y'].toString());
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  mqttService.publish("edit_anchors", "Delete",
                                      device.name, "0", "0");
                                  deviceList.value.removeWhere(
                                      (device) => device.id == widget.id);
                                  // refresh the device list
                                  context.goNamed('Devices');
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Device Name
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'lemon_milk',
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                    top: 10.0,
                                    bottom: 10.0,
                                    left: 10.0,
                                    right: 20.0),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Status',
                                          style: TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          device.status,
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Last Updated',
                                          style: TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          DateFormat.yMMMd()
                                              .format(device.updatedAt),
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Location',
                                          style: TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          device.location,
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        for (var activity in device.histories)
                                          TableRow(
                                            children: [
                                              TableCell(
                                                child: Center(
                                                  child: SizedBox(
                                                    height: 30,
                                                    child: Center(
                                                      child: Text(activity.x
                                                              ?.toString() ??
                                                          'N/A'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Center(
                                                  child: SizedBox(
                                                    height: 30,
                                                    child: Center(
                                                      child: Text(activity.y
                                                              ?.toString() ??
                                                          'N/A'),
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
                                                          DateFormat.yMMMd()
                                                              .format(activity
                                                                  .createdAt)),
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
                              context.goNamed('MapOfRoom',
                                  queryParameters: {'id': device.id});
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 10.0,
                                  right: 20.0),
                              // child: Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text(
                              //       'Device Location on Map',
                              //       style: TextStyle(
                              //         fontSize: 15,
                              //         fontFamily: 'Sandra',
                              //       ),
                              //     ),
                              //     Icon(Icons.arrow_forward_ios, size: 20),
                              //   ],
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
