import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  String sante;
  DateTime dateArrive;
  String identifiant;
  String provenance;
  String stade;
  String entrosposage;
  String? responsable;
  int activ_inactiv;
  String? description;
  DateTime? dateRetrait;
  String? raisonRetrait;
  String? note;

  Plant({
    required this.identifiant,
    required this.sante,
    required this.dateArrive,
    required this.stade,
    required this.entrosposage,
    required this.activ_inactiv,
    required this.provenance,
    required this.responsable,
    this.dateRetrait,
    this.raisonRetrait,
    this.description,
    this.note,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      identifiant: json['identifiant'],
      sante: json['sante'],
      dateArrive: DateTime.parse(json['dateArrive']),
      stade: json['stade'],
      entrosposage: json['entrosposage'],
      activ_inactiv: json['activ_inactiv'],
      provenance: json['provenance'],
      responsable: json['responsable'],
      dateRetrait: json['dateRetrait'] != null ? DateTime.parse(json['dateRetrait']) : null,
      description: json['description'],
      note: json['note'],
      raisonRetrait: json['raisonRetrait'],
    );
  }

  factory Plant.fromFirestore(Map<String, dynamic> json) {
    return Plant(
      identifiant: json['identifiant'],
      sante: json['sante'],
      dateArrive: (json['dateArrive'] as Timestamp).toDate(),
      stade: json['stade'],
      provenance: json['provenance'],
      responsable: json['responsable'],
      entrosposage: json['entrosposage'],
      activ_inactiv: json['activ_inactiv'],
      description: json['description'],
      dateRetrait: json['dateRetrait'] != null ? (json['dateRetrait'] as Timestamp).toDate() : null,
      note: json['note'],
      raisonRetrait: json['raisonRetrait'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifiant': identifiant,
      'sante': sante,
      'dateArrive': dateArrive.toIso8601String(),
      'stade': stade,
      'provenance': provenance,
      'responsable': responsable,
      'entrosposage': entrosposage,
      'activ_inactiv': activ_inactiv,
      'dateRetrait': dateRetrait?.toIso8601String(),
      'raisonRetrait': raisonRetrait,
      'description': description,
      'note': note,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'identifiant': identifiant,
      'sante': sante,
      'dateArrive': Timestamp.fromDate(dateArrive),
      'stade': stade,
      'entrosposage': entrosposage,
      'activ_inactiv': activ_inactiv,
      'description': description,
      'dateRetrait': dateRetrait != null ? Timestamp.fromDate(dateRetrait!) : null,
      'note': note,
      'raisonRetrait': raisonRetrait,
      'provenance': provenance,
      'responsable': responsable,
    };
  }
}
