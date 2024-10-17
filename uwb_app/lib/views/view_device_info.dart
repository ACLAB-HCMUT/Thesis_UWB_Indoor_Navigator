import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uwb_app/network/device.dart';
import 'package:intl/intl.dart';

class ViewDeviceInfo extends StatefulWidget {
  final String id;
  const ViewDeviceInfo({super.key, required this.id});

  @override
  State<ViewDeviceInfo> createState() => _ViewDeviceInfoState();
}

class _ViewDeviceInfoState extends State<ViewDeviceInfo> {
  late Future<Device> device;
  final DeviceService deviceService = DeviceService();
  @override
  void initState() {
    super.initState();
    device = deviceService.fetchDeviceById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(
              top: 20.0, bottom: 20, left: 10.0, right: 10.0),
          child: FutureBuilder<Device>(
              future: device,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No device found'));
                }
                final device = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                );
              })),
    );
  }
}
