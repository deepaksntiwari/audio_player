import 'dart:io';
import 'dart:math';
import 'package:audio_recorder/bloc/recorder_and_player_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

import '../widgets/glass_box.dart';
import 'audio_recording.dart';

class AudioRecorderAndPlayer extends StatefulWidget {
  const AudioRecorderAndPlayer({super.key});

  @override
  State<AudioRecorderAndPlayer> createState() => _AudioRecorderAndPlayerState();
}

class _AudioRecorderAndPlayerState extends State<AudioRecorderAndPlayer> {
  late final RecorderController recorderController;
  late PlayerController playerController;

  String audioFilePath = "";
  bool isRecording = false;
  bool isPlaying = false;
  Duration _durationRecorded = Duration();
  Duration _durationPlayed = Duration();
  late RecorderAndPlayerBloc _andPlayerBloc;
  @override
  void initState() {
    super.initState();

    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 48000;
    playerController = PlayerController();
    _andPlayerBloc = BlocProvider.of<RecorderAndPlayerBloc>(context);
    BlocProvider.of<RecorderAndPlayerBloc>(context).add(
        RecoderAndPlayerInitializeEvent(playerController, recorderController));
  }

  _recordListener(duration) {
    setState(() {
      _durationRecorded = duration;
    });
  }

  _playerListener(duration) {
    setState(() {
      _durationPlayed = duration;
    });
  }

  void _resetRecorderAndPlayer() {
    recorderController.reset();
    BlocProvider.of<RecorderAndPlayerBloc>(context)
        .add(RecorderANdPlayerStopEvent());
    setState(() {
      isPlaying = false;
      isRecording = false;
      audioFilePath = "";
      _durationRecorded = Duration.zero;
      _durationPlayed = Duration.zero;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 41, 0, 111).withOpacity(.7)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: BlocConsumer<RecorderAndPlayerBloc, RecorderAndPlayerState>(
              listener: (context, state) {
                if (state is RecorderRecordedAudioDurationState) {
                  _recordListener(state.duration);
                }
                if (state is RecorderRecordingState) {
                  isRecording = true;
                }
                if (state is RecorderRecordingStoppedState) {
                  playerController = PlayerController();
                  audioFilePath = state.audioFilePath;
                  BlocProvider.of<RecorderAndPlayerBloc>(context).add(
                      PlayerInialisedEvent(
                          audioFilePath: audioFilePath,
                          playerController: playerController));
                  isRecording = false;
                }
                if (state is PlayerBlocInitialisedState) {}
                if (state is PlayerPlayState) {
                  isPlaying = true;
                }
                if (state is PlayerAudioPlayedDurationState) {
                  _playerListener(state.duration);
                }
                if (state is PlayerPauseState) {
                  isPlaying = false;
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    Text(
                      "Record Audio",
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                              color: Colors.white70)),
                    ),
                    Spacer(flex: 1),
                    GlassBox(
                        borderRadius: 10,
                        height: 300,
                        width: double.maxFinite,
                        widget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isPlaying || isRecording
                                    ? audioFilePath.isEmpty
                                        ? AudioWaveforms(
                                            enableGesture: true,
                                            size: const Size(
                                                double.maxFinite - 10, 150),
                                            recorderController:
                                                recorderController,
                                            waveStyle: const WaveStyle(
                                              waveColor: Colors.white,
                                              extendWaveform: true,
                                              showMiddleLine: false,
                                            ),
                                          )
                                        : audioFilePath.isNotEmpty
                                            ? Column(
                                                children: [
                                                  AudioFileWaveforms(
                                                    size: const Size(
                                                        double.maxFinite - 10,
                                                        150),
                                                    playerController:
                                                        playerController,
                                                  ),
                                                ],
                                              )
                                            : SizedBox()
                                    : SizedBox(),
                                Text(
                                  audioFilePath.isNotEmpty
                                      ? _durationPlayed.toHHMMSS()
                                      : _durationRecorded.toHHMMSS(),
                                  style: GoogleFonts.roboto(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 50,
                                          color: Colors.white70)),
                                ),
                              ],
                            ),
                          ),
                        )),
                    Spacer(flex: 4),
                    GlassBox(
                        borderRadius: 20,
                        height: 60,
                        width: double.maxFinite,
                        widget: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _resetRecorderAndPlayer();
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white70,
                                  size: 35,
                                ),
                              ),
                              isPlaying == false && audioFilePath.isEmpty
                                  ? GestureDetector(
                                      onTap: () => isRecording == false
                                          ? BlocProvider.of<
                                                      RecorderAndPlayerBloc>(
                                                  context)
                                              .add(RecorderStartRecordingEvent(
                                                  "/data/user/0/com.example.audio_recorder/cache/audioMessage_${DateTime.now().millisecondsSinceEpoch}.acc"))
                                          : BlocProvider.of<
                                                      RecorderAndPlayerBloc>(
                                                  context)
                                              .add(
                                                  RecorderStopRecordingEvent()),
                                      child: isRecording == false
                                          ? const Icon(
                                              Icons.mic,
                                              color: Colors.white70,
                                              size: 50,
                                            )
                                          : const Icon(
                                              Icons.stop_circle,
                                              color: Colors.white70,
                                              size: 50,
                                            ),
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        BlocProvider.of<RecorderAndPlayerBloc>(
                                                context)
                                            .add(PlayerPlayAndPauseEvent());
                                      },
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
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider(
                                          create: (context) =>
                                              RecorderAndPlayerBloc(),
                                          child: FileListScreen(),
                                        ),
                                      ));
                                },

                                // onTap: () => Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => BlocProvider.value(
                                //             value: _andPlayerBloc,
                                //             child: FileListScreen(),
                                //           )),
                                // ),
                                child: const Icon(
                                  Icons.line_weight_sharp,
                                  color: Colors.white70,
                                  size: 35,
                                ),
                              )
                            ],
                          ),
                        ))
                  ],
                );
              },
            ),
          )),
        ),
      ),
    );
  }
}
