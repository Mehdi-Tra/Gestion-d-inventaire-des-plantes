// ignore_for_file: file_names, prefer_const_constructors, body_might_complete_normally_nullable

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rakcha/common/widgets/Fields.dart';

import '../../../../common/constants/MyColors.dart';
import '../../../../common/utils/GenerateQrCode.dart';
import '../../data/model/Plante.dart';
import '../widgets/FormulairWidgets.dart';
import '../widgets/SliderSante.dart';
import 'HomeScreen.dart';

class Formulairscreen extends StatefulWidget {
  final Function(Widget) changeCurrentScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isModifie;
  final Plant? plant;

  const Formulairscreen({
    required this.changeCurrentScreen,
    required this.isModifie,
    required this.scaffoldKey,
    this.plant,
    super.key,
  });

  @override
  State<Formulairscreen> createState() => _FormulairScreenState();
}

class _FormulairScreenState extends State<Formulairscreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();

  final TextEditingController _arivDateTimeControll = TextEditingController();
  final TextEditingController _retraitDateTimeControll =
      TextEditingController();
  final TextEditingController _inactivActivController = TextEditingController();
  final TextEditingController _identifController = TextEditingController();
  final TextEditingController _provenanceControll = TextEditingController();
  final TextEditingController _descriptionControll = TextEditingController();
  final TextEditingController _noteControll = TextEditingController();
  final TextEditingController _ajouterResponsableControll =
      TextEditingController();
  final TextEditingController _ajouterEntreposageControll =
      TextEditingController();

  late DateTime _arivTime;
  DateTime? _retraitTime;

  String? _chosenValuestade;
  String? _chosenValueeterposage;
  String? _chosenValueetreponsable;
  String? _chosenValueetraisonRetrait;

  bool dateArriveEnable = true;
  bool identifiantEnable = true;
  bool _isdateRetrait = false;
  bool erreurSante = true;

  double _valueSante = 50.0;

  int _numIdentifiant = 1;

  late Plant plant;

  DateTime selectedDate = DateTime.now();

  final List<DropdownMenuItem<String>> _stadeMenuList = [
    DropdownMenuItem(
      value: "initiation",
      child: Text("initiation"),
    ),
    DropdownMenuItem(
      value: "micro dissection",
      child: Text("micro dissection"),
    ),
    DropdownMenuItem(
      value: "magenta",
      child: Text("magenta"),
    ),
    DropdownMenuItem(
      value: "double magenta",
      child: Text("double magenta"),
    ),
    DropdownMenuItem(
      value: "Hydroponie",
      child: Text("Hydroponie"),
    ),
  ];

  final List<DropdownMenuItem<String>> _raisonRetraitMenuList = [
    DropdownMenuItem(
      value: "DESTRUCTION PAR AUTOCLAVE",
      child: Text("DESTRUCTION PAR AUTOCLAVE"),
    ),
    DropdownMenuItem(
      value: "TRANSFERT CLIENT",
      child: Text("TRANSFERT CLIENT"),
    ),
    DropdownMenuItem(
      value: "TRANSFERT AUTRE CENTRE",
      child: Text("TRANSFERT AUTRE CENTRE"),
    ),
    DropdownMenuItem(
      value: "AUTRE (INDIQUER LA RAISON DANS NOTE)",
      child: Text(
        "AUTRE (INDIQUER LA RAISON DANS NOTE)",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ];

  final List<DropdownMenuItem<String>> _reponsableMenuList = [];

  final List<DropdownMenuItem<String>> _eterposageMenuList = [];

  Future<void> fetechEntroposageItems({
    required String collection,
    required List<DropdownMenuItem<String>> droplist,
  }) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collection).get();
      List<DropdownMenuItem<String>> fetchedItems =
          querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return DropdownMenuItem<String>(
          value: data['label'],
          child: Text('${data['label']}'),
        );
      }).toList();
      setState(() {
        droplist.clear();
        droplist.addAll(fetchedItems);
      });
    } catch (e) {
      log("Error fetching entroposage: $e");
    }
  }

  Future<DateTime?> _dateTimePicker(TextEditingController controller) async {
    DateTime? pickedTime = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (pickedTime != null && pickedTime != selectedDate) {
      setState(() {
        selectedDate = pickedTime;
        controller.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
      return pickedTime;
    }
    log("$selectedDate");
  }

  Future<int> numIdentifiant(String nomPlante) async {
    QuerySnapshot snapshot = await _firestore.collection("plante").get();

    int count = 1;
    //List<int> numbers = [];

    for (var doc in snapshot.docs) {
      String identifiant = doc["identifiant"];

      List<String> parts = identifiant.split('.');

      String name = parts[0];

      if (nomPlante == name) {
        count++;
        //numbers.add(int.parse(parts[1]));
      }
      //count = numbers.max + 1;
    }

    return count;
  }

  void initIdentifiant() async {
    int num = await numIdentifiant(_identifController.text);
    setState(() {
      _numIdentifiant = num;
    });

    log(_numIdentifiant.toString());
  }

  bool validatorSante() {
    log('valuesante');
    return _valueSante != 50.0;
  }

  String sante(double value) {
    if (value == 0) {
      return 'Grand danger';
    } else if (value == 25) {
      return 'Mauvaise';
    } else if (value == 75) {
      return 'Moyenne';
    } else if (value == 100) {
      return 'Bonne';
    } else {
      return "";
    }
  }

  double santeInt(String value) {
    if (value == 'Grand danger') {
      return 0;
    } else if (value == 'Mauvaise') {
      return 25;
    } else if (value == 'Moyenne') {
      return 75;
    } else if (value == 'Bonne') {
      return 100;
    } else {
      return -1;
    }
  }

  void initPlante() async {
    if (widget.plant != null) {
      List<String> nom = widget.plant!.identifiant.split(".");
      setState(() {
        log("${santeInt(widget.plant!.sante)}");
        _valueSante = santeInt(widget.plant!.sante);
        _arivTime = widget.plant!.dateArrive;
        dateArriveEnable = false;
        _arivDateTimeControll.text = _arivTime.toString();
        _identifController.text = nom[0];
        identifiantEnable = false;
        _numIdentifiant = int.parse(nom[1]);
        _provenanceControll.text = widget.plant!.provenance;
        _descriptionControll.text = widget.plant!.description ?? "";
        _noteControll.text = widget.plant!.note ?? "";
        _chosenValuestade = widget.plant!.stade;
        _chosenValueeterposage = widget.plant!.entrosposage;
        _chosenValueetreponsable = widget.plant!.responsable;
        _chosenValueetraisonRetrait = widget.plant!.raisonRetrait;
        _retraitDateTimeControll.text =
            widget.plant!.dateRetrait?.toString() ?? "";
        _retraitTime = widget.plant!.dateRetrait;
        if (_retraitTime != null) {
          _inactivActivController.text = "0";
        } else {
          _inactivActivController.text = "1";
        }
      });
    }
  }

  Future<void> addHistoryEntry(String label, String description) async {
    await _firestore.collection('history').add({
      'label': label,
      'date': Timestamp.now(),
      'description': description,
    });
  }

  Future<void> addHistoryForPlant(String label, String description) async {
    await _firestore.collection('historyPlante').add(
        {'label': label, 'date': Timestamp.now(), 'description': description});
  }

  @override
  void initState() {
    super.initState();
    fetechEntroposageItems(
        collection: 'entroposage', droplist: _eterposageMenuList);
    fetechEntroposageItems(
        collection: 'responsable', droplist: _reponsableMenuList);
    initPlante();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(context),
          formulair(context),
          SizedBox(height: 32),
          widget.isModifie ? modifieButtons(context) : actionButtons(context),
          SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget actionButtons(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            log("press");
            int num = await numIdentifiant(_identifController.text);
            log("num");

            setState(() {
              erreurSante = validatorSante();
            });
            log('sante');
            if (erreurSante && _keyForm.currentState!.validate()) {
              log('succes');
              plant = Plant(
                identifiant: "${_identifController.text}.$num",
                sante: sante(_valueSante),
                dateArrive: _arivTime,
                stade: _chosenValuestade!,
                entrosposage: _chosenValueeterposage!,
                activ_inactiv: 1,
                description: _descriptionControll.text,
                dateRetrait: _retraitTime,
                note: _noteControll.text.isEmpty ? null : _noteControll.text,
                raisonRetrait: _chosenValueetraisonRetrait,
                provenance: _provenanceControll.text,
                responsable: _chosenValueetreponsable,
              );
              await _firestore
                  .collection("plante")
                  .doc()
                  .set(plant.toFirestore());
              await addHistoryEntry("Plante ajouter",
                  "Plant avec ID ${plant.identifiant} est ajouter");
              await addHistoryForPlant(plant.identifiant,
                  "La plante ${plant.identifiant} a été créé");
              generateQRCode(context, plant, () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/lobby', (_) => false);
              });
            } else {
              log("message");
            }
          },
          child: Text('Enregistrer'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.changeCurrentScreen(Homescreen(
              changeCurrentScreen: widget.changeCurrentScreen,
              scaffoldKey: widget.scaffoldKey,
            ));
          },
          child: Text('Annuler'),
        ),
      ],
    );
  }

  Widget modifieButtons(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            setState(() {
              erreurSante = validatorSante();
            });
            if (erreurSante && _keyForm.currentState!.validate()) {
              QuerySnapshot querySnapshot = await _firestore
                  .collection("plante")
                  .where('identifiant',
                      isEqualTo: "${_identifController.text}.$_numIdentifiant")
                  .get();

              if (querySnapshot.docs.isNotEmpty) {
                DocumentSnapshot doc = querySnapshot.docs.first;
                DocumentReference docRef = doc.reference;
                Map<String, dynamic> currentData =
                    doc.data() as Map<String, dynamic>;

                Plant newPlant = Plant(
                  identifiant: "${_identifController.text}.$_numIdentifiant",
                  sante: sante(_valueSante),
                  dateArrive: _arivTime,
                  stade: _chosenValuestade!,
                  entrosposage: _chosenValueeterposage!,
                  activ_inactiv: int.parse(_inactivActivController.text),
                  description: _descriptionControll.text,
                  dateRetrait: _retraitTime,
                  note: _noteControll.text.isEmpty ? null : _noteControll.text,
                  raisonRetrait: _chosenValueetraisonRetrait,
                  provenance: _provenanceControll.text,
                  responsable: _chosenValueetreponsable,
                );

                await _firestore.runTransaction((transaction) async {
                  DocumentSnapshot freshSnapshot =
                      await transaction.get(docRef);
                  if (freshSnapshot.exists) {
                    transaction.update(docRef, newPlant.toFirestore());
                  } else {
                    log('Le document n\'existe pas');
                  }
                });

                bool _ismodified = false;
                List<String> changedFields = [];
                newPlant.toFirestore().forEach((key, value) {
                  if (currentData[key] != value) {
                    _ismodified = true;
                    changedFields.add("$key: ${currentData[key]} => $value");
                  } else {
                    if (key == "dateArrive" ||
                        (key == "raisonRetrait" && currentData[key] != null)) {
                      changedFields.add(
                          "$key: ${(currentData[key] as Timestamp).toDate()}");
                    } else {
                      changedFields.add("$key: ${currentData[key]}");
                    }
                  }

                  // if (currentData[key] != value) {
                  //   changedFields.add("$key: ${currentData[key]} => $value");
                  // }
                });

                if (changedFields.isNotEmpty && _ismodified) {
                  String description =
                      "Champs modifiés : ${changedFields.join(',\n')}.";

                  if (_inactivActivController.text == "1") {
                    await addHistoryEntry(
                      "Plante Modifiée",
                      "La plante avec l'ID ${newPlant.identifiant} a été modifiée.",
                    );

                    await addHistoryForPlant(newPlant.identifiant,
                        "La plante ${newPlant.identifiant} a été modifiée. $description, de pui le responsable: ${newPlant.responsable}");
                  } else if (_inactivActivController.text == "0") {
                    await addHistoryEntry(
                      "Plante Archivée",
                      "La plante avec l'ID ${newPlant.identifiant} a été archivée.",
                    );

                    await addHistoryForPlant(newPlant.identifiant,
                        "La plante ${newPlant.identifiant} a été archivée avec la raison ${newPlant.raisonRetrait}. $description de pui le responsable: ${newPlant.responsable}");
                  }
                }

                generateQRCode(context, newPlant, () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/lobby', (_) => false);
                });

                log('Les données de la plante ont été mises à jour avec succès');
              } else {
                log('Aucune plante trouvée avec le nom ${_identifController.text}.$_numIdentifiant');
              }
            }
          },
          child: const Text('Modifier'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.changeCurrentScreen(Homescreen(
              changeCurrentScreen: widget.changeCurrentScreen,
              scaffoldKey: widget.scaffoldKey,
            ));
          },
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  Widget erreurTextSante() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: Text(
        "Sante not null",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget formulair(context) {
    return Form(
      key: _keyForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          menuSanteWidget(),
          if (!erreurSante) erreurTextSante(),
          dateArriveWidget(context),
          identificationWidget(),
          provenanceWidget(),
          descriptionWidget(),
          stadeMenuWidget(),
          entreposageWidget(),
          inactifWidget(),
          if (widget.isModifie) dateRetraitWidget(context),
          if (widget.isModifie)
            if (_isdateRetrait) raisonRetraitWidget(),
          if (widget.isModifie) responsableDecontaminationWidget(),
          noteWidget(),
        ],
      ),
    );
  }

  Widget menuSanteWidget() {
    return SliderSante(
      value: _valueSante,
      onchange: (value) {
        setState(() {
          _valueSante = value;
        });
      },
    );
  }

  Widget dateArriveWidget(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                enabled: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Choose a date";
                  }
                },
                style: Theme.of(context).textTheme.bodyLarge,
                controller: _arivDateTimeControll,
                showCursor: false,
                keyboardType: TextInputType.none,
                decoration: _dateArivTextFieldInputDecoration(),
              ),
            ),
            IconButton(
              onPressed: () async {
                if (!widget.isModifie) {
                  DateTime? date = await _dateTimePicker(_arivDateTimeControll);
                  setState(() {
                    if (date != null) {
                      _arivTime = date;
                      _retraitDateTimeControll.clear();
                      _inactivActivController.text = "1";
                    }
                  });
                }
              },
              icon: const Icon(
                Icons.date_range_outlined,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _dateArivTextFieldInputDecoration() => InputDecoration(
        label: Text("Date d’arrivée"),
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 24),
      );

  Widget identificationWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextFeildForm(
                  enable: identifiantEnable,
                  onFocusChange: initIdentifiant,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "identification not null";
                    }
                  },
                  null,
                  controller: _identifController,
                  defaultValue: null,
                  label: "Identification",
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: MyColors.primeryColor),
                child: Center(
                    child: Text(
                  _numIdentifiant.toString(),
                  style: TextStyle(color: MyColors.background),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget provenanceWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: TextFeildForm(
          validator: (value) {
            if (value!.isEmpty) {
              return "Provenance not null";
            }
          },
          controller: _provenanceControll,
          5,
          onFocusChange: () {},
          defaultValue: null,
          label: "Provenance",
        ),
      ),
    );
  }

  Widget descriptionWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: TextFeildForm(
          5,
          onFocusChange: () {},
          controller: _descriptionControll,
          defaultValue: null,
          label: "Discription",
        ),
      ),
    );
  }

  Widget stadeMenuWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: DropdownButtonFormField<String>(
          validator: (value) {
            if (_chosenValuestade == null) {
              return "Stade not null";
            }
          },
          style: TextStyle(color: MyColors.primeryColor),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: const Color.fromARGB(155, 0, 21, 24),
          value: _chosenValuestade,
          items: _stadeMenuList,
          hint: Text(
            "Stade",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onChanged: (String? value) {
            setState(() {
              _chosenValuestade = value;
            });
          },
        ),
      ),
    );
  }

  Widget entreposageWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  validator: (value) {
                    if (_chosenValueeterposage == null) {
                      return "Entreposage not null";
                    }
                  },
                  style: TextStyle(color: MyColors.primeryColor),
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: const Color.fromARGB(155, 0, 21, 24),
                  value: _chosenValueeterposage,
                  items: _eterposageMenuList,
                  hint: Text(
                    "Entreposage",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _chosenValueeterposage = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 16,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(MyColors.primeryColor)),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Ajouter Entreposage"),
                          content: TextFormField(
                            controller: _ajouterEntreposageControll,
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                String newEntreposage =
                                    _ajouterEntreposageControll.text;

                                setState(() {
                                  _ajouterEntreposageControll.clear();
                                });

                                await _firestore
                                    .collection("entroposage")
                                    .add({'label': newEntreposage});
                                fetechEntroposageItems(
                                    collection: "entroposage",
                                    droplist: _eterposageMenuList);

                                _chosenValueeterposage = newEntreposage;
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          MyColors.background)),
                              child: Text("Ajouter"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_ajouterEntreposageControll
                                    .text.isNotEmpty) {
                                  _ajouterEntreposageControll.clear();
                                }
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          MyColors.background)),
                              child: Text("Annuler"),
                            )
                          ],
                        );
                      });
                },
                child: Icon(
                  Icons.add_outlined,
                  color: MyColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inactifWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: TextFeildForm(
          enable: false,
          1,
          onFocusChange: () {},
          controller: _inactivActivController,
          defaultValue: null,
          label: "inactiv/activ",
        ),
      ),
    );
  }

  Widget dateRetraitWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime? date = await _dateTimePicker(_retraitDateTimeControll);
          if (date != null) {
            setState(() {
              _retraitTime = date;
              _inactivActivController.text = "0";
              _isdateRetrait = true;
            });
          }
        },
        child: AbsorbPointer(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    validator: (value) {},
                    controller: _retraitDateTimeControll,
                    showCursor: false,
                    style: Theme.of(context).textTheme.bodyLarge,
                    keyboardType: TextInputType.none,
                    decoration: _dateRetraitTextFieldInputDecoration(),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    DateTime? date =
                        await _dateTimePicker(_retraitDateTimeControll);
                    if (date != null) {
                      setState(() {
                        _retraitTime = date;
                        _inactivActivController.text = "0";
                        _isdateRetrait = true;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.date_range_outlined,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dateRetraitTextFieldInputDecoration() => InputDecoration(
        label: Text("Date de retrait"),
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 24),
      );

  Widget raisonRetraitWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: DropdownButtonFormField<String>(
          validator: (value) {
            if (_retraitDateTimeControll.text.isNotEmpty &&
                _chosenValueetraisonRetrait == null) {
              return "Raison de retrait not null";
            }
          },
          style: TextStyle(color: MyColors.primeryColor),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: const Color.fromARGB(155, 0, 21, 24),
          value: _chosenValueetraisonRetrait,
          items: _raisonRetraitMenuList,
          hint: Text(
            "Raison initiale de retrait",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onChanged: (String? value) {
            setState(() {
              _chosenValueetraisonRetrait = value;
            });
          },
        ),
      ),
    );
  }

  Widget responsableDecontaminationWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  validator: (value) {
                    if (widget.isModifie) {
                      if (value == null) {
                        return 'responsable invalide';
                      }
                    }
                  },
                  style: TextStyle(color: MyColors.primeryColor),
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: const Color.fromARGB(155, 0, 21, 24),
                  value: _chosenValueetreponsable,
                  items: _reponsableMenuList,
                  hint: Text(
                    "Responsable décontamination",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _chosenValueetreponsable = value!;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 16,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(MyColors.primeryColor)),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Ajouter un Responsable"),
                          content: TextFormField(
                            controller: _ajouterResponsableControll,
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);

                                String newResponsable =
                                    _ajouterResponsableControll.text;
                                setState(() {
                                  _ajouterResponsableControll.clear();
                                });
                                await _firestore
                                    .collection("responsable")
                                    .add({'label': newResponsable});

                                fetechEntroposageItems(
                                    collection: 'responsable',
                                    droplist: _reponsableMenuList);
                                _chosenValueetreponsable = newResponsable;
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          MyColors.background)),
                              child: Text("Ajouter"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_ajouterResponsableControll
                                    .text.isNotEmpty) {
                                  _ajouterResponsableControll.clear();
                                }
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          MyColors.background)),
                              child: Text("Annuler"),
                            )
                          ],
                        );
                      });
                },
                child: Icon(
                  Icons.add_outlined,
                  color: MyColors.background,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget noteWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: TextFeildForm(
          5,
          onFocusChange: () {},
          controller: _noteControll,
          defaultValue: null,
          label: "Note",
        ),
      ),
    );
  }
}
