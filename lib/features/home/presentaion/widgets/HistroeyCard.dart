import 'package:flutter/material.dart';
import 'package:rakcha/common/constants/MyColors.dart';

class HistoryCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final String description;

  const HistoryCard(
      {required this.date,
      required this.label,
      required this.description,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.primeryColor),
        borderRadius: BorderRadius.circular(12),
        color: MyColors.secondBackground,
        boxShadow: const [
          BoxShadow(
              color: Color.fromARGB(71, 149, 203, 40),
              offset: Offset(3, 3),
              blurRadius: 10,
              spreadRadius: 2),
          BoxShadow(
              color: Color.fromARGB(71, 149, 203, 40),
              offset: Offset(0, 0),
              blurRadius: 0,
              spreadRadius: 0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.headlineSmall,
                  // overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "description : $description",
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: MyColors.background, fontSize: 12),
                      ),
                      Text(
                          "date : ${date.toIso8601String().substring(0, date.toIso8601String().length - 7)}",
                          style: const TextStyle(
                              color: MyColors.background, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
