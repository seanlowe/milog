import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:milog/model/log.dart';

class LogScreen extends StatefulWidget {
  final Log log;
  LogScreen(this.log);

  @override
  State<StatefulWidget> createState() => new _LogScreenState();
}

final logsReference = FirebaseDatabase.instance.reference().child('Trips');

class _LogScreenState extends State<LogScreen> {
  TextEditingController _vehicleController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _vehicleController = new TextEditingController(text: widget.log.vehicle);
    _descriptionController = new TextEditingController(text: widget.log.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log')),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _vehicleController,
              decoration: InputDecoration(labelText: 'Vehicle'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: (widget.log.id != null) ? Text('Update') : Text('Add'),
              onPressed: () {
                if (widget.log.id != null) {
                  logsReference.child(widget.log.id).set({
                    'vehicle': _vehicleController.text,
                    'description': _descriptionController.text
                  }).then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  logsReference.push().set({
                    'vehicle': _vehicleController.text,
                    'description': _descriptionController.text
                  }).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}