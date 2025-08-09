import 'package:coptic_pulse/screens/liturgy_schedule.dart';
import 'package:coptic_pulse/screens/new_post.dart';
import 'package:flutter/material.dart';
import 'package:coptic_pulse/widgets/menu_card.dart';
import 'package:coptic_pulse/screens/announcement_detail_page.dart';
import 'package:coptic_pulse/screens/event_detail_page.dart';
import 'package:coptic_pulse/screens/prayer_request_detail_page.dart';
import 'package:coptic_pulse/models/community_item.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _communityItems = [
    CommunityItem(
      title: 'Events',
      subtitle: 'Join us this Saturday for a community meetup!',
      detailPage: EventDetailPage(),
    ),
    CommunityItem(
      title: 'Announcements',
      subtitle: 'New opening hours coming next week.',
      detailPage: AnnouncementDetailPage(),
    ),
    CommunityItem(
      title: 'Prayer Requests',
      subtitle: 'Please pray for safe travels.',
      detailPage: PrayerRequestDetailPage(),
    ),
    CommunityItem(
      title: 'Liturgy Schedule', 
      subtitle: 'View our liturgy schedule.', 
      detailPage: LiturgyScheduleDetailPage()
    ),
    CommunityItem(
      title: 'New Post', 
      subtitle: 'Create a new post.', 
      detailPage: NewPostPage()
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          ..._communityItems.map((item) => MenuCard(item: item)),
        ],
      ),
    );
  }
}

AppBar appBar() {
  return AppBar(
    title: Text(
      'Menu',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    backgroundColor: Color.fromRGBO(253, 250, 245, 1.0),
    elevation: 0.0,
  );
}