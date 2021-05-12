import 'package:flutter/material.dart';

class NoteDetailPage extends StatelessWidget {
  const NoteDetailPage({this.index, this.note});
  final int index;
  final String note;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Note ${index + 1}'),
        actions: [
          Icon(Icons.search),
          SizedBox(width: 6),
          Icon(Icons.more_vert)
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              note,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.5),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.bookmark_outline),
      ),
    );
  }
}
