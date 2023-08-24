import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../services/toast_service.dart';

part 'recorder_and_player_event.dart';
part 'recorder_and_player_state.dart';

class RecorderAndPlayerBloc
    extends Bloc<RecorderAndPlayerEvent, RecorderAndPlayerState> {
  int durationElapsed = 0;
  late RecorderController recorderController;

  late PlayerController playerController;
  RecorderAndPlayerBloc() : super(RecorderAndPlayerInitial()) {
    on<RecoderAndPlayerInitializeEvent>((event, emit) async {
      showToast("Controllers initialized...");
      recorderController = event.recorderController;
      //playerController = event.playerController;
      recorderController.onCurrentDuration.listen((event) {
        print("\n\nRecord Listener...\n\n");
        add(RecorderRecordedAudioDurationEvent(event));
      });
    });

    on<RecorderStartRecordingEvent>((event, emit) async {
      showToast("Recording started...");

      emit(RecorderRecordingState(Duration.zero));
      await recorderController.record(path: event.audioFilePath);
    });

    on<RecorderStopRecordingEvent>((event, emit) async {
      String value = await recorderController.stop() ?? "";
      //   PlayerBlocBloc().add(PlayerInialisedEvent(audioFilePath: ));
      emit(RecorderRecordingStoppedState(value));
      showToast("Recording Stopped...");
    });

    on<RecorderRecordedAudioDurationEvent>((event, emit) {
      emit(RecorderRecordedAudioDurationState(event.duration));
    });

    on<PlayerInialisedEvent>((event, emit) async {
      showToast("Preparing player...");
      playerController = event.playerController;
      await playerController.preparePlayer(
        path: event.audioFilePath,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 1.0,
      );
      playerController.onCurrentDurationChanged.listen((event) {
        print("\n\nPlayer Listener...\n\n");
        durationElapsed = event;
        add(PlayerDurationPassedEvent(Duration(milliseconds: event)));
      });
      emit(PlayerBlocInitialisedState());
    });

    on<PlayerPlayAndPauseEvent>((event, emit) async {
      if (playerController.playerState == PlayerState.playing) {
        await playerController.pausePlayer();
        showToast("Audio Paused...");
        emit(PlayerPauseState());
      } else if (playerController.playerState == PlayerState.paused ||
          playerController.playerState == PlayerState.initialized) {
        await playerController.startPlayer(finishMode: FinishMode.pause);
        showToast("Audio Played...");
        emit(PlayerPlayState());
      }
    });

    on<PlayerDurationPassedEvent>((event, emit) {
      emit(PlayerAudioPlayedDurationState(event.duration));
    });

    on<PlayerFastForwardEvent>((event, emit) {
      showToast("5+");
      if (playerController.playerState == PlayerState.playing) {
        playerController.seekTo(durationElapsed + 5000);
      }
      emit(PlayerAudioPlayedDurationState(
          Duration(milliseconds: durationElapsed)));
    });
    on<PlayerFastRewindEvent>((event, emit) {
      showToast("5-");
      playerController.seekTo(durationElapsed - 5000);
      emit(PlayerAudioPlayedDurationState(
          Duration(milliseconds: durationElapsed)));
    });
    on<RecorderANdPlayerStopEvent>((event, emit) {
      recorderController.reset();
      playerController.dispose();

      showToast("Recorder and Player Stopped");
      emit(RecorderAndPlayerStopState());
    });
  }

  @override
  Future<void> close() {
    showToast("Bloc closed...");
    recorderController.dispose();
    // playerController.dispose();

    return super.close();
  }
}
