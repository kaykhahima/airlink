import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/features/device/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/device_repository.dart';

class SyncServerAndGateway implements UseCase<void, String> {
  final DeviceRepository _repository;

  SyncServerAndGateway(this._repository);

  @override
  Future<Either<Failure, void>> call(String deviceName) async {
    return await _repository.serverAndGatewaySync(deviceName);
  }

}