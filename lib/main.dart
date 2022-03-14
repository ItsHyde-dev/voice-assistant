import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dialog_flowtter/dialog_flowtter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Speech_UI(),
    );
  }
}

class Speech_UI extends StatefulWidget {
  const Speech_UI({Key? key}) : super(key: key);

  @override
  State<Speech_UI> createState() => _Speech_UIState();
}

class _Speech_UIState extends State<Speech_UI> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  late DialogFlowtter dialogFlow;
  late DialogAuthCredentials credentials;
  @override
  void initState() {
    super.initState();
    getDialogflowCreds().whenComplete(() {
      dialogFlow = DialogFlowtter(credentials: credentials);
    });
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(onStatus: (val) {
      if (val.contains('done')) {
        setState(() {});
      }
    });
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (_speechToText.isNotListening) {
      QueryInput queryInput = QueryInput(
        text: TextInput(text: result.recognizedWords, languageCode: 'en-US'),
      );
      queryInput.text != null ? detectIntent(queryInput) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 300,
      color: Colors.black,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _lastWords,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
            child: GestureDetector(
              onTap: _speechEnabled
                  ? _speechToText.isListening
                      ? _stopListening
                      : _startListening
                  : _initSpeech,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Icon(Icons.mic,
                    size: 50,
                    color:
                        _speechToText.isListening ? Colors.red : Colors.black),
              ),
              // onTap: () {
              //   _startListening();
              // },
            ),
          ),
        ],
      )),
    );
  }

  Widget buttonSmallTransparent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        color: const Color(0xff5537ee),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 16,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          const Text(
            "Videos",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future getDialogflowCreds() async {
    credentials =
        await DialogAuthCredentials.fromFile('assets/dialog_flow_auth.json');
  }

  Future detectIntent(QueryInput queryInput) async {
    DetectIntentResponse response =
        await dialogFlow.detectIntent(queryInput: queryInput);
    switch (response.queryResult?.intent?.displayName) {
      case 'Opening':
      //open an application
    }
    print(response.queryResult?.intent?.displayName);
  }
}
