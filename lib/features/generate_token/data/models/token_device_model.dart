import 'package:airlink/features/generate_token/domain/entities/token_device.dart';

class TokenDeviceModel extends TokenDevice {
  TokenDeviceModel({required super.deviceUuid, required super.numberOfDays, super.method = 'Add Credit'});

  static TokenDeviceModel fromEntity(TokenDevice tokenDevice) {
    return TokenDeviceModel(
      deviceUuid: tokenDevice.deviceUuid,
      numberOfDays: tokenDevice.numberOfDays,
      method: tokenDevice.method,
    );
  }

  @override
  String toString() => 'TokenDeviceModel(deviceUuid: $deviceUuid, numberOfDays: $numberOfDays, method: $method)';

}