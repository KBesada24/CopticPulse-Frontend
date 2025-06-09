import 'package:flutter/material.dart';

class PrayerRequestDetailPage extends StatelessWidget {
  const PrayerRequestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Request'),
        backgroundColor: const Color.fromRGBO(253, 250, 245, 1.0),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prayer for Safe Travels',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '“Please join us in praying for the Johnson family as they travel to visit relatives this weekend. May their journey be safe and filled with peace.”',
            ),
            const SizedBox(height: 24),

            // Example of an action button or form
            ElevatedButton.icon(
              onPressed: () {
                // could open a form to submit your own prayer request
              },
              icon: const Icon(Icons.favorite_border),
              label: const Text('Add to My Prayers'),
            ),
          ],
        ),
      ),
    );
  }
}
