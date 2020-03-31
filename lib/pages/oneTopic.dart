import 'dart:convert';

import 'package:dotnews/apiKey.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'article.dart';

String topic;

class OneTopic extends StatefulWidget {
  OneTopic(String oneTopic){
    topic = oneTopic;
  }
  @override
  _OneTopicState createState() => _OneTopicState();
}

class _OneTopicState extends State<OneTopic> {
  bool favourite = false;
  int feedLength = 21;
  var data;
  ScrollController _scrollController = ScrollController();
  static DateTime now = DateTime.now();
  String url = "http://newsapi.org/v2/everything?language=de&q=$topic&from=${DateTime(now.year, now.month, now.day-3)
      .toString().substring(0, 10)}&to=${now.toString().substring(0, 10)}&"
      "sortBy=popularity&apiKey=$myApiKey";

  Future<dynamic> getJsonData() async {
    var response = await http.get(Uri.encodeFull(url),
        headers: {"Accept": "application/json"});

    var extractionData = json.decode(response.body);
    setState(() {
      data = extractionData["articles"];
      if(extractionData["totalResults"] < 20){
        feedLength = extractionData["totalResults"];
      }
    });
  }

  //function to check if topic is in favourites
  void isFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    List favourites = prefs.getStringList('favourites') ?? [];
    if(favourites.contains(topic)){
      setState(() {
        favourite = true;
      });
    } else{
      setState(() {
        favourite = false;
      });
    }
  }

  //add to favourites in shared preferences
  Future<void> addToFavourites() async {
      final prefs = await SharedPreferences.getInstance();
      List<String> favourites = prefs.getStringList('favourites') ?? [];
      if(!favourites.contains(topic)){
        favourites.add(topic);
        prefs.setStringList('favourites', favourites);
      }
      setState(() {
        favourite = true;
      });
  }

  //remove from favourites in shared preferences
  void removeFromFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favourites = prefs.getStringList('favourites') ?? [];
    if(favourites.contains(topic)){
      favourites.remove(topic);
      prefs.setStringList('favourites', favourites);
    }

    setState(() {
      favourite = false ;
    });
  }

  @override
  void initState(){
    super.initState();
    getJsonData();
    isFavourite();

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
      body: new ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          controller: _scrollController,
          itemCount: data == null ? 0 : feedLength,
          itemBuilder: (BuildContext context, int index){

            //Current Topic
            if(index == 0){
              return new Container(
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.fromLTRB(15.0, 20.0, 10.0, 10.0),
                      child: new Text(
                        topic,
                        style: new TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red
                        ),
                      ),
                    ),
                    Expanded(
                      child: new Container(),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 20.0, 10.0, 10.0),
                      child: new IconButton(
                        color: Colors.red,
                        icon: new Icon(favourite ? Icons.favorite: Icons.favorite_border),
                        padding: EdgeInsets.all(10.0),
                          onPressed: (){
                            if(favourite){
                              removeFromFavourites();
                            }else{
                              addToFavourites();
                            }
                          }
                      ),
                    )

                  ],
                ),
              );
            }

            //load more indicator
            if(index == feedLength-1){
              return CupertinoActivityIndicator();
            }

            //news cards
            return new Container(
                padding: EdgeInsets.only(bottom: 10.0),
                key: ValueKey(index),
                child: new Center(
                  child: new CupertinoButton(
                      child: new Center(
                          child: new Row(
                            children: <Widget>[
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 5.0),
                                        child: new Text(
                                          data[index]["title"],
                                          style: new TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.zero,
                                          child: new Text(
                                            data[index-1]["source"]["name"],
                                            style: new TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13.0
                                            ),
                                          )
                                      )
                                    ],
                                  )
                              ),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: data[index]["urlToImage"] == null
                                    ? Container(): Image.network(
                                    data[index]["urlToImage"],
                                    width: 100.0),
                              )
                            ],
                          )
                      ),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Article(data[index-1])));
                      }),
                )
            );
          }
      ),
    );
  }
}


