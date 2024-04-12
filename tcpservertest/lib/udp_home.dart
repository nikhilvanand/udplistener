import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tcpservertest/common/SharedPrefs.dart';
import 'package:tcpservertest/model/device_command.dart';

class UdpHome extends StatefulWidget {
  const UdpHome({super.key, required this.title});
  final String title;
  @override
  State<UdpHome> createState() => _UdpHomeState();
}

class MsgFormat {
  int type;
  String data;
  MsgFormat({required this.type, required this.data});
}

class _UdpHomeState extends State<UdpHome> {
  ExpansionTileController expansionTileController = ExpansionTileController();
  SharedPrefs sharedPrefs = SharedPrefs();
  RawDatagramSocket? udpResponseSocket;
  DeviceCommandModel echoResponse = DeviceCommandModel(content: Content());
  var detinationAddress = InternetAddress("255.255.255.255");
  var multicastIpList = <String>{};
  Socket? socket;
  var data = <String, dynamic>{};
  int udpCommandPort = 8889;

  String? propertyId;
  var recData = 'NoData';
  ServerSocket? server;
  var ips = <String>[];
  var listUpdate = ValueNotifier(0);
  var switchStatus = ValueNotifier(true);
  var statusMessage = <MsgFormat>[];

  late TextEditingController txtMsg,
      txtIncome,
      txtOutgoing; // = TextEditingController();
  @override
  void initState() {
    txtMsg = TextEditingController();
    txtIncome = TextEditingController(text: sharedPrefs.incomePort);
    txtOutgoing = TextEditingController(text: sharedPrefs.outcomePort);
    NetworkInfo().getWifiIP().then((value) {
      ips.add(value ?? 'null');
      //serverUpdate.value = value ?? 'ip';
    });
    super.initState();
  }

  @override
  void dispose() {
    server?.close();
    super.dispose();
  }

  initLanSocket() async {
    var myIpAddress = await NetworkInfo().getWifiIP();
    udpCommandPort = int.parse(txtOutgoing.text);
    var udpResponsePort = int.parse(txtIncome.text);
    udpResponseSocket?.close();
    udpResponseSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpResponsePort);
    udpResponseSocket?.broadcastEnabled = true;
    udpResponseSocket?.listen((e) {
      Datagram? dg = udpResponseSocket?.receive();
      if (dg != null) {
        log('UDP recieved..................................');
        if (dg.address.address != myIpAddress) {
          recData = utf8.decode(dg.data);
          try {
            data = json.decode(utf8.decode(dg.data));
            listUpdate.value++;
            statusMessage.add(MsgFormat(type: 0, data: '$data'));
          } on Exception {
            print('Invalid Json');
          }
          print(json.encode(data));
        }
      }
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
                      controller: txtIncome,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4)
                      ],
                      decoration: const InputDecoration(labelText: 'Incoming'),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4)
                      ],
                      controller: txtOutgoing,
                      decoration: const InputDecoration(labelText: 'Outgoing')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                          width: 100,
                          child: ElevatedButton(
                              onPressed: () {
                                sharedPrefs.incomePort = txtIncome.text;
                                sharedPrefs.outcomePort = txtOutgoing.text;
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
                valueListenable: listUpdate,
                builder: (context, v, c) {
                  var listStats = statusMessage.reversed.toList();
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
                                        color: listStats[index].type == 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: 8,
                                          right: listStats[index].type == 0
                                              ? 30
                                              : 0,
                                          left: listStats[index].type == 0
                                              ? 0
                                              : 30),
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          SelectableText(listStats[index].data),
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
          statusMessage.clear();
          listUpdate.value = 0;
        },
        child:
            Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    udpResponseSocket?.send(utf8.encode(txtMsg.text),
                        detinationAddress, udpCommandPort);
                    statusMessage.add(MsgFormat(type: 1, data: txtMsg.text));
                    //statusMessage.add();
                    listUpdate.value++;
                  },
                  icon: const Icon(Icons.send)),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
