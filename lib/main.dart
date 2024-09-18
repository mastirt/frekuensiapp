import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recognition',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _sound = "Listening...";
  bool _recording = false;
  late Stream<Map<dynamic, dynamic>> result;

  @override
  void initState() {
    super.initState();

    // Load model saat memulai aplikasi
    TfliteAudio.loadModel(
      model: 'assets/soundclassifier.tflite',
      label: 'assets/labels.txt',
      inputType: 'rawAudio',
      numThreads: 1,
      isAsset: true,
    );

    // Langsung memulai pengenalan suara saat aplikasi dijalankan
    _startRecognition();
  }

  void _startRecognition() {
    setState(() => _recording = true);

    // Mulai pengenalan suara real-time
    result = TfliteAudio.startAudioRecognition(
      sampleRate: 44100,
      bufferSize: 8192,
      audioLength: 44032,
      numOfInferences: 3,  // Set ke 0 agar terus berjalan tanpa batas
      detectionThreshold: 0.3,
      suppressionTime: 1000,
    );

    // Mendengarkan hasil pengenalan
    result.listen((event) {
      String recognition = event["recognitionResult"];
      setState(() {
        _sound = recognition.split(" ")[1];  // Update hasil pengenalan suara
      });
    }).onDone(() {
      // Jika stream selesai, restart pengenalan suara
      _startRecognition();  // Memastikan pengenalan suara tetap berjalan terus menerus
    });
  }

  void _stop() {
    TfliteAudio.stopAudioRecognition();
    setState(() => _recording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "What's this sound?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Text(
                '$_sound',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_recording)
                MaterialButton(
                  onPressed: _stop,
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Icon(Icons.stop, size: 60),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(25),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
