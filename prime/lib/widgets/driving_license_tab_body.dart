import 'package:flutter/material.dart';

import 'no_data_found.dart';

class DrivingLicenseTabBody extends StatelessWidget {
  const DrivingLicenseTabBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NoDataFound(
      title: 'No Driving License Found',
      subTitle: 'It seems you have not uploaded any driving license yet.',
    );
  }
}
