import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotnews/apiKey.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article.dart';

// page to display top 10 recent news in politics
class Dots extends StatefulWidget {
  @override
  _DotsState createState() => _DotsState();
}

class _DotsState extends State<Dots> {
  int _current = 0;
  var data;
  static List<String> myFavourites = ["Wirtschaft"];
  static DateTime now = DateTime.now();
  String url = "http://newsapi.org/v2/everything?language=de&q=Politik&from=${DateTime(now.year, now.month, now.day-1)
      .toString().substring(0, 10)}&to=${now.toString().substring(0, 10)}&"
      "sortBy=popularity&apiKey=$myApiKey";

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  Future<dynamic> getJsonData() async {
    for(int i = 0; i < 10; i++){
      String url = "http://newsapi.org/v2/everything?language=de&q=Politik&from=${DateTime(now.year, now.month, now.day-1)
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
    }
  }

  @override
  void initState() {
    super.initState();
    getJsonData();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CarouselSlider(
            height: MediaQuery.of(context).size.height*0.65,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: [1,2,3,4,5,6,7,8,9,10].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            )
                        ),
                        child: new Container(
                          child: data != null ? new Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.zero,
                                child: data != null ? Image.network(data[i]["urlToImage"]) : Image.asset("images/economy.jpg"),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                                child: new Text(
                                  "${data[i]["title"]} - ${data[i]["source"]["name"]}",
                                  style: new TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                                child: new Text(
                                  data[i]["description"],
                                  style: new TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black
                                  ),
                                ),
                              )
                            ],
                          ): new Column(),
                        )
                    ),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Article(data[i])));
                    },
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>([1,2,3,4,5,6,7,8,9,10], (index, url) {
              return Container(
                width: 5.0,
                height: 5.0,
                margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index ? Colors.black: Colors.grey,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
