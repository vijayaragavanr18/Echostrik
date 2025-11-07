import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioService extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        if (kIsWeb) {
          // For web, use a simple filename without path_provider
          _currentRecordingPath = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          _currentRecordingPath = '${directory.path}/$fileName';
        }

        await _recorder.start(
          const RecordConfig(),
          path: _currentRecordingPath!,
        );

        _isRecording = true;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Recording failed: $e');
      }
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      notifyListeners();
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Stop recording failed: $e');
      }
      return null;
    }
  }

  Future<void> playRecording(String path) async {
    try {
      // Check if it's a local file path or URL
      if (path.startsWith('/')) {
        // Local file path
        await _player.setFilePath(path);
      } else {
        // Firebase Storage URL (if we switch back later)
        await _player.setUrl(path);
      }
      await _player.play();
      _isPlaying = true;
      notifyListeners();

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          notifyListeners();
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Playback failed: $e');
      }
    }
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }
}
