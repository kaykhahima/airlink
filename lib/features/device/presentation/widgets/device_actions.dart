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
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: ActionButton(
                onPressed: () => deviceProvider.authorize(
                  context: context,
                  device: widget.device,
                ),
                label: 'Authorize',
              ),
            ),
            Expanded(
              flex: 4,
              child: InputField(
                controller: _accessTokenController,
                labelText: 'Access token',
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: ActionButton(
                onPressed: () => _showProvisionChoices(
                    ctx: context, device: widget.device),
                label: 'Provision',
              ),
            ),
            Expanded(
              flex: 4,
              child: ActionButton(
                onPressed: () {
                  _showPayGTokenInputDialog(context);
                },
                label: 'Transfer PayG Token',
              ),
            ),
          ],
        ),
        const Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Sync'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 3.0, vertical: 8.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.cloud,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              Icon(
                                Icons.sync_alt,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              Icon(
                                Icons.phone_android,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                        value: Sync.serverToPhone,
                        tooltip: 'Server to Phone'),
                    ButtonSegment(
                      label: GestureDetector(
                        onTap: () {
                          deviceProvider.gatewayAndDeviceSync(
                            context: context,
                            deviceName: widget.device.advertisementPacket.did
                                .toString(),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.phone_android,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            Icon(
                              Icons.sync_alt,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            Icon(
                              Icons.memory,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                      value: Sync.phoneToDevice,
                      tooltip: 'Phone to BLE Device',
                    ),
                    // ButtonSegment(
                    //   label: GestureDetector(
                    //     onTap: () {
                    //       final telemetryModel = TelemetryModel(
                    //           deviceName: widget.device.advertisementPacket.did
                    //               .toString());
                    //       deviceProvider.uploadBLEDeviceData(
                    //           context: context, telemetryModel: telemetryModel);
                    //     },
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         Icon(
                    //           Icons.memory,
                    //           color: Theme.of(context).colorScheme.onPrimary,
                    //         ),
                    //         Icon(
                    //           Icons.arrow_right_alt,
                    //           color: Theme.of(context).colorScheme.onPrimary,
                    //         ),
                    //         Icon(
                    //           Icons.cloud,
                    //           color: Theme.of(context).colorScheme.onPrimary,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   value: Sync.deviceToServer,
                    //   tooltip: 'BLE Device to Server',
                    // ),
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
      ],
    );
  }

  void _showProvisionChoices(
      {required BuildContext ctx, required DeviceModel device}) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) => ProvisionChoicesBottomSheet(
        deviceModel: device, ctx: ctx,
      ),
    );
  }

  void _showPayGTokenInputDialog(BuildContext ctx) {
    //show dialog to enter serial number
    showDialog(
      context: context,
      builder: (context) =>  InputPayGTokenDialog(ctx: ctx),
    );
  }
}
