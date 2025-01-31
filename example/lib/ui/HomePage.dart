import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsappstickerapi/whatsappstickerapi.dart';
import '../models/stickerPacks.dart';
import '../models/stickers.dart';
import '../models/model.dart';
import 'dart:async';
import 'dart:convert';
import 'StickerDetails.dart';
import 'package:dio/dio.dart';

class MyHomePage extends StatefulWidget {
  final List<StickerPacks> asdf;

  MyHomePage(this.asdf);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String url = 'https://gist.githubusercontent.com/viztushar/e359e5aeadc4fcfece7b48149fb580fe/raw/' +
      'b58fe6d6d0607a423d9a6ba5fd0a4ec3a0b8f2c4/whatsapp.json';
  StickerPacks stickerPack = StickerPacks();
  List<StickerPacks> st;
  bool isDownloading = true;
  int iD = -1;
  List<String> downloadList = [];
  List<String> stickerImageList = [];
  @override
  void initState() {
    super.initState();
    iD = -1;
    st = widget.asdf;
  }

  navigateToDetailsScreen(id, context) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return MyStickerDetails(
        stickerPacks: st[id],
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sticker Name"),
      ),
      body: Container(
        child: Center(
          child: ListView.builder(
            itemCount: st.length,
            itemBuilder: (context, i) {
              return Card(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          navigateToDetailsScreen(i, context);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  st[i].name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' • ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  st[i].publisher,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              direction: Axis.horizontal,
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Image.network(
                                      st[i].sticker[0].imagefile,
                                      height: 70.0,
                                      width: 70.0,
                                    ),
                                    Image.network(
                                      st[i].sticker[1].imageFile,
                                      height: 70.0,
                                      width: 70.0,
                                    ),
                                    Image.network(
                                      st[i].sticker[2].imageFile,
                                      height: 70.0,
                                      width: 70.0,
                                    ),
                                    st[i].sticker.length > 3
                                        ? Image.network(
                                            st[i].sticker[3].imageFile,
                                            height: 70.0,
                                            width: 70.0,
                                          )
                                        : SizedBox(
                                            width: 70.0,
                                            height: 70.0,
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              if (!downloadList.contains(st[i].identiFier))
                                iD == i && !isDownloading
                                    ? CircularProgressIndicator()
                                    : IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            iD = i;
                                            isDownloading = false;
                                            downloadSticker(st[i]);
                                          });
                                        },
                                      ),
                              if (downloadList.contains(st[i].identiFier))
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      iD = i;
                                      print(i);
                                      addToWhatsapp(st[i]);
                                    });
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> addToWhatsapp(StickerPacks s) async {
    try {
      print(s.identiFier);
      print(s.name);
      WhatsappstickerApi.addStickerPackToWhatsApp(identifier: s.identiFier, name: s.name);
    } on PlatformException catch (e) {
      print(e.details);
    }
  }

  Future<void> downloadSticker(StickerPacks s) async {
    if (s.publisherEmail == null) s.publisherEmail = "0";
    print((s.publisherEmail == null).toString() +
        s.identiFier +
        " " +
        s.name +
        " " +
        s.publisher +
        " " +
        s.trayImageFile +
        " " +
        s.publisherEmail +
        " " +
        s.publisherWebsite +
        " " +
        s.privacyPolicyWebsite +
        " " +
        s.licenseAgreementWebsite.contains("").toString() +
        " ");

    stickerImageList.clear();
    if (!downloadList.contains(s.identiFier)) {
      await Permission.storage.request();
      Dio dio = Dio();
      var dirToSave = await getApplicationDocumentsDirectory();
      var path =
          await Directory(dirToSave.path + "/" + "stickers_asset" + "/" + s.identiFier + "/").create(recursive: true);
      var trypath = await Directory(dirToSave.path + "/" + "stickers_asset" + "/" + s.identiFier + "/try/")
          .create(recursive: true);
      print(path.path + "\n" + trypath.path);

      String tryFilePath = trypath.path + basename(s.trayImageFile);
      print(tryFilePath);
      await dio.download(s.trayImageFile, tryFilePath, onReceiveProgress: (rec, total) {
        print((rec / total) * 100);
        print("try image downloaded");
      });

      for (int i = 0; i < s.sticker.length; i++) {
        String imageFilePath = path.path + basename(s.sticker[i].imageFile);
        stickerImageList.add(basename(s.sticker[i].imageFile));
        await dio.download(s.sticker[i].imageFile, imageFilePath, onReceiveProgress: (rec, total) {
          print((rec / total) * 100);
        });
      }
      await addToJson(s);
    } else {
      print("not");
    }
  }

  Future<void> addToJson(StickerPacks s) {
    try {
      WhatsappstickerApi.addToJson(
              identiFier: s.identiFier,
              name: s.name,
              publisher: s.publisher,
              trayimagefile: basename(s.trayImageFile),
              publisheremail: s.publisherEmail,
              publisherwebsite: s.publisherWebsite,
              privacypolicywebsite: s.privacyPolicyWebsite,
              licenseagreementwebsite: s.licenseAgreementWebsite,
              imagedataversion: "1",
              avoidcache: false,
              stickerImages: stickerImageList)
          .then((value) {
        print(value);
      });
    } on PlatformException catch (e) {
      print(e.details);
    }
    setState(() {
      isDownloading = true;
      if (!downloadList.contains(s.identiFier)) {
        downloadList.add(s.identiFier);
      }
    });
  }

  Future<void> showDialogs(context) {
    AlertDialog s = AlertDialog(
      content: Row(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(
            width: 10,
          ),
          Text("Downloading..."),
        ],
      ),
    );
    return showDialog(
      context: context,
      builder: (context) {
        return s;
      },
    );
  }
}
