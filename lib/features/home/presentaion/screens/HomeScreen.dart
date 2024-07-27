import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rakcha/common/constants/MyColors.dart';
import 'package:rakcha/features/home/presentaion/screens/FormulairScreen.dart';
import 'package:rakcha/features/home/presentaion/widgets/PlanteCard.dart';

import '../../../../common/utils/GenerateExcel.dart';
import '../../../../common/utils/GenerateQrCode.dart';
import '../../data/model/Plante.dart';
import 'HistroyPlantScreen.dart';

class Homescreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(Widget) changeCurrentScreen;

  const Homescreen({
    required this.changeCurrentScreen,
    required this.scaffoldKey,
    Key? key,
  }) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _visibleClearIcon = false;

  List<Plant> listPlant = [];
  List<Plant> filteredListPlant = [];

  List<String> alphabet =
      List.generate(26, (index) => String.fromCharCode(index + 65));
  Map<String, int> alphabetIndex = {};
  ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String? _selectedHealthStatus;

  int? quantiteMax;
  int? numPlante;

  late StreamSubscription<QuerySnapshot> _subscription;

  Future<void> getQuantite() async {
    try {
      QuerySnapshot<Map<String, dynamic>> fetchQuantite =
          await _firestore.collection("profile").get();

      if (fetchQuantite.docs.isNotEmpty) {
        var data = fetchQuantite.docs.first.data();
        int quantite = data['qantite'] ?? 0;

        setState(() {
          quantiteMax = quantite;
        });
      }
    } catch (e) {
      log('Error fetching quantiteMax: $e');
    }
  }

  Future<void> getNumPlante() async {
    try {
      QuerySnapshot<Map<String, dynamic>> fetchNumPlante = await _firestore
          .collection("plante")
          .where('activ_inactiv', isEqualTo: 1)
          .get();

      setState(() {
        numPlante = fetchNumPlante.docs.length;
      });
    } catch (e) {
      log('Error fetching numPlante: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getQuantite();
    getNumPlante();
    _subscription = _firestore
        .collection('plante')
        .where("activ_inactiv", isEqualTo: 1)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      setState(() {
        listPlant = snapshot.docs
            .map((doc) => Plant.fromFirestore(doc.data()))
            .toList();

        // Sort listPlant by identifiant ignoring case
        listPlant.sort((a, b) =>
            a.identifiant.toLowerCase().compareTo(b.identifiant.toLowerCase()));

        filterPlants();
        getNumPlante(); // Mise à jour du nombre de plantes
      });
    });

    // Écoute des changements dans la collection 'profile'
    _firestore.collection('profile').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        setState(() {
          quantiteMax = data['qantite'];
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void filterPlants() {
    setState(() {
      if (_searchQuery.isEmpty &&
          (_selectedHealthStatus == null || _selectedHealthStatus == 'All')) {
        filteredListPlant = listPlant;
      } else {
        filteredListPlant = listPlant.where((plant) {
          final matchesSearchQuery = plant.identifiant
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
          final matchesHealthStatus = _selectedHealthStatus == null ||
              _selectedHealthStatus == 'Tout' ||
              plant.sante == _selectedHealthStatus;
          return matchesSearchQuery && matchesHealthStatus;
        }).toList();
      }

      alphabetIndex.clear();
      for (int i = 0; i < filteredListPlant.length; i++) {
        String firstLetter = filteredListPlant[i].identifiant[0].toUpperCase();
        if (!alphabetIndex.containsKey(firstLetter)) {
          alphabetIndex[firstLetter] = i;
        }
      }
    });
    getNumPlante(); // Mise à jour du nombre de plantes
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            myAppBar(),
            const SizedBox(height: 8),
            addPlant(),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 10, child: listPlantFireStore()),
                  Expanded(flex: 1, child: alphabetScrollbar()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget alphabetScrollbar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        itemCount: alphabet.length,
        itemBuilder: (context, index) {
          String letter = alphabet[index];
          return GestureDetector(
            onTap: () {
              if (alphabetIndex.containsKey(letter)) {
                _scrollController.animateTo(
                  alphabetIndex[letter]! *
                      90, // Adjust scroll position as needed
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                letter,
                style: const TextStyle(color: MyColors.primeryColor),
              ),
            ),
          );
        },
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
            backgroundColor:
                WidgetStateProperty.all<Color?>(MyColors.secondBackground),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(
              const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            textStyle: WidgetStateProperty.all<TextStyle?>(
                Theme.of(context).textTheme.headlineSmall),
            hintText: "Cherche une Plante",
            hintStyle: WidgetStateProperty.all<TextStyle?>(
                Theme.of(context).textTheme.headlineSmall),
            controller: controller,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _visibleClearIcon = value.isNotEmpty;
                filterPlants();
              });
            },
            leading: Icon(
              Icons.search,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            trailing: [
              if (!_visibleClearIcon)
                Tooltip(
                  message: "Filter",
                  child: PopupMenuButton(
                    color: const Color.fromARGB(155, 0, 21, 24),
                    icon: const Icon(
                      Icons.tune_outlined,
                      color: MyColors.background,
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              _selectedHealthStatus = "Tout";
                              filterPlants();
                            });
                          },
                          child: const Text(
                            "Tout",
                            style: TextStyle(color: MyColors.primeryColor),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              _selectedHealthStatus = "Bonne";
                              filterPlants();
                            });
                          },
                          child: const Text(
                            "Bonne",
                            style: TextStyle(color: MyColors.primeryColor),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              _selectedHealthStatus = "Moyenne";
                              filterPlants();
                            });
                          },
                          child: const Text(
                            "Moyenne",
                            style: TextStyle(color: MyColors.primeryColor),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            setState(() {
                              _selectedHealthStatus = "Mauvaise";
                              filterPlants();
                            });
                          },
                          child: const Text(
                            "Mauvaise",
                            style: TextStyle(color: MyColors.primeryColor),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
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
                      Plant plant =
                          Plant.fromFirestore(fetchedPlant.docs.first.data());

                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  "Options pour la plante ${plant.identifiant}"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      generateQRCode(context, plant, () {
                                        // Navigator.pushNamedAndRemoveUntil(context, '/lobby', (_)=>false);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: const Text("Imprimer")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);

                                      widget
                                          .changeCurrentScreen(Formulairscreen(
                                        isModifie: true,
                                        scaffoldKey: widget.scaffoldKey,
                                        changeCurrentScreen:
                                            widget.changeCurrentScreen,
                                        plant: plant,
                                      ));
                                    },
                                    child: const Text("Modifier")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HistoryPlant(
                                                      scaffoldKey:
                                                          widget.scaffoldKey,
                                                      label:
                                                          plant.identifiant)));
                                    },
                                    child: const Text("Historique")),
                              ],
                            );
                          });

                      // widget.changeCurrentScreen(Formulairscreen(
                      //   scaffoldKey: widget.scaffoldKey,
                      //   isModifie: true,
                      //   changeCurrentScreen: widget.changeCurrentScreen,
                      //   plant: plant,
                      // ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Plante n'existe pas")),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.qr_code_2_outlined,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              if (_visibleClearIcon)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                      _searchQuery = '';
                      _visibleClearIcon = false;
                      filterPlants();
                    });
                  },
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

  Widget addPlant() {
    return GestureDetector(
      onLongPress: () {
        if (numPlante! >= quantiteMax!) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Impossible d'ajouter une plante, la quantité maximale est atteinte."),
            ),
          );
          return;
        } else {
          importFromExcel(context);
        }
      },
      onTap: () {
        if (quantiteMax != null && numPlante != null) {
          if (numPlante! >= quantiteMax!) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Impossible d'ajouter une plante, la quantité maximale est atteinte."),
              ),
            );
            return;
          } else {
            widget.changeCurrentScreen(Formulairscreen(
              changeCurrentScreen: widget.changeCurrentScreen,
              scaffoldKey: widget.scaffoldKey,
              isModifie: false,
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Les données de quantité ne sont pas disponibles."),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: MyColors.primeryColor),
            borderRadius: BorderRadius.circular(12),
            color: MyColors.background,
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(71, 149, 203, 40),
                offset: Offset(3, 3),
                blurRadius: 10,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Color.fromARGB(71, 149, 203, 40),
                offset: Offset(0, 0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Wrap(
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ajouter une plante",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              Text(
                "$numPlante/$quantiteMax",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Icon(
                Icons.add,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listPlantFireStore() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: filteredListPlant.length,
        itemBuilder: (context, index) {
          return PlantCard(
            plant: filteredListPlant[index],
            scaffoldKey: widget.scaffoldKey,
            changeCurrentScreen: widget.changeCurrentScreen,
          );
        },
      ),
    );
  }
}
