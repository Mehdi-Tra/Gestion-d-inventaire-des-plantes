import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rakcha/common/constants/MyColors.dart';
import 'package:rakcha/features/home/presentaion/widgets/MyAppBar.dart';
import '../../data/model/Plante.dart';

class ProfileScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ProfileScreen({required this.scaffoldKey, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _changeStockCap = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ignore: unused_field
  late StreamSubscription<QuerySnapshot> _subscription;
  List<Plant> listPlant = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int? quantiteMax;

  Future<void> getQuantite() async {
    QuerySnapshot<Map<String, dynamic>> fetchQuantite =
        await _firestore.collection("profile").get();

    if (fetchQuantite.docs.isNotEmpty) {
      var data = fetchQuantite.docs.first.data();
      int quantite = data['qantite'];
      setState(() {
        quantiteMax = quantite;
      });
    }
  }

  Future<void> chnageCapacite(int newCap) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('profile').get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        DocumentReference docRef = doc.reference;

        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot freshSnapshot = await transaction.get(docRef);
          if (freshSnapshot.exists) {
            transaction.update(docRef, {"qantite": newCap});
            setState(() {
              quantiteMax = newCap;
            });
          } else {
            log('Document does not exist');
          }
        });

        await addHistoryEntry(
          "modification de capacite",
          "modifier la capacite au $newCap",
        );
      }

      log('Capacite updated successfully');
    } catch (e) {
      log('Error updating capacite: $e');
    }
  }

  Future<void> addHistoryEntry(String label, String description) async {
    await FirebaseFirestore.instance.collection('history').add({
      'label': label,
      'date': Timestamp.now(),
      'description': description,
    });
  }

  int getActivePlantCount() {
    return listPlant.where((plant) => plant.activ_inactiv == 1).length;
  }

  @override
  void initState() {
    super.initState();
    getQuantite();
    _subscription = _firestore
        .collection('plante')
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
      setState(() {
        listPlant = snapshot.docs
            .map((doc) => Plant.fromFirestore(doc.data()))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Myappbar(scaffoldKey: widget.scaffoldKey, title: "Profile"),
          const SizedBox(
            height: 64,
          ),
          identifiantWidget(),
          const SizedBox(
            height: 32,
          ),
          chnageCapaciteWidget()
        ],
      ),
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
          Expanded(
              child: Center(
                  child: Text("Profile",
                      style: Theme.of(context).textTheme.titleLarge))),
        ],
      ),
    );
  }

  Widget identifiantWidget() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 16, left: 16),
      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 16),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: MyColors.primeryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Identifiant: ",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Text("Admin",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: MyColors.background)),
            ],
          )
        ],
      ),
    );
  }

  Widget chnageCapaciteWidget() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(right: 16, left: 16),
        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 16),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: MyColors.primeryColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Parameter de stock",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      style: const TextStyle(color: MyColors.background),
                      validator: (value) {
                        if (int.tryParse(value!) == null) {
                          return 'Numero non valid';
                        }
                        if (getActivePlantCount() > int.parse(value)) {
                          return 'la nouvel capacite invalide';
                        }
                        return null;
                      },
                      controller: _changeStockCap,
                      decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.amber),
                          focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: MyColors.background),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          contentPadding: const EdgeInsets.only(
                              left: 16, right: 16, top: 4, bottom: 4),
                          label: Text(
                            "Changer Le Capacite :$quantiteMax",
                            style: const TextStyle(color: MyColors.background),
                          )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        int newCap = int.parse(_changeStockCap.text);
                        if (newCap >= getActivePlantCount()) {
                          chnageCapacite(newCap);
                          _changeStockCap.clear();
                          FocusScope.of(context).unfocus();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'La nouvelle capacité doit être supérieure ou égale au nombre de plantes actives'),
                            ),
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(MyColors.background),
                    ),
                    child: Text("Changer",
                        style: Theme.of(context).textTheme.bodySmall)),
              ),
            ],
          )
        ]));
  }
}
