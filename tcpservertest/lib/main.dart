import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tcpservertest/common/SharedPrefs.dart';
import 'package:tcpservertest/common/theme_provider.dart';
import 'package:tcpservertest/tcp_home.dart';
import 'package:tcpservertest/udp_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  final InputBorder inputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide.none,
  );
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(isDark: SharedPrefs().themeMode),
      child: Selector<ThemeProvider, bool>(
          selector: (p0, p1) => p1.isDark,
          builder: (_, isDark, child) {
            return DynamicColorBuilder(
                builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              final darkTheme = ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: darkDynamic?.primary ?? Colors.red,
                      brightness: Brightness.dark),
                  scaffoldBackgroundColor: Colors.blueGrey.shade900,
                  useMaterial3: true);
              final themeData = ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: darkDynamic?.primary ?? Colors.red),
                  scaffoldBackgroundColor: Colors.grey.shade200,
                  useMaterial3: true);
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'TCP',
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                theme: themeData,
                darkTheme: darkTheme,
                home: const HomePage(title: 'UDP Listener'),
              );
            });
          }),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ServerSocket? server;
  SharedPrefs sharedPrefs = SharedPrefs();
  var ips = <String>[];
  var serverUpdate = ValueNotifier('Empty');
  var statusUpdate = <String>[];
  @override
  void initState() {
    NetworkInfo().getWifiIP().then((value) {
      ips.add(value ?? 'null');
      serverUpdate.value = value ?? 'ip';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              sharedPrefs.themeMode =
                  context.read<ThemeProvider>().changeTheme();
            },
            icon: const Icon(Icons.light_mode),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ResponsiveBuilder(builder: (context, size) {
          return size.isDesktop
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1024),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: menuList()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: menuList());
        }),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget menuCard(String asset, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: 50,
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> menuList() {
    return [
      Flexible(
        child: menuCard('assets/images/tcp.webp', 'TCP Server', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TcpHome(title: 'TCP Server')));
        }),
      ),
      Flexible(
        child: menuCard('assets/images/udp.webp', 'UDP Server', () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UdpHome(title: 'UDP Server')));
        }),
      ),
    ];
  }
}
