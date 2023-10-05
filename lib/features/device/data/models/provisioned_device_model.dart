import 'package:airlink/features/device/domain/entities/provisioned_device.dart';

class ProvisionedDeviceModel extends ProvisionedDevice {
  ProvisionedDeviceModel({required super.deviceSerialNumber, required super.type, required super.deviceSecret,});

  factory ProvisionedDeviceModel.fromEntity(ProvisionedDevice provisionedDevice) {
    return ProvisionedDeviceModel(
      deviceSerialNumber: provisionedDevice.deviceSerialNumber,
      type: provisionedDevice.type,
      deviceSecret: provisionedDevice.deviceSecret,
    );
  }

  //copyWith method
  ProvisionedDeviceModel copyWith({
    int? deviceSerialNumber,
    String? type,
    String? deviceSecret,
  }) {
    return ProvisionedDeviceModel(
      deviceSerialNumber: deviceSerialNumber ?? this.deviceSerialNumber,
      type: type ?? this.type,
      deviceSecret: deviceSecret ?? this.deviceSecret,
    );
  }

  @override
  toString() => 'deviceSerialNumber: $deviceSerialNumber, type: $type, deviceSecret: $deviceSecret';

}