part of 'recorder_and_player_bloc.dart';

abstract class RecorderAndPlayerState {}

final class RecorderAndPlayerInitial extends RecorderAndPlayerState {}

final class RecorderBlocInitial extends RecorderAndPlayerState {}

class RecorderRecordingState extends RecorderAndPlayerState {
  Duration duration;
  RecorderRecordingState(this.duration);
}

class RecorderPausedState extends RecorderAndPlayerState {}

class RecorderRecordingStoppedState extends RecorderAndPlayerState {
  String audioFilePath;
  RecorderRecordingStoppedState(this.audioFilePath);
}

class RecorderRecordedAudioDurationState extends RecorderAndPlayerState {
  Duration duration;
  RecorderRecordedAudioDurationState(this.duration);
}

final class PlayerBlocInitial extends RecorderAndPlayerState {}

class PlayerBlocInitialisedState extends RecorderAndPlayerState {}

class PlayerPlayState extends RecorderAndPlayerState {}

class PlayerPauseState extends RecorderAndPlayerState {}

class PlayerAudioPlayedDurationState extends RecorderAndPlayerState {
  Duration duration;

  PlayerAudioPlayedDurationState(this.duration);
}

class RecorderAndPlayerStopState extends RecorderAndPlayerState {}
