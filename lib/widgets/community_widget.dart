import 'package:flutter/material.dart';
import '../models/community_item.dart';
import 'community_card.dart';

/// A widget that displays a vertical list of community cards.
class CommunityWidget extends StatelessWidget {
  /// The items to show in the list.
  final List<CommunityItem> items;

  const CommunityWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return CommunityCard(item: items[index]);
      },
    );
  }
}
