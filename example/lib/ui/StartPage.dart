import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsappsticker_api_example/ui/HomePage.dart';
import 'package:whatsappstickerapi/whatsappstickerapi.dart';
import '../models/stickerPacks.dart';
import '../models/stickers.dart';
import '../models/model.dart';
import 'dart:async';
import 'dart:convert';
import 'StickerDetails.dart';
import 'package:dio/dio.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final String url = 'https://gist.githubusercontent.com/viztushar/e359e5aeadc4fcfece7b48149fb580fe/raw/' +
      'b58fe6d6d0607a423d9a6ba5fd0a4ec3a0b8f2c4/whatsapp.json';

  List<StickerPacks> st = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    this.getJsonData();
  }

  Future getJsonData() async {
    st = [];
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"},
    );
    setState(() {
      Map datas = jsonDecode(response.body);
      Model m = Model.formJson(datas);
      for (Map<String, dynamic> json in m.stickerPac) {
        List<Stickers> s = [];
        for (Map<String, dynamic> stickers in json['stickers']) {
          s.add(Stickers(imagefile: stickers['image_file'], emojis: stickers['emojis']));
        }
        print(json['publisher_email'] +
            " " +
            json['publisher_website'] +
            " " +
            json['privacy_policy_website'] +
            " " +
            json['license_agreement_website'] +
            " ");
        st.add(StickerPacks(
            identifier: json['identifier'],
            name: json['name'],
            publisher: json['publisher'],
            trayimagefile: json['tray_image_file'],
            publisheremail: json['publisher_email'],
            publisherwebsite: json['publisher_website'],
            privacypolicywebsite: json['privacy_policy_website'],
            licenseagreementwebsite: json['license_agreement_website'],
            stickers: s));
      }
      isLoading = false;
    });
  }

  navigateToDetailsScreen(id, context) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return MyStickerDetails(
        stickerPacks: st[id],
      );
    }));
  }

  startPressed(context) {
    //abrir home page
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return MyHomePage(st);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Start"),
      ),
      body: Container(
        child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    child: Text('open home page'),
                    onPressed: () => startPressed(context),
                  )),
      ),
    );
  }
}
