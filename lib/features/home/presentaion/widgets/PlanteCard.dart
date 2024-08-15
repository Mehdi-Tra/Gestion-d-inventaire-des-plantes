import 'package:flutter/material.dart';
import 'package:rakcha/common/constants/MyColors.dart';
import 'package:rakcha/common/utils/GneratePdf.dart';
import 'package:rakcha/features/home/presentaion/screens/FormulairScreen.dart';
import 'package:rakcha/features/home/presentaion/screens/HistroyPlantScreen.dart';

import '../../../../common/utils/GenerateQrCode.dart';
import '../../../../common/utils/SliderColor.dart';
import '../../data/model/Plante.dart';

class PlantCard extends StatefulWidget {
  final Function(Widget) changeCurrentScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Plant plant;
  const PlantCard(
      {required this.plant,
      required this.scaffoldKey,
      required this.changeCurrentScreen,
      super.key});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Information"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Identifiant: ${widget.plant.identifiant}",
                    style: const TextStyle(color: MyColors.background),
                  ),
                  Text("Santé: ${widget.plant.sante}",
                      style: const TextStyle(color: MyColors.background)),
                  Text(
                      "Date d'Arrivée: ${widget.plant.dateArrive.day}/${widget.plant.dateArrive.month}/${widget.plant.dateArrive.year}",
                      style: const TextStyle(color: MyColors.background)),
                  Text("Provenance: ${widget.plant.provenance}",
                      style: const TextStyle(color: MyColors.background)),
                  Text("Stade: ${widget.plant.stade}",
                      style: const TextStyle(color: MyColors.background)),
                  Text("Entrosposage: ${widget.plant.entrosposage}",
                      style: const TextStyle(color: MyColors.background)),
                  Text("Responsable: ${widget.plant.responsable}",
                      style: const TextStyle(color: MyColors.background)),
                  Text("Activ/Inactiv: ${widget.plant.activ_inactiv}",
                      style: const TextStyle(color: MyColors.background)),
                  if (widget.plant.dateRetrait != null)
                    Text(
                        "Date de Retrait: ${widget.plant.dateRetrait!.day}/${widget.plant.dateRetrait!.month}/${widget.plant.dateRetrait!.year}",
                        style: const TextStyle(color: MyColors.background)),
                  if (widget.plant.raisonRetrait != null)
                    Text("Raison de Retrait: ${widget.plant.raisonRetrait}",
                        style: const TextStyle(color: MyColors.background)),
                  if (widget.plant.description != null)
                    Text("Description: ${widget.plant.description}",
                        style: const TextStyle(color: MyColors.background)),
                  if (widget.plant.note != null)
                    Text("Note: ${widget.plant.note}",
                        style: const TextStyle(color: MyColors.background)),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          border:
              Border.all(width: 4.5, color: getSliderColor(widget.plant.sante)),
          borderRadius: BorderRadius.circular(12),
          color: MyColors.secondBackground,
          boxShadow: [
            BoxShadow(
                color: getSliderColor(widget.plant.sante).withOpacity(0.3),
                offset: Offset(3, 3),
                blurRadius: 10,
                spreadRadius: 2),
            BoxShadow(
                color: getSliderColor(widget.plant.sante).withOpacity(0.3),
                offset: Offset(0, 0),
                blurRadius: 0,
                spreadRadius: 0),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 8, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.plant.identifiant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                          "date : ${widget.plant.dateArrive.day}/${widget.plant.dateArrive.month}/${widget.plant.dateArrive.year} \nsante: ${widget.plant.sante}",
                          style: const TextStyle(
                              color: MyColors.background, fontSize: 12)),
                    )
                  ],
                ),
              ),
            ),
            PopupMenuButton(
                color: MyColors.background,
                style: ButtonStyle(
                  iconColor:
                      WidgetStateProperty.all<Color>(MyColors.background),
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        onTap: () => 
                        generateQRCode(context, widget.plant, () {
                             Navigator.pop(context);
                            }),
                        child: Text(
                          "Imprimer",
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                    PopupMenuItem(
                      child: Text("Modifier",
                          style: Theme.of(context).textTheme.bodyLarge),
                      onTap: () {
                        widget.changeCurrentScreen(Formulairscreen(
                          isModifie: true,
                          scaffoldKey: widget.scaffoldKey,
                          changeCurrentScreen: widget.changeCurrentScreen,
                          plant: widget.plant,
                        ));
                      },
                    ),
                    PopupMenuItem(
                      child: Text("Historique",
                          style: Theme.of(context).textTheme.bodyLarge),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryPlant(
                                    scaffoldKey: widget.scaffoldKey,
                                    label: widget.plant.identifiant)));
                      },
                    ),
                  ];
                })
          ],
        ),
      ),
    );
  }
}
