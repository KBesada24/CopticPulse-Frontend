import 'package:flutter/material.dart';
import '../models/community_item.dart';

/// A tappable card that displays a CommunityItem's title and subtitle,
/// and navigates to its detailPage when tapped.
/// This is used for menu items in the home page.
class MenuCard extends StatelessWidget {
  final CommunityItem item;

  const MenuCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            item.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.detailPage),
            );
          },
        ),
      ),
    );
  }
}