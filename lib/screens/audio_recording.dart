import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

import '../bloc/recorder_and_player_bloc.dart';
import '../services/toast_service.dart';
import '../widgets/glass_box.dart';

class FileListScreen extends StatefulWidget {
  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  List<String> fileNames = [];
  String _durationPlayed = "00.00.00";
  bool isPlaying = false;
  int maxDuration = 0;
  late RecorderAndPlayerBloc _andPlayerBloc;

  @override
  void initState() {
    super.initState();
    _loadFiles();
    _andPlayerBloc = BlocProvider.of<RecorderAndPlayerBloc>(context);

    RecorderController _recorderController = RecorderController();
    BlocProvider.of<RecorderAndPlayerBloc>(context).add(
        RecoderAndPlayerInitializeEvent(
            PlayerController(), _recorderController));
    // playerController.onCurrentDurationChanged.listen((duration) {
    //   _playerListener(duration);
    // });
  }

  // _playerListener(duration) {
  //   setState(() {
  //     _durationPlayed = Duration(milliseconds: duration).toHHMMSS();
  //   });
  // }

  // void _playandPause() async {
  //   if (playerController.playerState == PlayerState.playing) {
  //     await playerController.pausePlayer();
  //     showToast("Audio Paused...");
  //     setState(() {
  //       isPlaying = false;
  //     });
  //   } else {
  //     await playerController.startPlayer(finishMode: FinishMode.loop);
  //     showToast("Audio Played...");
  //     setState(() {
  //       isPlaying = true;
  //     });
  //   }
  // }

  Future<List<String>> listFilesInDirectory() async {
    try {
      Directory directory =
          Directory("/data/user/0/com.deepak.audio_recorder/cache/");
      List<FileSystemEntity> files = directory.listSync();
      List<String> fileNames = [];

      for (var file in files) {
        if (file is File) {
          fileNames.add(file.path);
          developer.log(file.path);
        }
      }

      return fileNames;
    } catch (e) {
      print("Error listing files: $e");
      return [];
    }
  }

  Future<void> _loadFiles() async {
    String directoryPath = (await getApplicationDocumentsDirectory()).path;
    List<String> files = await listFilesInDirectory();
    setState(() {
      fileNames = files;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecorderAndPlayerBloc(),
      child: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 41, 0, 111).withOpacity(.7)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              centerTitle: true,
              iconTheme: const IconThemeData(
                size: 35,
                color: Colors.white,
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              title: Text(
                "Audio Recordings",
                style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        color: Colors.white70)),
              )),
          body: ListView.builder(
            itemCount: fileNames.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    var playerController = PlayerController();
                    _andPlayerBloc.add(PlayerInialisedEvent(
                        audioFilePath: fileNames[index],
                        playerController: playerController));
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       fullscreenDialog: true,
                    //       builder: (context) => BlocProvider.value(
                    //             value: _andPlayerBloc,
                    //             child: AudioPlayerWidget(
                    //                 playerController: playerController),
                    //           )),
                    // );

                    // OverlayEntry overlayEntry = OverlayEntry(
                    //     builder: (context) => BlocProvider.value(
                    //           value: _andPlayerBloc,
                    //           child: AudioPlayerWidget(
                    //               playerController: playerController),
                    //         ));
                    // Overlay.of(context)?.insert(overlayEntry);

                    Navigator.of(context)
                        .push(
                      OverlayPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: _andPlayerBloc,
                          child: AudioPlayerWidget(
                              playerController: playerController),
                        ),
                      ),
                    )
                        .then(
                      (value) {
                        playerController.dispose();
                      },
                    );
                  },
                  child: GlassBox(
                    borderRadius: 10,
                    height: 80,
                    width: double.maxFinite - 10,
                    widget: ListTile(
                      title: Text(
                        fileNames[index].split("/").last,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "\nDuration:- ${Duration(milliseconds: maxDuration).toHHMMSS()}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({
    super.key,
    required this.playerController,
  });

  final PlayerController playerController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 41, 0, 111).withOpacity(.7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: GlassBox(
            borderRadius: 30,
            height: 320,
            width: double.maxFinite,
            widget: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  AudioFileWaveforms(
                    size: const Size(double.maxFinite - 10, 150),
                    playerController: playerController,
                  ),
                  BlocBuilder<RecorderAndPlayerBloc, RecorderAndPlayerState>(
                    builder: (context, state) {
                      if (state is PlayerAudioPlayedDurationState) {
                        return Text(
                          state.duration.toHHMMSS(),
                          style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                  color: Colors.white70)),
                        );
                      }
                      return Text(
                        Duration.zero.toHHMMSS(),
                        style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 50,
                                color: Colors.white70)),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            BlocProvider.of<RecorderAndPlayerBloc>(context)
                                .add(PlayerFastRewindEvent()),
                        child: Icon(
                          Icons.fast_rewind,
                          color: Colors.white70,
                          size: 50,
                        ),
                      ),
                      IconButton(
                          onPressed: () =>
                              BlocProvider.of<RecorderAndPlayerBloc>(context)
                                  .add(PlayerPlayAndPauseEvent()),
                          icon: playerController.playerState ==
                                  PlayerState.playing
                              ? Icon(
                                  Icons.play_arrow,
                                  color: Colors.white70,
                                  size: 50,
                                )
                              : Icon(
                                  Icons.pause,
                                  color: Colors.white70,
                                  size: 50,
                                )),
                      GestureDetector(
                        onTap: () =>
                            BlocProvider.of<RecorderAndPlayerBloc>(context)
                                .add(PlayerFastForwardEvent()),
                        child: Icon(
                          Icons.fast_forward,
                          color: Colors.white70,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OverlayPageRoute extends PageRoute<void> {
  OverlayPageRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return GestureDetector(
      onTap: () {
        // Dismiss the overlay when tapped
        Navigator.of(context).pop();
      },
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: Align(alignment: Alignment.bottomCenter, child: child),
    );
  }
}
