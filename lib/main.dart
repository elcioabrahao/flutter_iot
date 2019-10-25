import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:volume/volume.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool sound = false;
  bool light = false;

  AssetsAudioPlayer _assetsAudioPlayer;
  int maxVol, currentVol;
  bool oldState = false;

  @override
  void initState() {
    super.initState();
    //startListenerSensor();

    _assetsAudioPlayer = AssetsAudioPlayer();
    _assetsAudioPlayer.open(
      AssetsAudio(
        asset: "zepellin.mp3",
        folder: "assets/audios/",
      ),
    );
    _assetsAudioPlayer.playOrPause();

    _assetsAudioPlayer.isPlaying.listen((finished){
      if (!finished && oldState){
        _assetsAudioPlayer.playOrPause();
      }

      oldState = finished;
    });

    Volume.controlVolume(AudioManager.STREAM_MUSIC);
    Volume.getMaxVol.then((volume) {
      print("Volume máximo do aparelho: $volume");
    });
  }

  double _sliderValue = 0.0;
  int statusEletro = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold
      (
        appBar: AppBar
          (
          elevation: 2.0,
          backgroundColor: Colors.white,
          title: Text('Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0)),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                setState(() {
                  sound = !sound;
                });
              },
              child: Text(
                "${sound ? "Som On" : "Som Off"}",
              ),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  light = !light;
                });
              },
              child: Text(
                "${light ? "Luz On" : "Luz Off"}",
              ),
            ),
          ],
        ),
        body: StaggeredGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            _buildTile(
                Column
                  (
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>
                  [
                    Slider(
                      activeColor: Colors.indigoAccent,
                      min: 0.0,
                      max: 15.0,
                      onChanged: (newRating) {
                        if (sound) {
                          if (newRating < 13) {
                            if (statusEletro == 1) {
                              setState(() {
                                statusEletro = 0;
                              });

                              sendData();
                            }
                          } else {
                            if (statusEletro == 0) {
                              setState(() {
                                statusEletro = 1;
                              });

                              sendData();
                            }
                          }
                        }

                        setState(() => _sliderValue = newRating);
                        setVolume();
                      },
                      value: _sliderValue,
                    ),
                  ],
                )

            ),
          ],
          staggeredTiles: [
            StaggeredTile.extent(2, 110.0),
          ],
        )
    );
  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Color(0x802196F3),
        child: InkWell
          (
          // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null ? () => onTap() : () { print('Not set yet'); },
            child: child
        )
    );
  }

  Future<String> sendData() async {
    http.Response response = await http.get(
      Uri.encodeFull("https://ps.pndsn.com/publish/pub-c-b3c97c3a-4572-44ac-91d4-942e9dcecc86/sub-c-052a7e96-86f4-11e9-9f15-ba4fa582ffed/0/flutter_iot_lamp/0/{\"action\":$statusEletro}?uuid=db9c5e39-7c95-40f5-8d71-125765b6f561"),
    );

    print(response.body);
  }


  void setVolume() async {
    await Volume.setVol(_sliderValue.toInt());
  }

}
