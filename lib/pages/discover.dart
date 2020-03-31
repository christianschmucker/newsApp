import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'oneTopic.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  bool switched = false;
  List topicImages = ["images/politics.jpg", "images/economy.jpg", "images/finance.jpg",
    "images/tech.jpg","images/culture.jpg", "images/sports.png"];
  List topics = ["Politik", "Wirtschaft", "Finanzen", "Technik", "Kultur", "Sport"];


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          shrinkWrap: true,
          itemCount: topicImages.length,
          itemBuilder: (BuildContext context, int index){
            return CupertinoButton(
              borderRadius: BorderRadius.zero,
              padding: EdgeInsets.zero,
              child: Container(
                margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                width: MediaQuery.of(context).size.width,
                height: 150.0,
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(topicImages[index]),
                      fit: BoxFit.cover,
                    )
                ),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                      child: new Container(
                        alignment: Alignment.center,
                        child: new Text(
                          topics[index],
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => OneTopic(topics[index])));
              },
            );
          }
      ),
    );
  }
}
