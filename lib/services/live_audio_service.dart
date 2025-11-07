import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveAudioService extends ChangeNotifier {
  RtcEngine? _engine;
  bool _joined = false;
  int? _remoteUid;
  bool _muted = false;

  bool get joined => _joined;
  int? get remoteUid => _remoteUid;
  bool get muted => _muted;

  Future<void> initializeAgora() async {
    // Request microphone permission
    await [Permission.microphone].request();

    // Create RtcEngine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: 'your_agora_app_id', // TODO: Add your Agora App ID
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Local user ${connection.localUid} joined');
          _joined = true;
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('Remote user $remoteUid joined');
          _remoteUid = remoteUid;
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint('Remote user $remoteUid left channel');
          _remoteUid = null;
          notifyListeners();
        },
      ),
    );

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudio();
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileMusicHighQuality,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
  }

  Future<void> joinChannel(String token, String channelId, int uid) async {
    if (_engine == null) return;

    await _engine!.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;

    await _engine!.leaveChannel();
    _joined = false;
    _remoteUid = null;
    notifyListeners();
  }

  Future<void> toggleMute() async {
    if (_engine == null) return;

    _muted = !_muted;
    await _engine!.muteLocalAudioStream(_muted);
    notifyListeners();
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}
