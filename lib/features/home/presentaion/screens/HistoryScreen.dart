import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rakcha/features/home/presentaion/widgets/HistroeyCard.dart';
import 'package:rakcha/features/home/presentaion/widgets/MyAppBar.dart';
import '../../../../common/constants/MyColors.dart';
import '../../../../common/utils/GenerateQrCode.dart';

class HistoryScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HistoryScreen({required this.scaffoldKey, super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> listPlant = [];
  List<Map<String, dynamic>> filteredListPlant = [];
  String _searchQuery = '';
  bool _visibleClearIcon = false;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('history')
          .orderBy('date', descending: true)
          .get();
      setState(() {
        listPlant = snapshot.docs
            .map((doc) => {
                  'label': doc['label'],
                  'date': (doc['date'] as Timestamp).toDate(),
                  'description': doc['description'],
                })
            .toList();
        filteredListPlant = listPlant;
      });
    } catch (e) {
      log('Error fetching history: $e');
    }
  }

  void filterPlants() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredListPlant = listPlant;
      } else {
        filteredListPlant = listPlant.where((plant) {
          final description = plant['description'].toLowerCase();
          return description.contains('id $_searchQuery'.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Myappbar(scaffoldKey: widget.scaffoldKey, title: "Historique"),
        searchBar(),
        const SizedBox(
          height: 16,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredListPlant.length,
            itemBuilder: (context, index) {
              final plant = filteredListPlant[index];
              return HistoryCard(
                label: plant['label'],
                date: plant['date'],
                description: plant['description'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget titleWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
            },
            icon: Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          const SizedBox(width: 12),
          Text("Historique", style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            backgroundColor: WidgetStateProperty.all(MyColors.secondBackground),
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            textStyle: WidgetStateProperty.all<TextStyle?>(
                Theme.of(context).textTheme.headlineSmall),
            hintText: "Cherche une Plante",
            hintStyle: WidgetStateProperty.all<TextStyle?>(
                Theme.of(context).textTheme.headlineSmall),
            controller: controller,
            onTap: () {},
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _visibleClearIcon = value.isNotEmpty;
                filterPlants();
              });
              log("${listPlant.first['label']}");
            },
            leading: Icon(
              Icons.search,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            trailing: [
              if (!_visibleClearIcon)
                Tooltip(
                  message: "QR Scanner",
                  child: IconButton(
                    onPressed: () async {
                      String qrResult = await scanQrCode();

                      if (qrResult != '-1') {
                        _searchQuery = qrResult;
                      } else {
                        log(qrResult);
                      }
                    },
                    icon: Icon(
                      Icons.qr_code_2_outlined,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              if (_visibleClearIcon)
                Tooltip(
                  message: "Clear",
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        controller.clear();
                        _searchQuery = '';
                        _visibleClearIcon = false;
                        filterPlants();
                      });
                      log("$_visibleClearIcon");
                    },
                    icon: Icon(
                      Icons.clear_outlined,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
            ],
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
          return List<ListTile>.generate(5, (int index) {
            final String item = 'item $index';
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(() {
                  controller.closeView(item);
                });
              },
            );
          });
        },
      ),
    );
  }
}
