import 'package:airlink/features/device/data/models/advertisement_packet_model.dart';
import 'package:airlink/features/device/data/models/device_model.dart';

import '../../models/provisioned_device_model.dart';

abstract class DeviceLocalDataSource {
  /// Returns a list of BLE devices
  Future<List<DeviceModel>> getBLEDevices();

  /// Connects to a BLE device
  Future<DeviceModel> connectToDevice(DeviceModel deviceModel);

  /// Disconnects from a BLE device
  Future<void> disconnectDevice(DeviceModel deviceModel);

  /// Authorize a BLE device for read/write operations
  Future<void> authorizeDevice(DeviceModel deviceModel);

  /// Read from a characteristic
  Future<String> readCharacteristic(String characteristicUUID);

  /// Write to a characteristic
  Future<void> writeCharacteristic(String characteristicUUID, Map<String, dynamic> data);

  /// Serializes the BLE device
  Future<void> serializeDevice(ProvisionedDeviceModel provisionedDeviceModel);

  /// Get Device Access Token
  Future<String?> getDeviceAccessToken(DeviceModel bleDevice);

  /// Transfer PayG Token
  Future<void> transferToken(String payGToken);

  /// Push device data from local DB to BLE Device
  Future<void> pushDeviceData(String deviceName);

  /// Push device data from local DB to BLE Device
  Future<void> saveDeviceData(String deviceName, List<dynamic> data);

  /// Get BLE Device data
  Future<List> getBLEDeviceData();

  /// Save advertisement data
  Future<void> saveAdvertisementData(AdvertisementPacketModel advertisementPacketModel);
}