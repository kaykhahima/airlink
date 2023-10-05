import 'package:airlink/features/device/data/models/device_model.dart';
import 'package:airlink/features/device/presentation/widgets/barcode_scanner_dialog.dart';
import 'package:flutter/material.dart';

import 'input_serial_number_dialog.dart';

class ProvisionChoicesBottomSheet extends StatefulWidget {
  const ProvisionChoicesBottomSheet({super.key, required this.deviceModel, required this.ctx});

  final DeviceModel deviceModel;
  final BuildContext ctx;

  @override
  State<ProvisionChoicesBottomSheet> createState() =>
      _ProvisionChoicesBottomSheetState();
}

class _ProvisionChoicesBottomSheetState
    extends State<ProvisionChoicesBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select your choice',
              ),
              IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close,
                ),
              )
            ],
          ),
        ),
        const Divider(
          height: 1.0,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.barcode_reader)),
              title: const Text(
                'Scan Barcode',
              ),
              subtitle: const Text(
                'Scans the barcode on your device and automatically provisions it.',
              ),
              onTap: () async {
                //dismiss previous dialog
                Navigator.pop(context);
                _showBarcodeDialog(context: context);
              },
            ),
            const SizedBox(height: 10.0),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.keyboard),
              ),
              title: const Text(
                'Type serial number',
              ),
              subtitle: const Text(
                'Enter the name of the device you want to provision.',
              ),
              onTap: () async {
                Navigator.of(context).pop();
                _showSerialNumberInputDialog();
              },
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ],
    );
  }

  void _showBarcodeDialog({required BuildContext context}) {
    //show dialog to scan barcode
    showDialog(
        context: context,
        builder: (context) => BarcodeScannerDialog(ctx: widget.ctx,));
  }

  void _showSerialNumberInputDialog() {
    //show dialog to enter serial number
    showDialog(
        context: context,
        builder: (context) => InputSerialNumberDialog(ctx: widget.ctx,));
  }

}
