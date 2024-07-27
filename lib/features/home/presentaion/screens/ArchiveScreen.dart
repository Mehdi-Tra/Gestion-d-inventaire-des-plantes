import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rakcha/features/home/presentaion/screens/FormulairScreen.dart';

import '../../../../common/constants/MyColors.dart';
import '../../../../common/utils/GenerateQrCode.dart';
import '../../data/model/Plante.dart';
import '../widgets/PlanteCard.dart';

class ArchiveScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(Widget) changeCurrentScreen;
  const ArchiveScreen(
      {required this.changeCurrentScreen,
      required this.scaffoldKey,
      super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Plant> listPlant = [];
  List<Plant> filteredListPlant = [];
  late StreamSubscription<QuerySnapshot> _subscription;
  String _searchQuery = '';
  bool _visibleClearIcon = false;

  void filterPlants() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredListPlant = listPlant;
      } else {
        filteredListPlant = listPlant
            .where((plant) => plant.identifiant
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the list of plants
    fetechPlante();

    // Listen to changes in the 'plante' collection with a filter
    _subscription = _firestore
        .collection("plante")
        .where("activ_inactiv", isEqualTo: 0)
        .snapshots()
        .listen((snapshot) {
      List<Plant> updatedPlantList = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Plant.fromFirestore(data);
      }).toList();

      setState(() {
        listPlant = updatedPlantList;
        filteredListPlant = updatedPlantList;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    _subscription.cancel();
    super.dispose();
  }

  Future<void> fetechPlante() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("plante").get();
      List<Plant> fetchedPlant = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Plant.fromFirestore(data);
      }).toList();
      setState(() {
        listPlant = fetchedPlant
            .where((plant) => plant.activ_inactiv.toString() == "0")
            .toList();
        filteredListPlant = listPlant;
      });
    } catch (e) {
      log("erreur fetching $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        myAppBar(),
        const SizedBox(height: 32),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8),
            child: ListView.separated(
              itemBuilder: (context, index) {
                return PlantCard(
                    scaffoldKey: widget.scaffoldKey,
                    changeCurrentScreen: widget.changeCurrentScreen,
                    plant: filteredListPlant[index]);
              },
              itemCount: filteredListPlant.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget myAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
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
          searchBar(),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(right: 16),
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
              log("$_visibleClearIcon");
            },
            leading: Icon(
              Icons.search,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            trailing: [
              if (!_visibleClearIcon)
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

                        QuerySnapshot<Map<String, dynamic>> fetchedPlant =
                            await _firestore
                                .collection("plante")
                                .where("identifiant", isEqualTo: _searchQuery)
                                .get();

                        if (fetchedPlant.docs.isNotEmpty) {
                          Plant plant = Plant.fromFirestore(
                              fetchedPlant.docs.first.data());
                          widget.changeCurrentScreen(Formulairscreen(
                            scaffoldKey: widget.scaffoldKey,
                            isModifie: true,
                            changeCurrentScreen: widget.changeCurrentScreen,
                            plant: plant,
                          ));
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
