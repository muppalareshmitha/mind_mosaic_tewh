// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mind Mosaic Tutorial Video',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: MyVideoPlayer(),
    );
  }
}

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({super.key});

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/tutorial_video.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void _toggleOverlayVisibility() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleOverlayVisibility();
      },
      child: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller),
                      _ControlsOverlay(controller: _controller, isVisible: _isOverlayVisible),
                    ],
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({Key? key, required this.controller, required this.isVisible})
      : super(key: key);

  final VideoPlayerController controller;
  final bool isVisible;

  @override
  __ControlsOverlayState createState() => __ControlsOverlayState();
}

class __ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: widget.isVisible
          ? Container(
              color: Colors.black26,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.controller.value.isPlaying) {
                            widget.controller.pause();
                          } else {
                            widget.controller.play();
                          }
                        },
                        icon: Icon(
                          widget.controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                      Expanded(
                        child: VideoProgressIndicator(
                          widget.controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.amber,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.black,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          widget.controller.seekTo(
                            Duration(seconds: widget.controller.value.position.inSeconds - 5),
                          );
                        },
                        icon: Icon(
                          Icons.replay_5,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Container(),
    );
  }
}