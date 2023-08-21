part of 'recorder_and_player_bloc.dart';

abstract class RecorderAndPlayerEvent {}

class RecoderAndPlayerInitializeEvent extends RecorderAndPlayerEvent {
  RecorderController recorderController;
  PlayerController playerController;

  RecoderAndPlayerInitializeEvent(
      this.playerController, this.recorderController);
}

class RecorderStartRecordingEvent extends RecorderAndPlayerEvent {
  String audioFilePath;
  RecorderStartRecordingEvent(this.audioFilePath);
}

class RecorderStopRecordingEvent extends RecorderAndPlayerEvent {}

// class RecorderStopRecorderEvent extends RecorderBlocEvent {}

class RecorderRecordedAudioDurationEvent extends RecorderAndPlayerEvent {
  Duration duration;
  RecorderRecordedAudioDurationEvent(this.duration);
}

class PlayerInialisedEvent extends RecorderAndPlayerEvent {
  String audioFilePath;
  PlayerController playerController;
  PlayerInialisedEvent(
      {required this.audioFilePath, required this.playerController});
}

class PlayerPlayAndPauseEvent extends RecorderAndPlayerEvent {}

class PlayerDurationPassedEvent extends RecorderAndPlayerEvent {
  Duration duration;
  PlayerDurationPassedEvent(this.duration);
}

class RecorderANdPlayerStopEvent extends RecorderAndPlayerEvent {}

class PlayerFastForwardEvent extends RecorderAndPlayerEvent {}

class PlayerFastRewindEvent extends RecorderAndPlayerEvent {}