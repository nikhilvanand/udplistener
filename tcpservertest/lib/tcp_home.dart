/* import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tcpservertest/model/device_command.dart';

class TcpHome extends StatefulWidget {
  const TcpHome({super.key, required this.title});
  final String title;
  @override
  State<TcpHome> createState() => _TcpHomeState();
}

class _TcpHomeState extends State<TcpHome> {
  ServerSocket? server;
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
  void dispose() {
    server?.close();
    super.dispose();
  }

  void _incrementCounter() async {
    if (server == null) {
      serverUpdate.value = 'TCP Server starting 9001';
    } else {
      serverUpdate.value = ('TCP Server running 9001');
      return;
    }
    server = await ServerSocket.bind('0.0.0.0', 8001);
    server?.listen((socket) {
      var receivedCount = 0;
      socket.listen((eventBytes) {
        final result = utf8.decode(eventBytes);
        print('From client = $result');
        serverUpdate.value = result;
        statusUpdate.add(result);
        var devCommand = DeviceCommandModel.fromJson(json.decode(result));
        devCommand.deviceId = '5678064';
        /* Future.delayed(const Duration(seconds: 2),
            () => socket.add(utf8.encode('TCP data Received $receivedCount'))); */
        socket.add(utf8.encode(json.encode(devCommand.toJson())));
        receivedCount++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ValueListenableBuilder(
            valueListenable: serverUpdate,
            builder: (context, v, c) {
              var listStats = statusUpdate.reversed.toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${ips.toList()} @ 9001'),
                  const SizedBox(height: 10),
                  Text(
                    serverUpdate.value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                      child: ListView.builder(
                          itemCount: listStats.length,
                          itemBuilder: (context, index) => Card(
                              color: Theme.of(context).focusColor,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SelectableText(listStats[index]),
                              ))))
                ],
              );
            }),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        height: 50,
        child: Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  _incrementCounter();
                },
                child: const Text('Start Server')),
            const SizedBox(width: 10),
            ElevatedButton(
                onPressed: () {
                  statusUpdate.clear();
                  serverUpdate.value = 'Log cleared';
                },
                child: const Text('Clear log')),
            const SizedBox(width: 10),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close')),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
 */
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tcpservertest/common/SharedPrefs.dart';
import 'package:tcpservertest/model/device_command.dart';

class TcpHome extends StatefulWidget {
  const TcpHome({super.key, required this.title});
  final String title;
  @override
  State<TcpHome> createState() => _TcpHomeState();
}

class _TcpHomeState extends State<TcpHome> {
  ExpansionTileController expansionTileController = ExpansionTileController();
  SharedPrefs sharedPrefs = SharedPrefs();
  //RawDatagramSocket? udpResponseSocket;
  DeviceCommandModel echoResponse = DeviceCommandModel(content: Content());
  var detinationAddress = InternetAddress("255.255.255.255");
  //var multicastIpList = <String>{};
  Socket? socket;
  var data = <String, dynamic>{};

  String? propertyId;
  var recData = 'NoData';
  ServerSocket? server;
  var ips = <String>[];
  var serverUpdate = ValueNotifier('Empty');
  var switchStatus = ValueNotifier(true);
  var statusUpdate = <String>[];

  late TextEditingController txtMsg,
      txtServerIp,
      txtOutgoing; // = TextEditingController();
  @override
  void initState() {
    txtMsg = TextEditingController(text: sharedPrefs.sendMsg);
    txtServerIp = TextEditingController(text: sharedPrefs.tcpServerIp);
    txtOutgoing = TextEditingController(text: sharedPrefs.tcpPort);
    NetworkInfo().getWifiIP().then((value) {
      ips.add(value ?? 'null');
      serverUpdate.value = value ?? 'ip';
    });
    super.initState();
  }

  @override
  void dispose() {
    server?.close();
    super.dispose();
  }

  initLanSocket() async {
    //var myIpAddress = await NetworkInfo().getWifiIP();
    if (server == null) {
      serverUpdate.value = 'TCP Server starting${txtOutgoing.text}';
    } else {
      serverUpdate.value = ('TCP Server running${txtOutgoing.text}');
      return;
    }
    try {
      server = await ServerSocket.bind(
          txtServerIp.text, int.parse(txtOutgoing.text));
    } on Exception catch (e) {
      serverUpdate.value = e.toString();
      statusUpdate.add(e.toString());
    }
    server?.listen((socket) {
      socket.listen((eventBytes) {
        final result = utf8.decode(eventBytes);
        print('From client = $result');
        serverUpdate.value = result;
        statusUpdate.add(result);
        // var devCommand = DeviceCommandModel.fromJson(json.decode(result));
        // socket.add(utf8.encode(json.encode(devCommand.toJson())));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                controller: expansionTileController,
                collapsedBackgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                childrenPadding: const EdgeInsets.all(10),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                initiallyExpanded: switchStatus.value,
                title: const Text('Settings'),
                children: [
                  const SizedBox(height: 20),
                  TextField(
                      controller: txtServerIp,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        LengthLimitingTextInputFormatter(16)
                      ],
                      decoration: const InputDecoration(labelText: 'Server'),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4)
                      ],
                      controller: txtOutgoing,
                      decoration: const InputDecoration(labelText: 'Port')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                          width: 100,
                          child: ElevatedButton(
                              onPressed: () {
                                sharedPrefs.tcpServerIp = txtServerIp.text;
                                sharedPrefs.tcpPort = txtOutgoing.text;
                                initLanSocket();
                                expansionTileController.collapse();
                              },
                              child: const Text('Start'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              )),
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: serverUpdate,
                builder: (context, v, c) {
                  var listStats = statusUpdate.reversed.toList();
                  txtMsg.text = json.encode(echoResponse.toJson());
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Expanded(
                            child: ListView.builder(
                                itemCount: listStats.length,
                                itemBuilder: (context, index) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8.0),
                                      child: SelectableText(listStats[index]),
                                    )))
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.error,
        onPressed: () {
          statusUpdate.clear();
          serverUpdate.value = 'Log cleared';
        },
        child:
            Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        height: 100,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.titleSmall,
                controller: txtMsg,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 80,
              height: double.maxFinite,
              child: IconButton(
                  onPressed: () {
                    socket?.add(utf8.encode(json.encode(txtMsg.text)));
                    sharedPrefs.sendMsg = jsonEncode(txtMsg.text);
                  },
                  icon: const Icon(Icons.send)),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
