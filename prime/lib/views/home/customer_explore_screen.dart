import 'package:flutter/material.dart';

import '../../widgets/app_logo.dart';
import '../../widgets/navigation_bar/customer_navigation_bar.dart';

class CustomerExploreScreen extends StatelessWidget {
  const CustomerExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(height: 120),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Item 1'),
                subtitle: Text('Description 1'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 2'),
                subtitle: Text('Description 2'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 3'),
                subtitle: Text('Description 3'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 1'),
                subtitle: Text('Description 1'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 2'),
                subtitle: Text('Description 2'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 3'),
                subtitle: Text('Description 3'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 1'),
                subtitle: Text('Description 1'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 2'),
                subtitle: Text('Description 2'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 3'),
                subtitle: Text('Description 3'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 3'),
                subtitle: Text('Description 3'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 1'),
                subtitle: Text('Description 1'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 2'),
                subtitle: Text('Description 2'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 3'),
                subtitle: Text('Description 3'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 1'),
                subtitle: Text('Description 1'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 2'),
                subtitle: Text('Description 2'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Item 3'),
                subtitle: Text('Description 3'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomerNavigationBar(currentIndex: 0),
    );
  }
}
