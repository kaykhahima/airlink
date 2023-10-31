import 'dart:convert';
import 'dart:developer';

import 'package:airlink/core/api/airlink_api_service.dart';
import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/core/utils/enums/enums.dart';
import 'package:airlink/features/device/data/models/telemetry_model.dart';
import 'package:cbor/cbor.dart';
import 'package:hive/hive.dart';

import '../../../../../core/device_info/device_info.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/storage/storage.dart';
import '../../../../../core/utils/helper_functions.dart';
import '../../models/provisioned_device_model.dart';
import 'device_remote_data_source.dart';

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final AirLinkAPIService airlinkApiService;
  final NetworkInfo networkInfo;
  final SecureStorage secureStorage;
  final DeviceInfo deviceInfo;

  DeviceRemoteDataSourceImpl({
    required this.airlinkApiService,
    required this.networkInfo,
    required this.secureStorage,
    required this.deviceInfo,
  });

  //get profiles box
  final _profilesBox = Hive.box('profiles');

  //get telemetry box
  final _telemetryBox = Hive.box('telemetry');

  @override
  Future<void> postDevice(ProvisionedDeviceModel provisionedDeviceModel) async {
    if (await networkInfo.isConnected) {
      try {
        //get android device id
        final androidDeviceId = await deviceInfo.androidDeviceId;

        //get profile from box
        final profile = await _profilesBox.get(androidDeviceId);

        //device serial number
        int dNumber = provisionedDeviceModel.deviceSerialNumber;

        //payload
        Map<String, dynamic> body = {
          'name': dNumber,
          "type": "Devices Profile",
          "deviceProfileId": {
            "id": profile['deviceProfileId'],
            "entityType": "DEVICE_PROFILE"
          }
        };

        //get access token
        String? accessToken =
        await secureStorage.get('${dNumber}_access_token');

        //if access token is null, generate new one
        accessToken ??= generateSAT();

        //make api call to create device on the server
        final createDeviceRes = await airlinkApiService.createDevice(
            body: body, accessToken: accessToken);

        //check if device was provisioned successfully
        if (createDeviceRes.statusCode == 200) {
          //save access token
          await secureStorage.set('${dNumber}_access_token', accessToken);

          //get created device uuid
          final entityId = jsonDecode(createDeviceRes.body)['id']['id'];

          //save device secret and msg_id to server attributes
          final saveAttributesRes = await airlinkApiService
              .saveEntityAttributes(
              entityType: EntityType.device,
              entityId: entityId,
              scope: Scope.server,
              attributes: {
                'device_secret': provisionedDeviceModel.deviceSecret.toUpperCase(),
                'msg_id': 0,
                'payg_type': provisionedDeviceModel.type,
                'product_code': provisionedDeviceModel.productCode,
              });

          if (saveAttributesRes.statusCode == 200) {
            return;
          } else {
            throw const AirLinkFailure(message: 'Failed to save device secret');
          }
        } else {
          final errorResponse = jsonDecode(createDeviceRes.body);
          throw AirLinkFailure(message: '${errorResponse['message']}');
        }
      } catch (e) {
        throw AirLinkFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<List<dynamic>> getDeviceData(String deviceName) async {
    if (await networkInfo.isConnected) {
      try {
        //make api call to create device on the server
        final getTenantDeviceRes =
        await airlinkApiService.getTenantDevice(deviceName: deviceName);

        //decode the response
        final decodedResponse = jsonDecode(getTenantDeviceRes.body);

        //if status code is OK
        if (getTenantDeviceRes.statusCode == 200) {
          //get device uuid
          final deviceUuid = decodedResponse['id']['id'];

          //get shared attributes
          final getAttributesRes = await airlinkApiService.getAttributesByScope(
              entityType: EntityType.device,
              entityId: deviceUuid,
              scope: Scope.shared);

          //decode the response
          final decodedAttrResponse = jsonDecode(getAttributesRes.body);

          if (getAttributesRes.statusCode == 200) {
            //return body
            return decodedAttrResponse;
          } else {
            throw AirLinkFailure(message: decodedAttrResponse['message']);
          }
        } else {
          throw AirLinkFailure(message: decodedResponse['message']);
        }
      } catch (e) {
        throw AirLinkFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> postBLEData(TelemetryModel telemetryModel) async {
    if (await networkInfo.isConnected) {
      try {
        //make api call to create device on the server
        final getTenantDeviceRes = await airlinkApiService.getTenantDevice(
            deviceName: telemetryModel.deviceName);

        //decode the response
        final decodedResponse = jsonDecode(getTenantDeviceRes.body);

        //if status code is OK
        if (getTenantDeviceRes.statusCode == 200) {
          //get device uuid
          final deviceUuid = decodedResponse['id']['id'];

          //get shared attributes
          final postTelemetryRes = await airlinkApiService.saveTimeSeriesData(
            entityType: EntityType.device,
            entityId: deviceUuid,
            telemetryData: jsonDecode(telemetryModel.data.toString()),
          );


          if (postTelemetryRes.statusCode == 200) {
            return;
          } else {
            //decode the response
            final decodedAttrResponse = jsonDecode(postTelemetryRes.body);
            throw AirLinkFailure(message: decodedAttrResponse['message']);
          }
        } else {
          throw AirLinkFailure(message: decodedResponse['message']);
        }
      } catch (e, st) {
        log(e.toString());
        log(st.toString());
        throw AirLinkFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> postAdvertisementData() async {
    if (await networkInfo.isConnected) {
      //get gateway access token
      final gatewayAccessToken = await secureStorage.get(
          'gateway_access_token');

      if(gatewayAccessToken == null) {
        throw const AirLinkFailure(message: 'Gateway access token not found');
      }

      bool deviceKnown;

      //get advertisement data from local storage
      final telemetryData = _telemetryBox.toMap();
      for (var key in telemetryData.keys) {
        //check if key begins with 'advt'
        if (key.split('_')[0] == 'advt') {

          final deviceName = key.split('_')[1];

          //check if the gateway knows its access token
          final accessToken = await secureStorage.get('${deviceName}_access_token');

          //prepend keys with 'advt' eg. advt_123456789
          String jsonData = prepend(jsonEncode(telemetryData[key]), 'advt');

          // transform data into cbor value
          final deviceCborValue = CborValue(jsonData);

          final sendCborValue = CborValue(
            {
              'advt_adn': deviceName,
              'advt_tms': deviceCborValue,
            },
          );

          //if access token is not null, device is known
          deviceKnown = accessToken != null;

          //set contents based on whether device is known or not
          String contents = deviceKnown
              ? const CborJsonEncoder().convert(deviceCborValue)
              : const CborJsonEncoder().convert(sendCborValue);

          //make api call to post advt data
          final postAdvtDataRes = await airlinkApiService.postTelemetry(
              accessToken: gatewayAccessToken, telemetryData: jsonDecode(contents));

          if(postAdvtDataRes.statusCode == 200) {
            return;
          }
          else {
            //decode body
            final decodedResponse = jsonDecode(postAdvtDataRes.body);
            throw AirLinkFailure(message: decodedResponse['message']);
          }
        }
      }
    }
    else {
      throw const NetworkFailure(message: 'No internet connection');
    }
  }
}
