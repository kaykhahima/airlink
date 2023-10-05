import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

class PushDeviceData implements UseCase<void, String> {
  final DeviceRepository _repository;

  PushDeviceData(this._repository);

  @override
  Future<Either<Failure, void>> call(String deviceName) async {
    return await _repository.pushDeviceData(deviceName);
  }
}
