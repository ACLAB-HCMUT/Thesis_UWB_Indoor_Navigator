import 'package:flutter/material.dart';

class ViewMap extends StatefulWidget {
  final String? id;
  const ViewMap({super.key, this.id});

  @override
  State<ViewMap> createState() => _ViewMap();
}

class _ViewMap extends State<ViewMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Map of room ${widget.id}')
      ),
    );
  }
}