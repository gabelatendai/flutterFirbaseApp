import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firbase/model/board.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
List<Board> boardMessages = List();
Board board;
final FirebaseDatabase database =  FirebaseDatabase.instance  ;
final GlobalKey<FormState> formKey= GlobalKey<FormState>();
class _MyHomePageState extends State<MyHomePage> {
DatabaseReference databaseReference;
  @override
  void initState(){
    super.initState();
    board= Board("", "");
    databaseReference= database.reference().child("community_Board");
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);

  }


//
//  void _incrementCounter() {
//    database.reference().child("message").set({
//      "firstname":"Gabriel",
//      "Lastname":"Musodza",
//      "Age":45
//    });
//    setState(() {
//      database.reference().child("message").once().then((DataSnapshot snapshot){
//Map< dynamic, dynamic >data = snapshot.value;
//print("Values from db: ${snapshot.value}");
//      });
//     _counter++;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Board"),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (val)=> board.subject=val,
                      validator: (val)=> val==""? val:null,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.message),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (val)=> board.body=val,
                      validator: (val)=> val==""? val:null,
                  )
                  ),
                  //send or Post Button
                  FlatButton(
                    child: Text("Post"),
                    color: Colors.redAccent,
                    onPressed: (){
                      handleSubmit();
                    },
                  ),

                ],
              ),
            )
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: databaseReference,
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation <double> animation, int index){
                return new Card (
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                    ),
                    title: Text(boardMessages[index].subject),
                    subtitle: Text(boardMessages[index].body),

                  ),
                );
              },
            ),
          ),
        ],
      ),
//       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onEntryAdded(Event event) {
    boardMessages.add(Board.fromSnapshot(event.snapshot));
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if(form.validate()){
      form.save();
      form.reset();
      //save to db
      databaseReference.push().set(board.toJson());
    }
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((entry){
      return entry.key == event.snapshot.key;
    });
    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] =
          Board.fromSnapshot(event.snapshot);
    });
  }
}
