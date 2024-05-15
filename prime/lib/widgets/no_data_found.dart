import 'package:flutter/material.dart';
import '../utils/assets_paths.dart';

class NoDataFound extends StatelessWidget {
  final String noDataFoundImagePath = AssetsPaths.noDataFound;
  final String? title;
  final String? subTitle;

  const NoDataFound({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    String titleString;
    String subTitleString;

    if (title == null || title!.isEmpty) {
      titleString = 'No Data Found';
    } else {
      titleString = title ?? 'No Data Found';
    }

    if (subTitle == null || subTitle!.isEmpty) {
      subTitleString = 'There is no data available at the moment.';
    } else {
      subTitleString = subTitle ?? 'There is no data available at the moment.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            noDataFoundImagePath,
            width: 250,
            height: 250,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          Text(
            titleString,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subTitleString,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
