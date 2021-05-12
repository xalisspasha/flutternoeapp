import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutternoteapp/pages/note_detail_page.dart';
import 'package:flutternoteapp/models/note.dart';
import 'package:http/http.dart' as http;

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String description = '';

  Future addEditNote({Note note}) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: note?.description ?? '',
                    decoration: InputDecoration(
                      labelText: 'description',
                    ),
                    minLines: 2,
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (description == '') return Navigator.pop(context);
                note == null ? await addNote() : await editNote(note.id);
                setState(() {});
                Navigator.of(context).pop();
                description = '';
              },
              child: Text(note == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Note>> getAllNotes() async {
    final url = 'https://note-app-api-assignment.herokuapp.com/api/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = await json.decode(response.body) as Map<String, dynamic>;
      final notes = data['data'] as List;
      return notes
          .map((note) => Note.fromJson(note))
          .toList()
          .reversed
          .toList();
    } else
      throw Exception(response.statusCode);
  }

  Future<void> addNote() async {
    final url = 'https://note-app-api-assignment.herokuapp.com/api/';
    try {
      await http.post(
        Uri.parse(url),
        body: json.encode({
          'note': description,
        }),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        },
      );
    } catch (e) {
      throw Exception(e.message());
    }
  }

  Future<void> editNote(String id) async {
    final url = 'https://note-app-api-assignment.herokuapp.com/api/$id';
    await http.put(
      Uri.parse(url),
      body: json.encode({
        '_id': id,
        'note': description,
      }),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      },
    );
  }

  Future<void> deleteNote(String id) async {
    final url = 'https://note-app-api-assignment.herokuapp.com/api/$id';
    await http.delete(
      Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [Icon(Icons.search), SizedBox(width: 10)],
      ),
      body: FutureBuilder<List<Note>>(
        future: getAllNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final notesList = snapshot.data;
            return GridView.builder(
              padding: EdgeInsets.all(10),
              itemCount: notesList.length,
              itemBuilder: (BuildContext context, int index) {
                final note = notesList[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300], width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.grey[300], blurRadius: 6),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GridTile(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return NoteDetailPage(
                                  index: index,
                                  note: note.description,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(note.description),
                        ),
                      ),
                      footer: GridTileBar(
                        leading: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Warning!'),
                                  content: Text('Are You Sure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await deleteNote(notesList[index].id);
                                        setState(() {});
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        backgroundColor: Colors.black,
                        title: Text(
                          'Note ${index + 1}',
                          textAlign: TextAlign.center,
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            addEditNote(note: note);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2 / 1.5,
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addEditNote,
      ),
    );
  }
}
