import 'package:airlink/features/generate_token/presentation/pages/generate_token_page.dart';
import 'package:airlink/features/profile/presentation/pages/profile_page.dart';
import 'package:airlink/providers.dart';
import 'package:airlink/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'core/background_tasks/background_tasks.dart';
import 'features/device/data/data_sources/remote/device_remote_data_source_impl.dart';
import 'features/device/presentation/pages/device_list_page.dart';
import 'features/device/presentation/providers/device_provider.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  //Handles background tasks when called
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'postAdvertData') {
      if (kDebugMode) {
        print("Background task called: $taskName");
      }
      //initialize service locator
      initializeDependencies();

      //Initializes Hive
      await Hive.initFlutter();

      //open boxes
      //storing device profile data: username, pwd, gatewayDeviceId
      await Hive.openBox('profiles');

      //store telemetry data from the BLE Device
      await Hive.openBox('telemetry');

      //post advt data
      await sl<DeviceRemoteDataSourceImpl>().postAdvertisementData();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initializes Workmanager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  //Initializes Hive
  await Hive.initFlutter();

  //open boxes
  //storing device profile data: username, pwd, gatewayDeviceId
  await Hive.openBox('profiles');

  //storing angaza credentials: username, pwd
  await Hive.openBox('angaza_credentials');

  //store telemetry data from the BLE Device
  await Hive.openBox('telemetry');

  //stores attributes data from the server
  await Hive.openBox('attributes');

  //initialize service locator
  initializeDependencies();

  //load .env file
  await dotenv.load(fileName: ".env");

  //run background task
  postAdvtData();

  //run app
  runApp(MultiProvider(providers: providers, child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: MediaQuery.of(context).platformBrightness,
        colorSchemeSeed: const Color(0xFF1B75BA),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DeviceProvider deviceProvider;

  int _selectedIndex = 1;
  static const List<Widget> _widgetOptions = <Widget>[
    GenerateTokenPage(),
    DeviceListPage(),
    CredentialsPage(),
  ];

  final List<String> _titles = <String>[
    'Distributor/Tenant Admin',
    'Device User/Admin',
    'Credentials',
  ];

  void _onItemTapped(int index) {
    _selectedIndex = index;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles.elementAt(_selectedIndex)),
      ),
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.toll),
            label: 'PayG Token',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.memory),
            label: 'Device List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Credentials',
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Start scanning
                await deviceProvider
                    .clearDevices()
                    .then((_) => deviceProvider.getDevices(context: context));
              },
              icon: const Icon(Icons.change_circle_rounded),
              label: const Text('Scan'),
            )
          : null,
    );
  }
}
