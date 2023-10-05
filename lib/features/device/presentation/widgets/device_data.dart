import 'package:flutter/material.dart';

import '../../data/models/characteristic_model.dart';
import '../../data/models/device_model.dart';
import 'characteristic_button.dart';
import 'device_actions.dart';

class DeviceData extends StatelessWidget {
  const DeviceData({
    super.key,
    required this.connectedDevice,
  });

  final DeviceModel connectedDevice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DeviceActions(device: connectedDevice),
          const SizedBox(
            height: 24.0,
          ),
          const Text('Resources'),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: ListView.builder(
                itemCount:
                connectedDevice.characteristics.length,
                itemBuilder: (context, index) {
                  final c =
                  connectedDevice.characteristics[index];
                  return CharacteristicButton(
                    c: CharacteristicModel.fromEntity(c),
                  );
                }),
          ),
        ],
      ),
    );
  }
}