import 'package:airlink/core/utils/enums/enums.dart';
import 'package:airlink/features/device/data/models/device_model.dart';
import 'package:airlink/features/device/presentation/widgets/input_field.dart';
import 'package:airlink/features/device/presentation/widgets/provision_selection_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import 'action_button.dart';
import 'input_payg_token_dialog.dart';

class DeviceActions extends StatefulWidget {
  const DeviceActions({super.key, required this.device});

  final DeviceModel device;

  @override
  State<DeviceActions> createState() => _DeviceActionsState();
}

class _DeviceActionsState extends State<DeviceActions> {
  final TextEditingController _accessTokenController = TextEditingController();

  late DeviceProvider deviceProvider;

  final Sync _selectedSync = Sync.serverToPhone;

  @override
  void initState() {
    super.initState();
    deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    _getAccessToken();
  }

  //get access token from device and set it to the text field
  Future<void> _getAccessToken() async {
    String? accessToken = await deviceProvider.getAccessToken(
      context: context,
      deviceModel: widget.device,
    );

    if (accessToken != null) {
      setState(() {
        _accessTokenController.text = accessToken;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _accessTokenController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildManufacturerActionsCard(context),
        buildDeviceUserActionsCard(context),
      ],
    );
  }

  Card buildManufacturerActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manufacturer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InputField(
                    controller: _accessTokenController,
                    labelText: 'Access token',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ActionButton(
                    onPressed: () => deviceProvider.authorize(
                      context: context,
                      device: widget.device,
                    ),
                    label: 'Authorize',
                  ),
                ),
                //if device is already provisioned, don't show the provision button
                widget.device.advertisementPacket.pst <= 3
                    ? Expanded(
                        flex: 2,
                        child: ActionButton(
                          onPressed: () => _showProvisionChoices(
                              ctx: context, device: widget.device),
                          label: 'Provision',
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card buildDeviceUserActionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device User',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12.0),
            const Text('Sync'),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SegmentedButton(
                      selected: <Sync>{_selectedSync},
                      showSelectedIcon: false,
                      segments: <ButtonSegment<Sync>>[
                        ButtonSegment(
                            label: GestureDetector(
                              onTap: () {
                                deviceProvider.serverAndGatewaySync(
                                    context: context,
                                    deviceName: widget
                                        .device.advertisementPacket.did
                                        .toString());
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.cloud,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  Icon(
                                    Icons.sync_alt,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  Icon(
                                    Icons.phone_android,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                            value: Sync.serverToPhone,
                            tooltip: 'Server - Phone Sync'),
                        ButtonSegment(
                          label: GestureDetector(
                            onTap: () {
                              deviceProvider.gatewayAndDeviceSync(
                                context: context,
                                deviceName: widget
                                    .device.advertisementPacket.did
                                    .toString(),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  Icons.phone_android,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                Icon(
                                  Icons.sync_alt,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                Icon(
                                  Icons.memory,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ],
                            ),
                          ),
                          value: Sync.phoneToDevice,
                          tooltip: 'Phone - BLE Device Sync',
                        ),
                      ],
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primary),
                        side: MaterialStateProperty.all(
                          BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ActionButton(
                    onPressed: () {
                      _showPayGTokenInputDialog(context);
                    },
                    label: 'Transfer PayG Token',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProvisionChoices(
      {required BuildContext ctx, required DeviceModel device}) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) => ProvisionChoicesBottomSheet(
        deviceModel: device,
        ctx: ctx,
      ),
    );
  }

  void _showPayGTokenInputDialog(BuildContext ctx) {
    //show dialog to enter serial number
    showDialog(
      context: context,
      builder: (context) => InputPayGTokenDialog(ctx: ctx),
    );
  }
}
