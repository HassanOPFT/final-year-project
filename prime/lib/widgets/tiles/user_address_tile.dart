import 'package:flutter/material.dart';
import 'package:prime/models/address.dart';

class UserAddressTile extends StatelessWidget {
  final Address? address;
  const UserAddressTile({
    super.key,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            Icon(
              Icons.location_on_rounded,
              size: 50.0,
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(height: 20.0),
            Text(
              'No Address Added',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ],
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_rounded),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
            Text(
              address?.label ?? 'Label',
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
          ],
        ),
        subtitle: Text(address.toString()),
      ),
    );
  }
}
