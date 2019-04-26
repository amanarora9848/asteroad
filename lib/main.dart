import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AsteRoad',
      home: MyHomePage(title: 'AsteRoad'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final String url =
      "https://api.nasa.gov/neo/rest/v1/neo/browse?api_key=DEMO_KEY";
  @override
  void initState() {
    super.initState();
    this.getJsonData();
  }

  Future<List> getJsonData() async {
    var rng = new Random();
    int l;
    for (var i = 0; i < 12; i++) {
      l = rng.nextInt(5);
    }
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var init = json.decode(response.body)["near_earth_objects"][l];
    var name = init["name"];
    var diameter = init["estimated_diameter"]["kilometers"]
            ["estimated_diameter_max"]
        .toString();
    var hazard = init["is_potentially_hazardous_asteroid"].toString();
    var date = init["close_approach_data"][0]["close_approach_date"];
    List<String> data = [name, diameter, hazard, date];
    return data;
  }

  double _height;
  double _width;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height,
        width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            image: AssetImage('assets/images/asteroids.jpg'),
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedSize(
                curve: Curves.fastOutSlowIn,
                child: Container(
                  width: _width,
                  height: _height,
                  child: Image(
                    image: AssetImage(
                      'assets/images/nasa.png',
                    ),
                  ),
                ),
                vsync: this,
                duration: Duration(seconds: 3),
              ),
              Container(
                padding: EdgeInsets.all(2.0),
                height: height / 8,
                width: width / 1.12,
                margin: EdgeInsets.all(1.0),
                child: Text(
                  "Welcome to AsteRoad. Get some useful information about asteroids nearby/approaching earth.",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: height / 8,
                width: width / 1.12,
                child: FutureBuilder(
                  future: getJsonData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 4.0,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        height: height / 3,
                        width: width / 1.12,
                        margin: EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Asteroid name: ${snapshot.data[0]}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.5),
                            ),
                            Text(
                              'Diameter: ${snapshot.data[1]} km',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.5),
                            ),
                            Text(
                              'Hazardous?: ${snapshot.data[2]}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.5),
                            ),
                            Text(
                              'Closest Approach Date: ${snapshot.data[3]}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.5),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
