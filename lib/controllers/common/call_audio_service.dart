import 'package:audioplayers/audioplayers.dart';
import 'package:biphip_messenger/utils/constants/imports.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Play caller tune or ringtone
  Future<void> playAudio(String audioPath, {bool isSpeaker = false}) async {
    await _audioPlayer.stop(); // Stop any existing playback
    await _audioPlayer.setSource(AssetSource(audioPath));
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.setPlaybackRate(1.0);
    await Helper.setSpeakerphoneOn(isSpeaker);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(audioPath));
  }

  // Stop audio playback
  Future<void> stopAudio() async {
    ll("Audio Stopped");
    await _audioPlayer.stop();
  }

  // Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}