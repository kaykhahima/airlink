import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/entities/advertisement_packet.dart';
import 'package:airlink/features/device/domain/entities/device.dart';
import 'package:airlink/features/device/domain/entities/provisioned_device.dart';
import 'package:airlink/features/device/domain/entities/telemetry.dart';
import 'package:dartz/dartz.dart';

abstract class DeviceRepository {
  /// Returns a list of BLE devices
  Future<Either<Failure, List<Device>>> getBLEDevices();

  /// Connects to a BLE device
  Future<Either<Failure, Device>> connectToDevice(Device bleDevice);

  /// Disconnects from a BLE device
  Future<Either<Failure, void>> disconnectDevice(Device bleDevice);

  /// Authorize from a BLE device
  Future<Either<Failure, void>> authorizeDevice(Device bleDevice);

  /// Read from a characteristic
  Future<Either<Failure, String>> readCharacteristic(String characteristicUUID);

  /// Write to a characteristic
  Future<Either<Failure, void>> writeCharacteristic(String characteristicUUID, Map<String, dynamic> data);

  /// Connects to a BLE device
  Future<Either<Failure, void>> provisionDevice(ProvisionedDevice device);

  /// Get Device Access Token
  Future<Either<Failure, String?>> getDeviceAccessToken(Device bleDevice);

  /// Transfer PayG Token
  Future<Either<Failure, void>> transferToken(String payGToken);

  /// Get Data from Server to local DB
  Future<Either<Failure, List<dynamic>>> getDeviceData(String deviceName);

  /// Save Data from Server to local DB
  Future<Either<Failure, void>> saveDeviceData(String deviceName, List data);

  /// Push device data from local DB to BLE Device
  Future<Either<Failure, void>> pushDeviceData(String deviceName);

  /// Upload BLE Device data to server as timeseries
  Future<Either<Failure, void>> uploadBLEDeviceData(Telemetry telemetry);

  /// Save Advertisement data
  Future<Either<Failure, void>> saveAdvertisementData(AdvertisementPacket advertisementPacket);

  /// Post Advertisement data
  Future<Either<Failure, void>> postAdvertisementData();

}
