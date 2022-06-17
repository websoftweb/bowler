// @dart=2.9
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({Key key}) : super(key: key);

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _playerRoundLegformKey = GlobalKey<FormState>();
  bool isGameStarted = false;
  int playerCount = 1;
  List players = [];
  Map selectedPlayer;
  int selectedPlayerIndex = 0;
  int selectedRound = 0;
  String genericLeg1 = "0";
  String genericLeg2 = "0";

  _considerStartingANewGame() {
    setState(() {
      isGameStarted = isGameStarted ? false : true;
      playerCount = 1;
      players = [];
    });
  }

  _considerAddingPlayer() {
    Map legMap = {};
    legMap["leg_1"] = 0;
    legMap["leg_2"] = 0;
    legMap["leg_aggregate"] = 0;
    List stage = List.generate(12, (index) {
      return legMap;
    });
    Map playerData = {};
    playerData["name"] = "Player ${playerCount.toString()}";
    playerData["total_score"] = 0;
    playerData["stages"] = stage;
    setState(() {
      players.add(playerData);
    });
    playerCount++;
    debugPrint(players.toString());
  }

  _considerShowingPlayerLegData(int playerIndex, int legIndex) {
    // debugPrint("${playerIndex} - ${legIndex}");
    setState(() {
      selectedPlayerIndex = playerIndex;
      selectedPlayer = players[playerIndex];
      selectedRound = legIndex;
    });
    _considerShowingPlayerScoreInputDialog(context);
  }

  List _calculateScoreMatrix(List stages) {
    List updatedStages = stages;
    if (stages != null && stages.isNotEmpty) {
      int loopIndex = 0;
      for (var stage in stages) {
        int leg1 = stage['leg_1'];
        int leg2 = stage['leg_2'];
        int leg1sumleg2 = leg1 + leg2;
        int legAggregate = 0;
        int prevAggregate = 0;
        if (loopIndex > 0) {
          prevAggregate = stages[loopIndex - 1]['leg_aggregate'];
        }
        debugPrint(prevAggregate.toString());
        Map legMap = {};
        if (leg1 > 9) {
          //strike
          //get and add the future 2 shots
          if (loopIndex < 11) {
            int nextDistantFuture = 0;
            int nextNearFuture = stages[loopIndex + 1]['leg_1'];
            nextDistantFuture = stages[loopIndex + 2]['leg_1'];
            if (nextNearFuture < 10) {
              nextDistantFuture = stages[loopIndex + 1]['leg_2'];
            }
            legAggregate =
                prevAggregate + (leg1 + nextNearFuture + nextDistantFuture);

            legMap["leg_1"] = leg1;
            legMap["leg_2"] = leg2;
            legMap["leg_aggregate"] = legAggregate;
            updatedStages[loopIndex] = legMap;
          }
        } else if (leg1sumleg2 > 9) {
          //spare
          if (loopIndex < 11) {
            int nextNearFuture = stages[loopIndex + 1]['leg_1'];
            legAggregate = prevAggregate + (leg1 + leg2 + nextNearFuture);

            legMap["leg_1"] = leg1;
            legMap["leg_2"] = leg2;
            legMap["leg_aggregate"] = legAggregate;
            updatedStages[loopIndex] = legMap;
          }
        } else {
          //open
          if (leg1sumleg2 < 10 && leg1sumleg2 > 0) {
            if (loopIndex < 11) {
              legAggregate = prevAggregate + leg1sumleg2;

              legMap["leg_1"] = leg1;
              legMap["leg_2"] = leg2;
              legMap["leg_aggregate"] = legAggregate;
              updatedStages[loopIndex] = legMap;
            }
          }
        }
        // else {
        //   if (leg1 + leg2 > 9) {
        //     //Spare
        //     //get and add the future 1 shot
        //     if (loopIndex < 11) {
        //       int nextNearFuture = stages[loopIndex + 1]['leg_1'];
        //       int prevAggregate = 0;
        //       if (loopIndex > 0) {
        //         prevAggregate = stages[loopIndex - 1]['leg_aggregate'];
        //       }
        //       legAggregate = prevAggregate + (leg1 + leg2 + nextNearFuture);

        //       legMap["leg_1"] = leg1;
        //       legMap["leg_2"] = leg2;
        //       legMap["leg_aggregate"] = legAggregate;
        //       updatedStages[loopIndex] = legMap;
        //     }
        //   } else {
        //     if (leg1 + leg2 < 10) {
        //       if (loopIndex < 11) {
        //         int prevAggregate = 0;
        //         if (loopIndex > 0) {
        //           prevAggregate = stages[loopIndex - 1]['leg_aggregate'];
        //         }
        //         legAggregate = prevAggregate + leg1 + leg2;

        //         legMap["leg_1"] = leg1;
        //         legMap["leg_2"] = leg2;
        //         legMap["leg_aggregate"] = legAggregate;
        //         updatedStages[loopIndex] = legMap;
        //       }
        //     }
        //   }
        // }
        loopIndex++;
      }
    }
    return updatedStages;
  }

  _considerSavingPlayerLegData(BuildContext context) async {
    // debugPrint(selectedPlayer.toString());
    _playerRoundLegformKey.currentState.save();
    int leg1 = genericLeg1.toLowerCase() == "x" ? 10 : int.parse(genericLeg1);
    int leg2 = int.parse(genericLeg2);
    Map legMap = {};
    legMap["leg_1"] = leg1;
    legMap["leg_2"] = leg2;
    legMap["leg_aggregate"] = leg1 + leg2;

    List stages = _calculateScoreMatrix(selectedPlayer['stages']);
    var stage = legMap;
    stages[selectedRound] = stage;

    selectedPlayer['stages'] = stages;
    setState(() {
      players[selectedPlayerIndex] = selectedPlayer;
    });
    Navigator.pop(context);
    _considerShowingCelebration(selectedPlayer);
  }

  _showStrikeCelebration(String playerName) {
    _considerShowingGenericAlert(
        context, "Congrats $playerName", "It's a strike...");
  }

  _showSpareCelebration(String playerName) {
    _considerShowingGenericAlert(
        context, "Congrats $playerName", "It's a spare...");
  }

  _considerShowingCelebration(Map selectedPlayer) {
    var stage = selectedPlayer['stages'];
    String playerName = selectedPlayer['name'];
    var stageRound = stage[selectedRound];
    genericLeg1 = stageRound['leg_1'].toString();
    genericLeg2 = stageRound['leg_2'].toString();
    if (int.parse(genericLeg1) > 9) {
      //strike alert
      _showStrikeCelebration(playerName);
    } else if ((int.parse(genericLeg1) + int.parse(genericLeg2)) > 9) {
      // spare alert
      _showSpareCelebration(playerName);
    }
  }

  _considerShowingPlayerScoreInputDialog(BuildContext context) {
    var stage = selectedPlayer['stages'];
    String playerName = selectedPlayer['name'];
    var stageRound = stage[selectedRound];
    genericLeg1 = stageRound['leg_1'].toString();
    genericLeg2 = stageRound['leg_2'].toString();
    int roundDisplay = selectedRound + 1;
    Widget formContent = Material(
        child: Form(
      key: _playerRoundLegformKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: genericLeg1.toString(),
            decoration: InputDecoration(labelText: 'Leg 1'),
            onSaved: (input) => genericLeg1 = input,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              //only numeric keyboard.
              LengthLimitingTextInputFormatter(1), //only 6 digit
              // WhitelistingTextInputFormatter.digitsOnly
            ],
            initialValue: genericLeg2.toString(),
            decoration: InputDecoration(labelText: 'Leg 2'),
            onSaved: (input) => genericLeg2 = input,
          )
        ],
      ),
    ));
    var alertTitle = "Round ${roundDisplay.toString()} \n$playerName";
    // var alertBody = "Do you want to sign out?";
    var alertCancelButtonTitle = "Cancel";
    var alertConfirmButtonTitle = "Save";
    if (kIsWeb || Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              alertTitle,
              // style: TextStyle(color: Color(globals.defaultAppSolidColor))
            ),
            content: formContent,
            actions: <Widget>[
              FlatButton(
                  child: Text(alertConfirmButtonTitle),
                  onPressed: () {
                    _considerSavingPlayerLegData(context);
                  }),
              FlatButton(
                child: Text(alertCancelButtonTitle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              "$alertTitle",
              // style: TextStyle(color: Color(globals.defaultAppSolidColor))
            ),
            content: formContent,
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(alertCancelButtonTitle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(alertConfirmButtonTitle),
                onPressed: () {
                  _considerSavingPlayerLegData(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  _considerShowingGenericAlert(BuildContext context, alertTitle, alertBody) {
    var alertCancelButtonTitle = "OK";
    if (kIsWeb || Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              alertTitle,
            ),
            content: Text(alertBody),
            actions: <Widget>[
              FlatButton(
                child: Text(alertCancelButtonTitle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              "$alertTitle",
            ),
            content: Text("\n$alertBody"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(alertCancelButtonTitle),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    Widget gameSelection = Center(
      child: Container(
          color: Colors.amberAccent,
          child: Wrap(
            children: [
              Card(
                child: InkWell(
                  onTap: () {
                    _considerStartingANewGame();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Text("Start A New Game"),
                  ),
                ),
              ),
              Card(
                child: InkWell(
                  onTap: () {},
                  child: const Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Text("Leaderboard")),
                ),
              )
            ],
          )),
    );
    return Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Bowler"),
          actions: [
            Visibility(
              visible: isGameStarted ? true : false,
              child: IconButton(
                  // onPressed: (){
                  //   setState(() {
                  //     isGameStarted = isGameStarted ? false : true;
                  //   }),
                  // })
                  onPressed: () {
                    setState(() {
                      isGameStarted = isGameStarted ? false : true;
                    });
                  },
                  icon: const Icon(Icons.close)),
            )
          ],
        ),
        body: isGameStarted
            ? Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Container(
                    color: Colors.blue,
                    child: ListView(
                        children: List.generate(
                            players != null ? players.length : 0, (yindex) {
                      Map player = players[yindex];
                      var stages = player['stages'];
                      String playerName = player['name'];
                      return Card(
                        child: Container(
                          color: yindex.isEven ? Colors.white : Colors.black12,
                          height: 100,
                          child: Row(
                            children: [
                              Container(width: 100, child: Text(playerName)),
                              Container(
                                width: screenSize.width - 200,
                                color: Colors.black26,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: List.generate(10, (xindex) {
                                    var stage = stages[xindex];
                                    int leg1 = stage['leg_1'];
                                    int leg2 = stage['leg_2'];
                                    int legAggr = stage['leg_aggregate'];
                                    return InkWell(
                                      onTap: () {
                                        _considerShowingPlayerLegData(
                                            yindex, xindex);
                                      },
                                      child: Container(
                                        color: xindex.isEven
                                            ? Colors.amberAccent
                                                .withOpacity(0.3)
                                            : Colors.amberAccent,
                                        width: 100,
                                        child: Center(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Text(
                                                    "${leg1.toString()} | ${leg2.toString()}",
                                                    style: TextStyle(
                                                        fontSize: 22)),
                                              ),
                                              Container(
                                                child: Text(
                                                  legAggr.toString(),
                                                  style:
                                                      TextStyle(fontSize: 35),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                      // ListTile(title: Text("$playerName"));
                    })
                        // [
                        //   Container(
                        //     width: screenSize.width,
                        //     color: Colors.grey,
                        //     child: Card(
                        //         color: Colors.orange,
                        //         child: Row(
                        //           children: [
                        //             const SizedBox(
                        //               width: 100,
                        //               child: Text("Player 1"),
                        //             ),
                        //             Container(
                        //               width: 100,
                        //               child: Text("230"),
                        //             ),
                        //             Container(
                        //               width: 100,
                        //               child: Text("12"),
                        //             )
                        //           ],
                        //         )),
                        //   ),
                        //   Card(
                        //       color: Colors.orange,
                        //       child: Row(
                        //         children: [
                        //           Container(
                        //             width: 100,
                        //             child: Text("Player 1"),
                        //           ),
                        //           Container(
                        //             width: 100,
                        //             child: Text("230"),
                        //           ),
                        //           Container(
                        //             width: 100,
                        //             child: Text("12"),
                        //           )
                        //         ],
                        //       )),
                        //   Card(
                        //       color: Colors.orange,
                        //       child: Row(
                        //         children: [
                        //           Container(
                        //             width: 100,
                        //             child: Text("Player 1"),
                        //           ),
                        //           Container(
                        //             width: 100,
                        //             child: Text("230"),
                        //           ),
                        //           Container(
                        //             width: 100,
                        //             child: Text("12"),
                        //           )
                        //         ],
                        //       )),
                        // ],
                        )),
              )
            : gameSelection,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Visibility(
            visible: isGameStarted ?? false,
            child: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  _considerAddingPlayer();
                },
                tooltip: 'Add New',
                child: const IconTheme(
                    data: IconThemeData(
                      size: 40.0,
                      color: Colors.orange,
                    ),
                    child: Icon(Icons.add, color: Colors.green)))));
  }
}
