import 'package:airlink/core/api/base_api_client.dart';
import 'package:airlink/core/device_info/device_info.dart';
import 'package:airlink/features/device/data/repositories/ble_device_repository_impl.dart';
import 'package:airlink/features/device/domain/usecases/authorize_device.dart';
import 'package:airlink/features/device/domain/usecases/connect_to_ble_device.dart';
import 'package:airlink/features/device/domain/usecases/disconnect_ble_device.dart';
import 'package:airlink/features/device/domain/usecases/get_ble_devices.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/api/api_service.dart';
import 'core/bluetooth/bluetooth_info.dart';
import 'core/environment/dot_env.dart';
import 'core/location/location_info.dart';
import 'core/network/network_info.dart';
import 'core/storage/storage.dart';
import 'features/device/data/data_sources/local/ble_device_local_data_source_impl.dart';
import 'features/device/data/data_sources/remote/device_remote_data_source_impl.dart';
import 'features/device/domain/usecases/get_device_access_token.dart';
import 'features/device/domain/usecases/get_device_data.dart';
import 'features/device/domain/usecases/post_advertisement_data.dart';
import 'features/device/domain/usecases/provision_device.dart';
import 'features/device/domain/usecases/push_device_data.dart';
import 'features/device/domain/usecases/read_characteristic.dart';
import 'features/device/domain/usecases/save_advertisement_data.dart';
import 'features/device/domain/usecases/transfer_payg_token.dart';
import 'features/device/domain/usecases/upload_ble_data.dart';
import 'features/device/domain/usecases/write_characteristic.dart';
import 'features/device/presentation/providers/device_provider.dart';
import 'features/generate_token/data/data_sources/remote/token_device_remote_data_source_impl.dart';
import 'features/generate_token/data/repositories/token_device_repository_impl.dart';
import 'features/generate_token/domain/usecases/generate_token.dart';
import 'features/generate_token/domain/usecases/get_device_suggestion.dart';
import 'features/generate_token/presentation/providers/token_device_provider.dart';
import 'features/profile/data/data_sources/local/profile_local_data_source_impl.dart';
import 'features/profile/data/data_sources/remote/profile_remote_data_source_impl.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_gateway_device_id.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/provision_gateway.dart';
import 'features/profile/presentation/provider/profile_provider.dart';

final sl = GetIt.instance;

void initializeDependencies() {
  //get instance of connection checker
  final connectionChecker = InternetConnectionChecker();

  //get instance of DeviceInfoPlugin
  final deviceInfoPlugin = DeviceInfoPlugin();

  //get instance of NetworkInfo
  final networkInfo = NetworkInfoImpl(connectionChecker);

  //get instance of DeviceInfo
  final deviceInfo = DeviceInfoImpl(deviceInfoPlugin);

  //get instance of BluetoothInfo
  final bluetoothInfo = BluetoothInfoImpl();

  //get instance of LocationInfo
  final locationInfo = LocationInfoImpl();

  //get instance of BaseAPIService
  final apiService = BaseApiService();

  //get instance of AirLink API Service
  final airlinkApiService = AirLinkAPIService(apiService);

  //get environment
  final environment = EnvironmentImpl();

  //get secure storage
  final secureStorage = SecureStorageImpl();

  //register secure storage
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  //get instance of ProfileLocalDataSource
  final localProfileDataSource = ProfileLocalDataSourceImpl(
      deviceInfo: deviceInfo, secureStorage: secureStorage);

  //get instance of ProfileRemoteDataSource
  final remoteProfileDataSource = ProfileRemoteDataSourceImpl(
      deviceInfo: deviceInfo,
      networkInfo: networkInfo,
      secureStorage: secureStorage,
      airlinkApiService: airlinkApiService);

  //register profile local data source
  sl.registerLazySingleton<ProfileLocalDataSourceImpl>(
      () => localProfileDataSource);

  //get instance of profile repository
  final profileRepository = ProfileRepositoryImpl(
      remoteDataSource: remoteProfileDataSource,
      localDataSource: localProfileDataSource);

  //get instance of profile usecases
  final getProfile = GetProfile(profileRepository);
  final provisionGateway = ProvisionGateway(profileRepository);
  final getGatewayDeviceId = GetGatewayDeviceId(profileRepository);

  //register profile provider
  sl.registerLazySingleton<ProfileProvider>(() => ProfileProvider(
        provisionGateway: provisionGateway,
        getProfile: getProfile,
        getGatewayDeviceId: getGatewayDeviceId,
      ));

  //create an instance of the ble device data source
  final deviceLocalDataSource = BLEDeviceLocalDataSourceImpl(
    bluetoothInfo: bluetoothInfo,
    locationInfo: locationInfo,
    environment: environment,
    secureStorage: secureStorage,
  );

  final deviceRemoteDataSource = DeviceRemoteDataSourceImpl(
    airlinkApiService: airlinkApiService,
    networkInfo: networkInfo,
    secureStorage: secureStorage,
    deviceInfo: deviceInfo,
  );

  //register remote data source
  sl.registerLazySingleton<DeviceRemoteDataSourceImpl>(
      () => DeviceRemoteDataSourceImpl(
            airlinkApiService: airlinkApiService,
            networkInfo: networkInfo,
            secureStorage: secureStorage,
            deviceInfo: deviceInfo,
          ));

  //register local data source
  sl.registerLazySingleton<BLEDeviceLocalDataSourceImpl>(
      () => deviceLocalDataSource);

  //create an instance of the device repo
  final deviceRepository =
      DeviceRepositoryImpl(deviceLocalDataSource, deviceRemoteDataSource);

  //register ble device provider
  sl.registerLazySingleton<DeviceProvider>(() => DeviceProvider(
        getBLEDevices: GetBLEDevices(deviceRepository),
        connectToBLEDevice: ConnectToBLEDevice(deviceRepository),
        disconnectBLEDevice: DisconnectBLEDevice(deviceRepository),
        authorizeDevice: AuthorizeDevice(deviceRepository),
        readCharacteristic: ReadCharacteristic(deviceRepository),
        writeCharacteristic: WriteCharacteristic(deviceRepository),
        provisionDevice: ProvisionDevice(deviceRepository),
        getDeviceAccessToken: GetDeviceAccessToken(deviceRepository),
        transferPayGToken: TransferPayGToken(deviceRepository),
        getDeviceData: GetDeviceData(deviceRepository),
        pushDeviceData: PushDeviceData(deviceRepository),
        uploadBLEData: UploadBLEData(deviceRepository),
        saveAdvertisementData: SaveAdvertisementData(deviceRepository),
        postAdvertisementData: PostAdvertisementData(deviceRepository),
      ));

  final tokenDeviceRepository = TokenDeviceRepositoryImpl(
    tokenDeviceDataSource: TokenDeviceRemoteDataSourceImpl(
      networkInfo: networkInfo,
      airLinkAPIService: airlinkApiService,
    ),
  );

  //register TokenDeviceProvider
  sl.registerLazySingleton<TokenDeviceProvider>(() => TokenDeviceProvider(
    generateToken: GenerateToken(tokenDeviceRepository),
    getDeviceSuggestion: GetDeviceSuggestion(tokenDeviceRepository),
  ));
}
