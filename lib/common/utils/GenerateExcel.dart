import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/home/data/model/Plante.dart';

Future<void> exportToExcel(BuildContext context, Plant plant) async {
  bool permissionGranted = false;

  if (await Permission.storage.request().isGranted) {
    permissionGranted = true;
  } else if (await Permission.manageExternalStorage.request().isGranted) {
    permissionGranted = true;
  } else if (await Permission.storage.isPermanentlyDenied) {
    await openAppSettings();
  }

  if (permissionGranted) {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      String newPath = "";
      List<String> folders = directory.path.split("/");
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
    }

    if (!directory!.existsSync()) {
      directory.createSync(recursive: true);
    }

    String filePath = '${directory.path}/Plantes.xlsx';

    Excel excel;
    Sheet sheetObject;
    bool identifiantExists = false;

    // Check if the file already exists
    if (File(filePath).existsSync()) {
      var bytes = File(filePath).readAsBytesSync();
      excel = Excel.decodeBytes(bytes);
      sheetObject = excel['Sheet1'];

      // Check for existing identifiant
      for (var row in sheetObject.rows) {
        if (row[0]?.value.toString() == plant.identifiant) {
          log("identifiant: ${row[0]?.value}.");
          identifiantExists = true;
          break;
        }
      }
    } else {
      excel = Excel.createExcel();
      sheetObject = excel['Sheet1'];
      // Adding headers
      sheetObject.appendRow([
        "Identifiant",
        "Santé",
        "Date Arrivée",
        "Stade",
        "Entreposage",
        "Actif/Inactif",
        "Description",
        "Date Retrait",
        "Note",
        "Raison Retrait",
        "Provenance",
        "Responsable"
      ]);
    }

    if (!identifiantExists) {
      // Adding form data
      sheetObject.appendRow([
        plant.identifiant,
        plant.sante,
        plant.dateArrive.toIso8601String(),
        plant.stade,
        plant.entrosposage,
        plant.activ_inactiv,
        plant.description,
        plant.dateRetrait?.toIso8601String(),
        plant.note,
        plant.raisonRetrait,
        plant.provenance,
        plant.responsable,
      ]);

      var fileBytes = excel.encode();
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      // Notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to Excel: $filePath')),
      );

      // Optionally, you can also print the file path to the console
      log('Excel file saved at: $filePath');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Identifiant already exists in Excel: ${plant.identifiant}')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage permission denied')),
    );
  }
}

