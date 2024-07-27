

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:rakcha/common/constants/MyColors.dart';

class HistoryPlant extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String label;

  const HistoryPlant({required this.scaffoldKey, required this.label, super.key});

  @override
  State<HistoryPlant> createState() => _HistoryPlantState();
}

class _HistoryPlantState extends State<HistoryPlant> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedDate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [myAppBar(), dateFilter(), historyList()],
          ),
        ),
      ),
    );
  }

  Widget myAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<QueryDocumentSnapshot>> fetchHistoryPlanteDocuments(String label) {
    return _firestore
        .collection('historyPlante')
        .where("label", isEqualTo: label)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<Set<String>> fetchAvailableDates(String label) {
    return fetchHistoryPlanteDocuments(label).map((docs) {
      return docs.map((doc) {
        Timestamp timestamp = doc['date'];
        DateTime dateTime = timestamp.toDate();
        return DateFormat('yyyy-MM-dd').format(dateTime);
      }).toSet();
    });
  }

  Widget dateFilter() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: StreamBuilder<Set<String>>(
      stream: fetchAvailableDates(widget.label),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No available dates");
        }

        final availableDates = snapshot.data!.toList();
        availableDates.insert(0, "Tout les date");

        return DropdownButton<String>(
              dropdownColor: const Color.fromARGB(155, 0, 21, 24),

          value: selectedDate ?? "Tout les date",
          hint: const Text(
            "Select a date",
            style: TextStyle(color: MyColors.primeryColor),
          ),
          items: availableDates.map((date) {
            return DropdownMenuItem(
              value: date,
              child: Text(date, style: Theme.of(context).textTheme.labelLarge),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (value == "Tout les date") {
                selectedDate = null; // No date filter
              } else {
                selectedDate = value;
              }
            });
          },
        );
      },
    ),
  );
}


  Stream<Map<String, List<QueryDocumentSnapshot>>> groupDocumentsByDate(String label) {
    return fetchHistoryPlanteDocuments(label).map((docs) {
      final filteredDocs = selectedDate == null
          ? docs
          : docs.where((doc) {
              Timestamp timestamp = doc['date'];
              DateTime dateTime = timestamp.toDate();
              String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
              return formattedDate == selectedDate;
            }).toList();

      return groupBy(filteredDocs, (doc) {
        Timestamp timestamp = doc['date'];
        DateTime dateTime = timestamp.toDate();
        String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
        return formattedDate;
      });
    });
  }

  Widget historyList() {
    return StreamBuilder<Map<String, List<QueryDocumentSnapshot>>>(
      stream: groupDocumentsByDate(widget.label),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          log("No data");
          return const Text("No history data available");
        }

        final groupedData = snapshot.data!;
        log("Grouped data: $groupedData");

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: groupedData.entries.map((entry) {
            final date = entry.key;
            final docs = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...docs.map((doc) {
                    Timestamp timestamp = doc['date'];
                    DateTime dateTime = timestamp.toDate();
                    String formattedTime = DateFormat('HH:mm:ss').format(dateTime);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: RichText(
                        text: TextSpan(
                          text: "${doc["description"]} le ",
                          children: [
                            TextSpan(text: formattedTime, style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }


}
