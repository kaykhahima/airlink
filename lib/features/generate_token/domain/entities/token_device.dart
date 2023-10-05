class TokenDevice {
  /// The method of token to be generated. Default is Add Credit.
  /// E.g. Add Credit, Set Credit, Unlock PAYG.
  final String method;

  /// The device uuid of the device to be added credit to.
  final String deviceUuid;

  /// The number of days to be added to the device.
  final int numberOfDays;

  TokenDevice({
    this.method = 'Add Credit',
    required this.deviceUuid,
    required this.numberOfDays,
  });
}