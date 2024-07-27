import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rakcha/features/home/presentaion/widgets/MyAppBar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/model/Plante.dart';

class StatisticScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const StatisticScreen({required this.scaffoldKey, super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late StreamSubscription<QuerySnapshot> _subscription;

  List<Plant> listPlant = [];

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

  int getActivePlantCount() {
    return listPlant.where((plant) => plant.activ_inactiv == 1).length;
  }

  int getInactivePlantCount() {
    return listPlant.where((plant) => plant.activ_inactiv == 0).length;
  }

  int getFreeSpace() {
    if (quantiteMax != null) {
      return quantiteMax! - getActivePlantCount();
    } else {
      return -1;
    }
  }

  int getBonnePlantCount() {
    return listPlant
        .where((plant) => plant.sante == "Bonne" && plant.activ_inactiv == 1)
        .length;
  }

  int getMoyennePlantCount() {
    return listPlant
        .where((plant) => plant.sante == "Moyenne" && plant.activ_inactiv == 1)
        .length;
  }

  int getMauvaisePlantCount() {
    return listPlant
        .where((plant) => plant.sante == "Mauvaise" && plant.activ_inactiv == 1)
        .length;
  }

  int getDangerPlantCount() {
    return listPlant
        .where((plant) =>
            plant.sante == "Grand danger" && plant.activ_inactiv == 1)
        .length;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Myappbar(
              scaffoldKey: widget.scaffoldKey,
              title: "Statistiques des Plantes"),
          espaceStatistiqueCircularWidget(),
          espaceStatistiqueTextWidget(),
          santeStatistiqueCircularWidget(),
          santeStatistiqueTextWidget(),
        ],
      ),
    );
  }

  Widget espaceStatistiqueTextWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        runSpacing: 6,
        children: [
          Text(
            'Total des plantes : ${listPlant.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 14),
          Text(
            'Plantes actives : ${getActivePlantCount()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 14),
          Text(
            'Plante archivée : ${getInactivePlantCount()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 14),
          Text('Espace libre : ${getFreeSpace()}'),
        ],
      ),
    );
  }

  Widget espaceStatistiqueCircularWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        child: SfCircularChart(
          title: ChartTitle(
              text: 'Espace',
              textStyle: Theme.of(context).textTheme.titleLarge),
          legend: Legend(
              isVisible: true,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              overflowMode: LegendItemOverflowMode.wrap),
          series: <PieSeries<ChartData, String>>[
            PieSeries<ChartData, String>(
              pointColorMapper: (ChartData data, _) => data.color,
              dataSource: [
                ChartData('Espace Libre', getFreeSpace(), Colors.green),
                ChartData('Plante Actives', getActivePlantCount(), Colors.red),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  showZeroValue: false,
                  textStyle: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget santeStatistiqueTextWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 6,
        children: [
          Text(
            'Plantes en bonne santé : ${getBonnePlantCount()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 14),
          Text(
            'Plantes en santé moyenne : ${getMoyennePlantCount()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 14),
          Text(
            'Plantes en mauvaise santé : ${getMauvaisePlantCount()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 14),
          Text(
            'Plantes en grand danger : ${getDangerPlantCount()}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget santeStatistiqueCircularWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.width * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        child: SfCircularChart(
          title: ChartTitle(
              text: 'État',
              textStyle: Theme.of(context).textTheme.titleLarge),
          legend: Legend(
              isVisible: true,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              overflowMode: LegendItemOverflowMode.wrap),
          series: <PieSeries<ChartData, String>>[
            PieSeries<ChartData, String>(
              pointColorMapper: (ChartData data, _) => data.color,
              dataSource: [
                ChartData('Bonne', getBonnePlantCount(), Colors.green),
                ChartData('Moyenne', getMoyennePlantCount(), Colors.orange),
                ChartData('Mauvaise', getMauvaisePlantCount(), Colors.yellow),
                ChartData('Grand danger', getDangerPlantCount(), Colors.red),
              ],
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  showZeroValue: false,
                  textStyle: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final int y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
