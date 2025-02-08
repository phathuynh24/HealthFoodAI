import 'package:app/models/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void showExerciseDetailBottomSheet(BuildContext context, Exercise exercise) {
  int selectedOption = 0;
  int updatedTime = exercise.duration;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Handle the draggable handle
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Content container based on selection
                    Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectedOption == 0
                            ? Center(
                                child: Image.asset(
                                  exercise.imageUrl, // First image URL
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Unable to load image 1');
                                  },
                                ),
                              )
                            : Center(
                                child: YoutubePlayer(
                                  controller: YoutubePlayerController(
                                    initialVideoId:
                                        YoutubePlayer.convertUrlToId(
                                            exercise.youtubeUrl)!,
                                    flags: const YoutubePlayerFlags(
                                      autoPlay: false,
                                      mute: false,
                                    ),
                                  ),
                                  showVideoProgressIndicator: true,
                                ),
                              )),
                    // Toggle buttons for options
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ToggleButtons(
                        isSelected: [
                          selectedOption == 0,
                          selectedOption == 1,
                        ],
                        onPressed: (int index) {
                          setState(() {
                            selectedOption = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        fillColor: Colors.blue,
                        selectedColor: Colors.white,
                        color: Colors.grey,
                        textStyle: const TextStyle(fontSize: 16),
                        constraints: BoxConstraints(
                          minWidth:
                              (MediaQuery.of(context).size.width - 64) / 3,
                          minHeight: 40,
                        ),
                        children: const [
                          Text('Hình ảnh'),
                          Text('Video'),
                        ],
                      ),
                    ),
                    // Duration adjustment section
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       const Text(
                    //         'THỜI GIAN',
                    //         style: TextStyle(
                    //             fontSize: 20,
                    //             color: Colors.blue,
                    //             fontWeight: FontWeight.bold),
                    //       ),
                    //       Row(
                    //         children: [
                    //           IconButton(
                    //             icon: const Icon(Icons.remove),
                    //             onPressed: () {
                    //               setState(() {
                    //                 if (updatedTime > 10) {
                    //                   updatedTime -= 10; // Giảm 10 giây
                    //                 }
                    //               });
                    //             },
                    //           ),
                    //           Text(
                    //             '${(updatedTime ~/ 60).toString().padLeft(2, '0')}:${(updatedTime % 60).toString().padLeft(2, '0')}',
                    //             style: const TextStyle(fontSize: 16),
                    //           ),
                    //           IconButton(
                    //             icon: const Icon(Icons.add),
                    //             onPressed: () {
                    //               setState(() {
                    //                 updatedTime += 10; // Tăng 10 giây
                    //               });
                    //             },
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Exercise description
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MÔ TẢ',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            exercise.description, // Exercise description
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'ĐÓNG',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}