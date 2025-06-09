import 'package:flutter/material.dart';

class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
        backgroundColor: const Color.fromRGBO(253, 250, 245, 1.0),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'New Opening Hours',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Starting next Monday, our community center will be open from 8 AM to 8 PM on weekdays and from 10 AM to 4 PM on weekends.',
            ),
            SizedBox(height: 24),
            Text(
              'Please plan your visits accordingly, and feel free to reach out if you have any questions!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
