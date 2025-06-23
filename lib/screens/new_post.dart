import 'package:flutter/material.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  State<NewPostPage> createState() => NewPostPageState();
}

class NewPostPageState extends State<NewPostPage> {
  final TextEditingController postController = TextEditingController();

  void _submitPost() {
    final text = postController.text.trim();
    if (text.isNotEmpty) {
      // Handle submission logic here (e.g., send to backend or display it)
      print("Submitted post for approval: $text");
      postController.clear(); // clear input after submit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post submitted for approval!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post content cannot be empty.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
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
              'Create a New Post',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This is where you can create a new post for the community.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: postController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Your Post',
                hintText: 'What’s on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitPost,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
