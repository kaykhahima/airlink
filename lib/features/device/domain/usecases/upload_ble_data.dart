import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/entities/telemetry.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

class UploadBLEData implements UseCase<void, Telemetry> {
  final DeviceRepository _repository;

  UploadBLEData(this._repository);

  @override
  Future<Either<Failure, void>> call(Telemetry telemetry) async {
    return await _repository.uploadBLEDeviceData(telemetry);
  }
}
