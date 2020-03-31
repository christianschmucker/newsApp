import 'package:dotnews/pages/favourites.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'feed.dart';
import 'dots.dart';
import 'discover.dart';
import 'oneTopic.dart';
import 'favourites.dart';

//wrapper class.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> _children = [Dots(), Feed(), Discover()];
  int _currentIndex = 0;
  bool isSearching = false;

  void search(String keyWord){
    String first = keyWord.substring(0, 1);
    keyWord = first.toUpperCase() + keyWord.substring(1);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => OneTopic(keyWord)));
    setState(() {
      isSearching = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,

        //on press searching -> open text field
        title: !isSearching
            ? new Text(
                "Dot.",
                style: new TextStyle(
                    color: Colors.black
                ),
              )
            : TextField(
          onSubmitted: (String value) {
            search(value);
          },
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: Colors.red,
              ),
              hintText: "Suchen",
              hintStyle: TextStyle(color: Colors.white)),
        ),
        actions: <Widget>[
          isSearching ? IconButton(
            icon: Icon(Icons.clear, color: Colors.red,),
              onPressed: () {
                setState(() {
                  this.isSearching = false;
                });
              },
            ) :
            IconButton(
              icon: new Icon(Icons.search, color: Colors.red),
              onPressed: () {
                setState(() {
                  this.isSearching = true;
                });
              },
            ),
            IconButton(
              icon: new Icon(Icons.bookmark_border, color: Colors.red),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Favourites()));
              },
            )

        ],
        backgroundColor: Colors.white,
      ),
      body: new WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: new BottomNavigationBar(
        selectedItemColor: Colors.red,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              title: new Text("Dots")
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.language),
              title: new Text("Feed")
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.label_important),
              title: new Text("Discover")
          ),
        ]
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}






