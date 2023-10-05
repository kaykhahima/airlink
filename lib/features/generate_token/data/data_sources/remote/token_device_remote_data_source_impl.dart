import 'dart:convert';
import 'dart:developer';

import 'package:airlink/core/errors/failures.dart';
import 'package:airlink/core/network/network_info.dart';
import 'package:airlink/features/generate_token/data/data_sources/remote/token_device_remote_data_source.dart';
import 'package:airlink/features/generate_token/data/models/device_suggestion_model.dart';
import 'package:airlink/features/generate_token/data/models/token_device_model.dart';

import '../../../../../core/api/api_service.dart';

class TokenDeviceRemoteDataSourceImpl implements TokenDeviceRemoteDataSource {
  final NetworkInfo networkInfo;
  final AirLinkAPIService airLinkAPIService;

  TokenDeviceRemoteDataSourceImpl(
      {required this.networkInfo, required this.airLinkAPIService});

  @override
  Future<String> generateToken(TokenDeviceModel tokenDeviceModel) async {
    if (await networkInfo.isConnected) {
      try {
        //payload
        final body = {
          'method': tokenDeviceModel.method,
          'credit': tokenDeviceModel.numberOfDays,
        };

        //send request to generate token
        final generateTokenRes = await airLinkAPIService.generateToken(
          deviceUuid: tokenDeviceModel.deviceUuid,
          body: body,
        );

        //check if response is successful and return token
        if (generateTokenRes.statusCode == 200) {
          //decode response body
          final decodedResponse = jsonDecode(generateTokenRes.body);
          final token = decodedResponse['token'];
          return token;
        } else {
          throw AirLinkFailure(
              message: generateTokenRes.body.isEmpty
                  ? 'Something went wrong'
                  : generateTokenRes.body);
        }
      } catch (e) {
        log(e.toString());
        throw AirLinkFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No Internet Connection');
    }
  }

  @override
  Future<List<DeviceSuggestionModel>> getDevicesByQuery(
      String deviceName) async {
    if (await networkInfo.isConnected) {
      try {
        final body = {
          'entityFilter': {
            'type': 'entityName',
            'entityType': 'DEVICE',
            'entityNameFilter': deviceName
          },
          'entityFields': [
            {'type': 'ENTITY_FIELD', 'key': 'name'}
          ],
          'latestValues': [
            {'type': 'ATTRIBUTE', 'key': 'payg_type'},
            {'type': 'ATTRIBUTE', 'key': 'PAYG_Type'}
          ],
          'pageLink': {
            'page': 0,
            'pageSize': 10,
            'sortOrder': {
              'key': {'key': 'name', 'type': 'ENTITY_FIELD'},
              'direction': 'ASC'
            }
          }
        };

        //send request to get devices by query
        final getDevicesByQueryRes =
            await airLinkAPIService.findEntityDataByQuery(body: body);

        //check if response is successful and return list of devices
        if (getDevicesByQueryRes.statusCode == 200) {

          //decode response body
          final decodedResponse = jsonDecode(getDevicesByQueryRes.body);
          final devices = decodedResponse['data'] as List;
          return devices
              .map((device) => DeviceSuggestionModel.fromJson(device))
              .toList();
        } else {
          throw const AirLinkFailure(message: 'Something went wrong');
        }
      } catch (e, st) {
        log(e.toString());
        log(st.toString());
        throw AirLinkFailure(message: e.toString());
      }
    } else {
      throw const NetworkFailure(message: 'No Internet Connection');
    }
  }
}
