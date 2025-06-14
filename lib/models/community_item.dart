import 'package:flutter/widgets.dart';

/// A simple data model for items displayed in the Community screen.
class CommunityItem {
  /// The title shown on the card (e.g. “Event”, “Announcement”).
  final String title;

  /// A brief description or subtitle under the title.
  final String subtitle;

  /// The widget to navigate to (or display) when this card is tapped.
  final Widget detailPage;

  const CommunityItem({
    required this.title,
    required this.subtitle,
    required this.detailPage,
  });
}
