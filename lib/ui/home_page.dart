import 'package:buscar_giphys/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

const urlMelhores =
    "https://api.giphy.com/v1/gifs/trending?api_key=iRMMSi1JbTV57c8TtESvwiQFgXVOqNy6&limit=25&rating=g";
const urlLogo =
    "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController pesquiseAquiController = TextEditingController();
  String? _search;
  int _offSet = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null) {
      response = await http.get((Uri.https("api.giphy.com", "/v1/gifs/trending",
          {"api_key": "iRMMSi1JbTV57c8TtESvwiQFgXVOqNy6", "limit": "20", "rating": "g"})));
    } else {
      response = await http.get(Uri.https("api.giphy.com", "/v1/gifs/trending", {
        "api_key": "iRMMSi1JbTV57c8TtESvwiQFgXVOqNy6",
        "q": "$_search",
        "limit": "19",
        "offset": "$_offSet",
        "rating": "g"
      }));
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(urlLogo),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              textAlign: TextAlign.center,
              controller: pesquiseAquiController,
              style: TextStyle(color: Colors.white, fontSize: 25.8),
              decoration: new InputDecoration(
                  enabledBorder:
                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.white)),
                  focusedBorder:
                      new OutlineInputBorder(borderSide: new BorderSide(color: Colors.white)),
                  labelText: "Pesquise Aqui",
                  labelStyle: TextStyle(color: Colors.white, fontSize: 20.0)),
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return _createGitTable(context, snapshot);
                      }
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search!.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGitTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data['data'].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offSet += 19;
                  });
                },
              ),
            );
          }
        });
  }
}
