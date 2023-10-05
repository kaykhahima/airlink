import 'package:workmanager/workmanager.dart';

postAdvtData() async {
  await Workmanager().registerPeriodicTask(
    'postAdvertData',
    'postAdvertData',
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 3),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: true,
    ),
  );
}