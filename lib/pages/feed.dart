import 'package:dotnews/apiKey.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'article.dart';
import 'package:dotnews/apiKey.dart';

class Feed extends StatefulWidget {
  @override
  _HomeStateContent createState() => _HomeStateContent();
}

class _HomeStateContent extends State<Feed> {
  static List<String> myFavourites = [];
  ScrollController _scrollController = ScrollController();
  static DateTime now = DateTime.now();
  int feedLength = 20;
  List data;      //list of news articles

  // method to retrieve articles from the last 3 days (all favourite topics)
  Future<dynamic> getJsonData() async {
    for(int i = 0; i < myFavourites.length; i++){
      String url = "http://newsapi.org/v2/everything?language=de&q=${myFavourites[i]}&from=${DateTime(now.year, now.month, now.day-3)
          .toString().substring(0, 10)}&to=${now.toString().substring(0, 10)}&"
          "sortBy=popularity&apiKey=$myApiKey";

      var response = await http.get(Uri.encodeFull(url),
          headers: {"Accept": "application/json"});
      var extractionData = json.decode(response.body);
      List dataPart = extractionData["articles"];
      for(int j = 0; j < dataPart.length; j++){
        if(data == null)
          data = [];
        data.add(dataPart[j]);
      }
    }

    // remove google news (problem: articles can't be displayed in WebView)
    if(data != null){
      //filter
      List articles = [];
      for(int i = 0; i < data.length; i++){
        if(articles.contains(data[i]["title"]) || data[i]["source"]["name"] == "Google News") {
          data.remove(data[i]);
        }
        else {
          articles.add(data[i]["title"]);
        }
      }

      //sort the items by time
      data.sort((a, b){
        return (a["publishedAt"]).compareTo(b["publishedAt"]);
      });
      setState(() {
        if(data.length < 20){
          feedLength = data.length;
        }
      });
    }
  }

  // updates the list of favourite topics
  void checkFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favourites = prefs.getStringList('favourites') ?? [];
    if(favourites.isNotEmpty){
      setState(() {
        myFavourites = favourites;
      });
    }
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 2));
    setState(() async {
      data = null;
      myFavourites = [];
    });
    checkFavourites();
    getJsonData();
    return null;
  }

  @override
  void initState(){
    super.initState();
    checkFavourites();
    getJsonData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if((feedLength + 10) < data.length){
          feedLength += 10;
          setState(() { });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new RefreshIndicator(
        color: Colors.redAccent,
          child: new ListView.builder(
          controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: data == null ? 0 : feedLength,
              itemBuilder: (BuildContext context, int index){
                if(index == feedLength-1){
                  return CupertinoActivityIndicator();
                }else{
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
                                                  data[index]["source"]["name"],
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
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Article(data[index])));
                            }),
                      )
                  );
                }
              }
          ),
          onRefresh: _handleRefresh
      )
    );
  }
}