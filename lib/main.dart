import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codelab Flutter Firebase',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final db = Firestore.instance;
  var _formKey = GlobalKey<FormState>();
  String name;

  void createData() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      DocumentReference ref = await db.collection('baby').add(
        {
          'name': '$name',
          'votes': 0,
        },
      );
    }
  }

  void deleteData(DocumentSnapshot doc) async {
    await db.collection('baby').document(doc.documentID).delete();
  }

  void _showAddForm() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Add a new baby name:"),
                TextFormField(
                  autofocus: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        createData();
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baby Name Votes')),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForm,
        tooltip: 'Add baby name',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(DocumentSnapshot record) {
    return Dismissible(
      key: Key(record.documentID),
      onDismissed: (direction) => deleteData(record),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.0),
        color: Colors.redAccent,
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.white),
          trailing: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: Padding(
        key: ValueKey(record.documentID),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
              title: Text('${record['name']}'),
              trailing: Text('${record['votes'].toString()}'),
              onTap: () => record.reference
                  .updateData({'votes': FieldValue.increment(1)})),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('baby').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) =>
              _buildListItem(snapshot.data.documents[index]),
        );
      },
    );
  }
}
