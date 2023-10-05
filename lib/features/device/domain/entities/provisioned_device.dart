class ProvisionedDevice {
  final int deviceSerialNumber;
  final String type;
  final String deviceSecret;

  ProvisionedDevice({
    required this.deviceSerialNumber,
    required this.type,
    required this.deviceSecret,
  });
}