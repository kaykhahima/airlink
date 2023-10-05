import 'package:airlink/features/profile/domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.airlinkServerUrl,
    required super.email,
    required super.password,
    required super.deviceProfileId,
    required super.gatewayProfileId,
  });

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      airlinkServerUrl: profile.airlinkServerUrl,
      email: profile.email,
      password: profile.password,
      deviceProfileId: profile.deviceProfileId,
      gatewayProfileId: profile.gatewayProfileId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'airlinkServerUrl': airlinkServerUrl,
      'email': email,
      'password': password,
      'deviceProfileId': deviceProfileId,
      'gatewayProfileId': gatewayProfileId,
    };
  }

  static ProfileModel fromMap(profile) {
    return ProfileModel(
      airlinkServerUrl: profile['airlinkServerUrl'],
      email: profile['email'],
      password: profile['password'],
      deviceProfileId: profile['deviceProfileId'],
      gatewayProfileId: profile['gatewayProfileId'],
    );
  }

  @override
  String toString() {
    return 'airlinkServerUrl: $airlinkServerUrl, email: $email, password: $password, deviceProfileId: $deviceProfileId, gatewayProfileId: $gatewayProfileId';
  }
}
