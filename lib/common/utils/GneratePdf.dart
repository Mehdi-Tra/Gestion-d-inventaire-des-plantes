import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

import '../../features/home/data/model/Plante.dart';

Future<void> exportToPDF(BuildContext context, Plant plant) async {
  try {
    bool permissionGranted = false;

    // Request permissions
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
    }

    if (permissionGranted) {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // Handle Android specific path
        String newPath = "";
        List<String> folders = directory!.path.split("/");
        for (int i = 1; i < folders.length; i++) {
          String folder = folders[i];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        newPath = "$newPath/Download";
        directory = Directory(newPath);

        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        String filePath = '${directory.path}/${plant.identifiant}.pdf';
        await savePDFFile(context, plant, filePath);
      } else if (Platform.isIOS || Platform.isWindows) {
        directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/${plant.identifiant}.pdf';
        await savePDFFile(context, plant, filePath);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  } catch (e, stackTrace) {
    log('Error in exportToPDF: $e');
    log('Stack trace: $stackTrace');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred during export')),
    );
  }
}

Future<void> savePDFFile(
    BuildContext context, Plant plant, String filePath) async {
  try {
    final pdf = pw.Document();
    String formData = '''
  {
    "identifiant": "${plant.identifiant}",
    "date d'arrivée": "${DateFormat.yMd().format(plant.dateArrive)}"
  }
  ''';

    final qrImage = QrImageView(
      data: formData,
      version: QrVersions.auto,
      size: 50.0,
    );

    final qrImageData = await _generateQRCodeImage(formData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                  height: 120,
                  width: 120,
                  child: pw.Image(pw.MemoryImage(qrImageData))),
              pw.SizedBox(height: 20),
              pw.Text('Identifiant: ${plant.identifiant}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text('Date Arrivée: ${plant.dateArrive.toIso8601String()}',
                  style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Santé: ${plant.sante}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Stade: ${plant.stade}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Entreposage: ${plant.entrosposage}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Actif/Inactif: ${plant.activ_inactiv}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Description: ${plant.description}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text(
              //     'Date Retrait: ${plant.dateRetrait?.toIso8601String() ?? 'N/A'}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Note: ${plant.note}', style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Raison Retrait: ${plant.raisonRetrait}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Provenance: ${plant.provenance}',
              //     style: pw.TextStyle(fontSize: 18)),
              // pw.Text('Responsable: ${plant.responsable}',
              //     style: pw.TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );

    final fileBytes = await pdf.save();
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data exported to PDF: $filePath')),
    );
    log('PDF file saved at: $filePath');
  } catch (e, stackTrace) {
    log('Error in savePDFFile: $e');
    log('Stack trace: $stackTrace');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred while saving the file')),
    );
  }
}

Future<Uint8List> _generateQRCodeImage(String data) async {
  final qrPainter = QrPainter(
    gapless: true,
    data: data,
    version: QrVersions.auto,
  );

  final byteData = await qrPainter.toImageData(2048);
  return byteData!.buffer.asUint8List();
}
