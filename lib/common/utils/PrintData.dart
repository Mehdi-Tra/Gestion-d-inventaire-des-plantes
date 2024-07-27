import 'dart:typed_data';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;

void selectAndPrint(BuildContext context, String dataToPrint) async {
  showDialog(
    context: context,
    barrierDismissible: false, // prevent user from dismissing dialog
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text('Searching for printers...'),
            ],
          ),
        ),
      );
    },
  );

  List<String> printers = await discoverPrinters();

  Navigator.pop(context); // close the CircularProgressIndicator dialog

  // Show dialog to select printer
  String? selectedPrinter = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Printer'),
        content: SingleChildScrollView(
          child: ListBody(
            children: printers
                .map((printer) => ListTile(
                      title: Text(printer),
                      onTap: () {
                        Navigator.pop(context, printer);
                      },
                    ))
                .toList(),
          ),
        ),
      );
    },
  );

  if (selectedPrinter != null) {
    // Print using selected printer
    await printData(selectedPrinter, dataToPrint);
  }
}

Future<List<String>> discoverPrinters() async {
  List<String> printers = [];

  final MDnsClient client = MDnsClient();
  await client.start();

  await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
    ResourceRecordQuery.serverPointer('_printer._tcp.local'),
  )) {
    await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
      ResourceRecordQuery.service(ptr.domainName),
    )) {
      await for (final IPAddressResourceRecord ip
          in client.lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(srv.target),
      )) {
        printers.add(ip.address.address);
      }
    }
  }

  client.stop();
  return printers;
}

// Future<void>  printData(String printerIp, String data) async {
//   final profile = await CapabilityProfile.load();
//   final printer = NetworkPrinter(PaperSize.mm80, profile);

//   final PosPrintResult res = await printer.connect(printerIp, port: 9100);

//   if (res == PosPrintResult.success) {
//     printer.text(
//       data,
//       styles: const PosStyles(align: PosAlign.left),
//       linesAfter: 1,
//     );

//     printer.cut();
//     printer.disconnect();
//   } else {
//     print('Could not connect to printer');
//   }
// }

Future<void> printData(String printerIp, String data) async {
  final profile = await CapabilityProfile.load();
  final printer = NetworkPrinter(PaperSize.mm80, profile);

  final PosPrintResult res = await printer.connect(printerIp, port: 9100);

  if (res == PosPrintResult.success) {
    // Generate QR code image
    final qrCode = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
    );

    // Convert QR code image to Uint8List
    final picData = await qrCode.toImageData(200);
    final imgCode = img.decodeImage(Uint8List.view(picData!.buffer));

    // Print QR code image
    printer.image(imgCode!);

    // Optionally, you can also print the text data
    printer.text(
      data,
      styles: const PosStyles(align: PosAlign.left),
      linesAfter: 1,
    );

    printer.cut();
    printer.disconnect();
  } else {
    print('Could not connect to printer');
  }
}
