class Profile {
  final String airlinkServerUrl;
  final String email;
  final String password;
  final String deviceProfileId;
  final String gatewayProfileId;

  Profile({
    required this.airlinkServerUrl,
    required this.email,
    required this.password,
    required this.deviceProfileId,
    required this.gatewayProfileId,
  });
}