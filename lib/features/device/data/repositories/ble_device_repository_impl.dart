import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/data/models/telemetry_model.dart';
import 'package:airlink/features/device/domain/entities/advertisement_packet.dart';
import 'package:airlink/features/device/domain/entities/device.dart';
import 'package:airlink/features/device/domain/entities/telemetry.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/provisioned_device.dart';
import '../data_sources/local/ble_device_local_data_source.dart';
import '../data_sources/remote/device_remote_data_source.dart';
import '../models/advertisement_packet_model.dart';
import '../models/device_model.dart';
import '../models/provisioned_device_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource _localDataSource;
  final DeviceRemoteDataSource _remoteDataSource;

  DeviceRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, Device>> connectToDevice(Device bleDevice) async {
    try {
      final device = await _localDataSource.connectToDevice(DeviceModel.fromEntity(bleDevice));
      return Right(device);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectDevice(Device bleDevice) async {
    try {
      await _localDataSource.disconnectDevice(DeviceModel.fromEntity(bleDevice));
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Device>>> getBLEDevices() async {
    try {
      final bleDevices = await _localDataSource.getBLEDevices();
      return Right(bleDevices);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }


  @override
  Future<Either<Failure, void>> authorizeDevice(Device bleDevice) async {
    try {
      await _localDataSource.authorizeDevice(DeviceModel.fromEntity(bleDevice));
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> readCharacteristic(String characteristicUUID) async {
    try {
      final value = await _localDataSource.readCharacteristic(characteristicUUID);
      return Right(value);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> writeCharacteristic(String characteristicUUID, Map<String, dynamic> data) async {
    try {
      await _localDataSource.writeCharacteristic(characteristicUUID, data);
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> provisionDevice(ProvisionedDevice provisionedDevice) async {
    try {
      await _remoteDataSource.postDevice(ProvisionedDeviceModel.fromEntity(provisionedDevice));
      await _localDataSource.serializeDevice(ProvisionedDeviceModel.fromEntity(provisionedDevice));
      return const Right(null);
    } catch (e) {
      if(e is AirLinkFailure) {
        return Left(AirLinkFailure(message: e.toString()));
      }
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getDeviceAccessToken(Device bleDevice) async {
    try {
      final accessToken = await _localDataSource.getDeviceAccessToken(DeviceModel.fromEntity(bleDevice));
      return Right(accessToken);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> transferToken(String payGToken) async {
    try {
      await _localDataSource.transferToken(payGToken);
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getDeviceData(String deviceName) async {
    try {
      final data = await _remoteDataSource.getDeviceData(deviceName);
      await saveDeviceData(deviceName, data);
      return Right(data);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> pushDeviceData(String deviceName) async {
    try {
      await _localDataSource.pushDeviceData(deviceName);
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDeviceData(String deviceName, List<dynamic> data) async {
    try {
      await _localDataSource.saveDeviceData(deviceName, data);
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadBLEDeviceData(Telemetry telemetry) async {
    try {
      //get BLE data
      final data = await _localDataSource.getBLEDeviceData();

      //add data to telemetry model
      final telemetryModel = TelemetryModel(deviceName: telemetry.deviceName, data: data);

      //post data to server
      await _remoteDataSource.postBLEData(telemetryModel);
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAdvertisementData(AdvertisementPacket advertisementPacket) async {
    try {
      await _localDataSource.saveAdvertisementData(AdvertisementPacketModel.fromEntity(advertisementPacket));
      return const Right(null);
    } catch (e) {
      return Left(BLEDeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> postAdvertisementData() async {
    try {
      await _remoteDataSource.postAdvertisementData();
      return const Right(null);
    } catch (e) {
      return Left(AirLinkFailure(message: e.toString()));
    }
  }
}
