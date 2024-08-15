import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rakcha/common/constants/MyColors.dart';
import 'package:rakcha/common/utils/GenerateExcel.dart';
import 'package:rakcha/common/utils/PrintData.dart';

import '../../features/home/data/model/Plante.dart';
import 'GneratePdf.dart';

void generateQRCode(BuildContext context, Plant plant, Function() navigate) {
  String formData = '''
  {
    "identifiant": "${plant.identifiant}",
    "date d'arrivée": "${DateFormat.yMd().format(plant.dateArrive)}"
  }
  ''';

  try {
    Map<String, dynamic> json = jsonDecode(formData);
    log(json["identifiant"]);
  } catch (e) {
    log('Error: $e');
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Generated QR Code'),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: 150,
        child: SingleChildScrollView(
          child: Column(
            children: [
              QrImageView(
                data: formData,
                version: QrVersions.auto,
                size: 150.0,
              ),
              RichText(
                  softWrap: true,
                  text: TextSpan(children: [
                    const TextSpan(
                      text: "Identifiant: ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                        text: plant.identifiant,
                        style: const TextStyle(
                            color: MyColors.background,
                            fontWeight: FontWeight.w500,
                            fontSize: 18)),
                    const TextSpan(
                        text: "\ndate d'arrivée: ",
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: DateFormat.yMd().format(plant.dateArrive),
                        style: const TextStyle(
                            color: MyColors.background,
                            fontWeight: FontWeight.w500,
                            fontSize: 18)),
                  ]))
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            exportToExcel(context, plant);
          },
          child: const Text('Export to Excel'),
        ),
        TextButton(
            onPressed: () {
              exportToPDF(context, plant) ;
              // selectAndPrint(context, formData);
            },
            child: const Text("Imprimer")),
        TextButton(
          onPressed: navigate,
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<String> scanQrCode() async {
  String qrResult = await FlutterBarcodeScanner.scanBarcode(
    '#ff6666', // Color of the scan button
    'Cancel', // Text for the cancel button
    true, // Use flash
    ScanMode.QR, // Scan mode (QR code, others available)
  );

  if (qrResult != '-1') {
    Map<String, dynamic> json = jsonDecode(qrResult);
    return json["identifiant"];
  } else {
    return '-1';
  }
}
