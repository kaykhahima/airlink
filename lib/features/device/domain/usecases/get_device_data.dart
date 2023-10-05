import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/repositories/device_repository.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

class GetDeviceData implements UseCase<List<dynamic>, String> {
  final DeviceRepository _repository;

  GetDeviceData(this._repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(String deviceName) async {
    return await _repository.getDeviceData(deviceName);
  }
}