Future<void> importFromExcel(BuildContext context) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File not found')),
    );
    return;
  }

  String filePath = result.files.single.path!;
  var bytes = File(filePath).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  var sheet = excel['Sheet1'];
  List<Plant> plants = [];

  try {
    // Récupérer la quantité maximale et le nombre actuel de plantes
    QuerySnapshot<Map<String, dynamic>> quantiteSnapshot =
        await FirebaseFirestore.instance.collection("profile").get();
    if (quantiteSnapshot.docs.isEmpty) {
      throw Exception('Failed to get profile data');
    }
    int quantiteMax = quantiteSnapshot.docs.first.data()['qantite'] ?? 0;
    log('Quantite maximale: $quantiteMax');

    QuerySnapshot<Map<String, dynamic>> numPlanteSnapshot =
        await FirebaseFirestore.instance
            .collection("plante")
            .where('activ_inactiv', isEqualTo: 1)
            .get();
    int numPlante = numPlanteSnapshot.docs.length;
    log('Nombre actuel de plantes: $numPlante');

    int remainingCapacity = quantiteMax - numPlante;
    log('Capacité restante: $remainingCapacity');
    int importedCount = 0;

    for (var row in sheet.rows) {
      if (row.length < 12) {
        log('Row skipped due to insufficient length: ${row.length}');
        continue;
      }

      if (importedCount >= remainingCapacity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Limite de stockage atteinte.')),
        );
        break; // Stop importing if the limit is reached
      }

      try {
        String? identifiant = row[0]?.value?.toString();
        String? sante = row[1]?.value?.toString();
        DateTime? dateArrive = parseDate(row[2]?.value?.toString());
        String? stade = row[3]?.value?.toString();
        String? entrosposage = row[4]?.value?.toString();
        String? description = row[6]?.value?.toString();
        DateTime? dateRetrait = parseDate(row[7]?.value?.toString());
        String? note = row[8]?.value?.toString();
        String? raisonRetrait = row[9]?.value?.toString();
        String? provenance = row[10]?.value?.toString();
        String? responsable = row[11]?.value?.toString();

        int? activ_inactiv = dateRetrait == null ? 1 : 0;

        if (identifiant == null ||
            sante == null ||
            dateArrive == null ||
            stade == null ||
            entrosposage == null ||
            //activ_inactiv == null ||
            provenance == null) {
          throw FormatException(
              'Required field is missing \n$identifiant/$sante/$dateArrive/$stade/$entrosposage/$activ_inactiv/$provenance');
        }

        Plant plant = Plant(
          identifiant: identifiant,
          sante: sante,
          dateArrive: dateArrive,
          stade: stade,
          entrosposage: entrosposage,
          activ_inactiv: activ_inactiv,
          provenance: provenance,
          responsable: responsable,
          description: description,
          dateRetrait: dateRetrait,
          raisonRetrait: raisonRetrait,
          note: note,
        );

        if (!identifiant.contains('.')) {
          identifiant = await generateUniqueIdentifiant(identifiant);
        } else {
          bool exists = await identifiantExistsInFirestore(identifiant);
          if (exists) {
            identifiant =
                await generateUniqueIdentifiant(identifiant.split('.')[0]);
          }
        }

        plant.identifiant = identifiant;

        await addPlantToFirestore(plant);
        plants.add(plant);
        importedCount++;
        log('Plant ajouté: ${plant.identifiant}');

        await addHistoryEntry(
            "Plante ajouter", "Plant avec ID ${plant.identifiant} est ajouter");
        await addHistoryForPlant(
            plant.identifiant, "La plante ${plant.identifiant} a été créé");
      } catch (e) {
        log('Error parsing row: $e');
        continue;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data imported successfully')),
    );

    print('Imported Plants: $plants');
  } catch (e) {
    log('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}

Future<String> generateUniqueIdentifiant(String baseIdentifiant) async {
  int num = 1;
  String newIdentifiant = '$baseIdentifiant.$num';

  while (await identifiantExistsInFirestore(newIdentifiant)) {
    num++;
    newIdentifiant = '$baseIdentifiant.$num';
  }

  return newIdentifiant;
}

Future<void> addHistoryEntry(String label, String description) async {
  await FirebaseFirestore.instance.collection('history').add({
    'label': label,
    'date': Timestamp.now(),
    'description': description,
  });
}

Future<void> addHistoryForPlant(String label, String description) async {
  await FirebaseFirestore.instance.collection('historyPlante').add(
      {'label': label, 'date': Timestamp.now(), 'description': description});
}

Future<bool> plantExistsInFirestore(String identifiant) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('plante')
      .where('identifiant', isEqualTo: identifiant)
      .get();

  return querySnapshot.docs.isNotEmpty;
}

Future<bool> identifiantExistsInFirestore(String identifiant) async {
  var querySnapshot = await FirebaseFirestore.instance
      .collection('plante')
      .where('identifiant', isEqualTo: identifiant)
      .get();

  return querySnapshot.docs.isNotEmpty;
}

Future<void> addPlantToFirestore(Plant plant) async {
  plant.identifiant = plant.identifiant;
  await FirebaseFirestore.instance
      .collection('plante')
      .add(plant.toFirestore());
}

Future<void> addPlantExistToFirestore(Plant plant) async {
  String nomPlante = plant.identifiant.split('.')[0];

  int num = await numIdentifiant(nomPlante);

  plant.identifiant = '$nomPlante.$num';

  await FirebaseFirestore.instance
      .collection('plante')
      .add(plant.toFirestore());
}

Future<void> addPlantExistWithoutNumToFirestore(Plant plant) async {
  int num = await numIdentifiant(plant.identifiant);

  plant.identifiant = '${plant.identifiant}.$num';

  await FirebaseFirestore.instance
      .collection('plante')
      .add(plant.toFirestore());
}

Future<String> updateIdentifiantWithNumber(String identifiant) async {
  String nomPlante = identifiant.split('.')[0];
  int num = await numIdentifiant(nomPlante);
  return '$nomPlante.$num';
}

Future<int> numIdentifiant(String nomPlante) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("plante").get();

  List<int> numbers = [];

  for (var doc in snapshot.docs) {
    String identifiant = doc["identifiant"];

    List<String> parts = identifiant.split('.');

    String name = parts[0];

    if (nomPlante == name && parts.length > 1) {
      numbers.add(int.parse(parts[1]));
    }
  }

  return numbers.isNotEmpty ? (numbers.max + 1) : 1;
}

DateTime? parseDate(String? dateString) {
  final dateFormats = [
    DateFormat("yyyy-MM-dd"),
    DateFormat("yyyy-MM-ddTHH:mm:ss"),
    // Add more formats as needed
  ];

  for (var format in dateFormats) {
    try {
      return format.parse(dateString ?? '');
    } catch (e) {
      // Continue to next format
    }
  }
  return null;
}