import 'package:flutter/material.dart';
import 'package:mentor_app/pallete.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SpeechToText speech;
  late FlutterTts flutterTts;
  bool isListening = false;
  String name = "";
  List<Map<String, String>> data = List.generate(
    3,
    (_) => {"subject": "", "marks": ""},
  ); // Add this line to store the data for each iteration
  int counter = 0; // Add this line to keep track of the current iteration

  @override
  void initState() {
    super.initState();
    speech = SpeechToText();
    flutterTts = FlutterTts(); // Start listening when the widget is initialized
  }

  
  void startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (val) async {
          if (val.finalResult) {
            setState(() {
              isListening = false;
              // Store the recognized words based on the current state
              if (name.isEmpty) {
                name = val.recognizedWords;
              } else if (data[counter]["subject"]!.isEmpty) {
                data[counter]["subject"] = val.recognizedWords;
              } else if (data[counter]["marks"]!.isEmpty) {
                data[counter]["marks"] = val.recognizedWords;
                if (counter < 2) {
                  counter++;
                }
              }
            });
          }
        },
      );
    }
  }

  String getFeedback(int marks) {
    // Add this function to give feedback based on marks
    if (marks > 90) {
      return "Excellent work!";
    } else if (marks > 75) {
      return "Good job!";
    } else if (marks > 60) {
      return "Nice effort!";
    } else {
      return "Needs improvement.";
    }
  }

  Future<void> speakFeedback() async {
    for (var e in data) {
      // Loop through each subject
      String feedback = getFeedback(int.tryParse(e["marks"] ?? "0") ?? 0);
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.speak(
          "Feedback for ${e["subject"]}: $feedback"); // Speak the feedback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Mentor App'),
        ),
        backgroundColor: Pallete.firstSuggestionBoxColor,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Column(          
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.jpeg'),
                    ),
                  ),
                ),
              ],
            ),
            // chat bubble
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                top: 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor,
                ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: Radius.zero,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Good Morning , Tell me your name, subject and marks.',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Name: $name",
                      style: const TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.blackColor,
                        fontSize: 25,
                      ),
                    ),
                  ), // Display the recognized name
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.8, // Increase the width of the table
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Pallete.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DataTable(
                        columnSpacing: MediaQuery.of(context).size.width *
                            0.1, // Increase the spacing between columns
                        dividerThickness: 2.0, // Add a line between columns
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Subject',
                              style: TextStyle(
                                fontFamily: 'Cera Pro',
                                color: Pallete.blackColor,
                                fontSize: 25,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Marks',
                              style: TextStyle(
                                fontFamily: 'Cera Pro',
                                color: Pallete.blackColor,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ],
                        rows: data
                            .map((e) => DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text(
                                      "${e["subject"]}",
                                      style: const TextStyle(
                                        fontFamily: 'Cera Pro',
                                        color: Pallete.blackColor,
                                        fontSize: 25,
                                      ),
                                    )),
                                    DataCell(Text(
                                      "${e["marks"]}",
                                      style: const TextStyle(
                                        fontFamily: 'Cera Pro',
                                        color: Pallete.mainFontColor,
                                        fontSize: 25,
                                      ),
                                    )),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),                    
                  if (counter >= 2 && data[2]["marks"]!.isNotEmpty)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 310,
                            child: FloatingActionButton(                                
                              onPressed: speakFeedback,
                              backgroundColor:
                                  Pallete.yellowBtn,
                              child: const Text('Speak Feedback',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                          
                          
                ],
              ),
            ),
          ],
        ),
      ),
      //Mic icon
      floatingActionButton: SizedBox(
        height: 60.0,
        width: 60.0,
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (isListening) {
              setState(() => isListening = false);
              speech.stop();
            } else {
              startListening();
            }
          },
          child: Icon(
            isListening ? Icons.stop : Icons.mic,
            size: 30,
          ),
          // MediaQuery.of(context).size.width *
        ),
      ),
    );
  }
}
