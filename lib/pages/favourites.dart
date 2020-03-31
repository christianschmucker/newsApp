import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// page to manage favourites
class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  List<String> myFavourites = [];
  int elements = 1;

  // delete Dialog popup
  deleteDialog(String topic){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: new Text("Löschen"),
            content: new Text("$topic von Favoriten entfernen?"),
            actions: <Widget>[
              new FlatButton(
                  onPressed: (){
                    setState(() {
                      removeFromFavourites(topic);
                      checkFavourites();
                    });
                    Navigator.of(context).pop();
                  },
                  child: new Text("Ja")),
              new FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: new Text("Abbruch"))
            ],
          );
        }
    );
  }

  // updates the list of favourite topics
  void checkFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favourites = prefs.getStringList('favourites') ?? [];
    if(favourites.isNotEmpty){
      setState(() {
        myFavourites = favourites;
        elements = myFavourites.length + 1;
      });
    }
  }
  
  //remove topic from favourites in shared preferences
  void removeFromFavourites(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favourites = prefs.getStringList('favourites') ?? [];
    if(favourites.contains(topic)){
      favourites.remove(topic);
      prefs.setStringList('favourites', favourites);
    }
  }

  @override
  void initState() {
    super.initState();
    checkFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text(
          "Dot.",
          style: new TextStyle(
              color: Colors.black
          ),
        ),
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back_ios,
            color: Colors.red,
          ),
          onPressed: () => Navigator.of(context).pop()
        ),
        backgroundColor: Colors.white,
      ),
      body: new Container(
        child: new ListView.builder(
          itemCount: elements,
          itemBuilder: (BuildContext context, int index){
            if(index == 0){
              return new Container(
                padding: EdgeInsets.fromLTRB(15.0, 20.0, 10.0, 10.0),
                child: new Text(
                  "Favoriten",
                  style: new TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red
                  ),
                ),
              );
            }
            return new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.fromLTRB(15.0, 20.0, 10.0, 10.0),
                  margin: EdgeInsets.zero,
                  child: new Text(
                    myFavourites[index - 1],
                    style: new TextStyle(
                      fontSize: 16.0,
                    ),
                  )
                ),
                new Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.zero,
                  child: new IconButton(
                    padding: EdgeInsets.only(right: 15.0),
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: (){
                      deleteDialog(myFavourites[index-1]);
                    }
                  ),
                )
              ],
            );
          }
        ),
      ),
    );
  }
}
