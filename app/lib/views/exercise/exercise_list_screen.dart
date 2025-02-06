import 'package:app/models/exercise_model.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ExerciseListScreen extends StatelessWidget {
  final String filterType;
  ExerciseListScreen({super.key, required this.filterType});
  final List<Exercise> exercises = [
    // Bung
    Exercise(
        calories: 0.056, // Calories per second for 'Plank cơ bản'
        name: 'Plank cơ bản',
        description:
            'Nằm sấp, chống hai khuỷu tay xuống sàn, giữ cơ thể thẳng hàng.',
        duration: 30,
        imageUrl: 'assets/planking.gif',
        youtubeUrl: 'https://www.youtube.com/watch?v=pvIjsG5Svck',
        types: ['Abs1', 'Abs2', 'Abs3']),
    Exercise(
        calories: 0.050, // Calories per second for 'Plank nghiêng'
        name: 'Plank nghiêng',
        description:
            'Nằm nghiêng, duỗi thẳng chân, chống khuỷu tay nâng cơ thể.',
        duration: 30,
        imageUrl: 'assets/side-plank.gif',
        youtubeUrl: 'https://youtu.be/N_s9em1xTqU?si=ui4BWWuYOUgeEHej',
        types: ['Abs1']),
    Exercise(
        calories: 0.058, // Calories per second for 'Đạp xe trên không'
        name: 'Đạp xe trên không',
        description: 'Nằm ngửa, hai tay chạm đầu, đạp chân như đạp xe.',
        duration: 30,
        imageUrl: 'assets/airbike.gif',
        youtubeUrl: 'https://youtu.be/i6mPCVUrtNk?si=CqVUSUvc5y1JzFvi',
        types: ['Abs1']),
    Exercise(
        calories: 0.017, // Calories per second for 'Cá chết'
        name: 'Dead Fish',
        description: 'Nằm sấp, thả lỏng toàn bộ cơ thể, thư giãn cơ bụng.',
        duration: 30,
        imageUrl: 'assets/dead_fish.gif',
        youtubeUrl: 'https://youtu.be/hXUE5s8R-Oc?si=yQS7DuzPLS9sslce',
        types: ['Abs1']),
    Exercise(
        calories: 0.053, // Calories per second for 'Crunch cơ bản'
        name: 'Crunch cơ bản',
        description: 'Nằm ngửa, co đầu gối, nâng vai khỏi sàn.',
        duration: 30,
        imageUrl: 'assets/crunch.gif',
        youtubeUrl: 'https://youtu.be/MKmrqcoCZ-M?si=IGegHB1rpQN1u5Co',
        types: ['Abs2']),
    Exercise(
        calories: 0.057, // Calories per second for 'Nâng chân'
        name: 'Nâng chân',
        description: 'Nằm ngửa, nâng chân thẳng lên, giữ trong vài giây.',
        duration: 30,
        imageUrl: 'assets/leg_raise.gif',
        youtubeUrl: 'https://youtu.be/l4kQd9eWclE?si=pqUX8dlIEwG8vgHp',
        types: ['Abs2']),
    Exercise(
        calories: 0.055, // Calories per second for 'Crunch kéo kéo'
        name: 'Crunch kéo kéo',
        description: 'Nằm ngửa, co đầu gối, nâng chân xen kẽ.',
        duration: 30,
        imageUrl: 'assets/crunch_scissor.gif',
        youtubeUrl: 'https://youtu.be/WoNCIBVLbgY?si=OAzdtRflOH3E0aYo',
        types: ['Abs3']),
    Exercise(
        calories: 0.063, // Calories per second for 'Thuyền sức mạnh'
        name: 'Thuyền sức mạnh',
        description:
            'Nằm ngửa, nâng chân và tay lên tạo thành hình chiếc thuyền.',
        duration: 30,
        imageUrl: 'assets/power_boat.gif',
        youtubeUrl: 'https://youtu.be/iKWF7InnzOg?si=jyQZdfg-sJVGjY8M',
        types: ['Abs3']),
    Exercise(
        calories: 0.062, // Calories per second for 'Đạp xe nâng cao'
        name: 'Đạp xe nâng cao',
        description: 'Nằm ngửa, nâng vai và đạp chân mạnh mẽ hơn.',
        duration: 30,
        imageUrl: 'assets/raise_bike.gif',
        youtubeUrl: 'https://youtu.be/wnuLak2onoA?si=Px3IirnPGUrpRv2A',
        types: ['Abs3']),
    Exercise(
        calories: 0.053, // Calories per second for 'Kéo đầu gối nằm sấp'
        name: 'Kéo đầu gối nằm sấp',
        description: 'Nằm sấp, kéo đầu gối về phía ngực và duỗi ra.',
        duration: 30,
        imageUrl: 'assets/prone_knee.gif',
        youtubeUrl: 'https://youtu.be/4X60w2JZMO4?si=f7cSTrXsN3Ty8K4B',
        types: ['Abs3']),
    Exercise(
        calories: 0.066, // Calories per second for 'Hít đất cơ bản'
        name: 'Hít đất cơ bản',
        description:
            'Bài tập hít đất cơ bản, nằm sấp, chống tay, nâng hạ cơ thể bằng sức mạnh tay.',
        duration: 30,
        imageUrl: 'assets/pushup_1.gif',
        youtubeUrl: 'https://youtu.be/WcHtt6zT3Go?si=-eVR5eB4Iroy4eiR',
        types: ['Chest1', 'Chest2', 'Chest3']),
    Exercise(
        calories: 0.073, // Calories per second for 'Hít đất chéo'
        name: 'Hít đất chéo',
        description:
            'Đặt chân cao hơn tay, thực hiện động tác hít đất nâng cao, giúp phát triển cơ ngực và tay.',
        duration: 30,
        imageUrl: 'assets/pushup_2.gif',
        youtubeUrl: 'https://youtu.be/QBlYp-EwHlo?si=pCZnMe7tH2r94fzb',
        types: ['Chest1', 'Chest2']),
    Exercise(
        calories: 0.056, // Calories per second for 'Plank với tạ tay'
        name: 'Plank với tạ tay',
        description:
            'Giữ tư thế plank trong khi cầm tạ tay và nâng chúng lên xuống, kết hợp sức mạnh tay và cơ bụng.',
        duration: 30,
        imageUrl: 'assets/dumbbell_press.gif',
        youtubeUrl: 'https://youtu.be/YQ2s_Y7g5Qk?si=6XU-LivsO7jQ6pJq',
        types: ['Chest2', 'Chest3']),
    Exercise(
        calories: 0.056, // Calories per second for 'Plank với tạ bay'
        name: 'Plank với tạ bay',
        description:
            'Giữ tư thế plank và thực hiện động tác tạ bay, phát triển cơ ngực và vai.',
        duration: 30,
        imageUrl: 'assets/deck_fly.gif',
        youtubeUrl: 'https://youtu.be/eGjt4lk6g34?si=_OjxB4SopctKJzSx',
        types: ['Chest2', 'Chest3']),
    Exercise(
        calories: 0.056, // Calories per second for 'Plank với tạ kéo qua đầu'
        name: 'Plank với tạ kéo qua đầu',
        description:
            'Giữ tư thế plank trong khi kéo tạ qua đầu, giúp phát triển cơ ngực và vai.',
        duration: 30,
        imageUrl: 'assets/pull_over.gif',
        youtubeUrl: 'https://youtu.be/Mcrh83gJac8?si=V35VWJumr9amp9oP',
        types: ['Chest3']),
    Exercise(
        calories:
            0.056, // Calories per second for 'Plank với thanh tạ đẩy ngực'
        name: 'Plank với thanh tạ đẩy ngực',
        description:
            'Giữ tư thế plank và thực hiện động tác đẩy ngực với thanh tạ, giúp phát triển cơ ngực và tay.',
        duration: 30,
        imageUrl: 'assets/barbell_bench.gif',
        youtubeUrl: 'https://youtu.be/gRVjAtPip0Y?si=FWYWcXsx9fGPjCU9',
        types: ['Chest3']),
    Exercise(
        calories: 0.056, // Calories per second for 'Plank với cáp tay'
        name: 'Plank với cáp tay',
        description:
            'Giữ tư thế plank và thực hiện động tác kéo cáp tay, giúp phát triển cơ ngực và vai.',
        duration: 30,
        imageUrl: 'assets/cable_fly.gif',
        youtubeUrl: 'https://youtu.be/hhruLxo9yZU?si=mQXCDxxvE3muTmwV',
        types: ['Chest2']),

    //Tay
    Exercise(
        calories: 1.67, // Calories per second for 'DBCurl.gif'
        name: 'Curl với tạ đòn',
        description:
            'Nằm nghiêng, tay cầm tạ đòn, thực hiện động tác curl để phát triển cơ bắp tay.',
        duration: 30,
        imageUrl: 'assets/DBCurl.gif',
        youtubeUrl: 'https://youtu.be/ykJmrZ5v0Oo?si=rC7jdkR4KPNPx8O7',
        types: ['Arm1', 'Arm2']),
    Exercise(
        calories: 1.80, // Calories per second for 'diamond_push.gif'
        name: 'Hít đất kim cương',
        description:
            'Thực hiện động tác hít đất với tay đặt gần nhau theo hình kim cương, giúp phát triển cơ tay sau và ngực.',
        duration: 30,
        imageUrl: 'assets/diamond_push.gif',
        youtubeUrl: 'https://youtu.be/XtU2VQVuLYs?si=awJdSEQxipy0MIPG',
        types: ['Arm2', 'Arm3']),
    Exercise(
        calories: 1.75, // Calories per second for 'hammercurl.gif'
        name: 'Curl với tạ tay kiểu búa',
        description:
            'Nằm nghiêng, tay cầm tạ tay, thực hiện động tác curl kiểu búa, giúp phát triển cơ tay trước.',
        duration: 30,
        imageUrl: 'assets/hammercurl.gif',
        youtubeUrl: 'https://youtu.be/CFBZ4jN1CMI?si=fYV8RyAiP--hMtzL',
        types: ['Arm1', 'Arm2']),
    Exercise(
        calories: 1.70, // Calories per second for 'seatcurl.gif'
        name: 'Curl ngồi với tạ',
        description:
            'Ngồi trên ghế, tay cầm tạ, thực hiện động tác curl để phát triển cơ tay.',
        duration: 30,
        imageUrl: 'assets/seatcurl.gif',
        youtubeUrl: 'https://youtu.be/BsULGO70tcU?si=5UdtfSEhQf6P87Lr',
        types: ['Arm1', 'Arm2']),
    Exercise(
        calories: 2.00, // Calories per second for 'benchdip.gif'
        name: 'Dip trên ghế',
        description:
            'Ngồi trên ghế, hai tay đặt lên ghế phía sau và thực hiện động tác dip, giúp phát triển cơ tay sau.',
        duration: 30,
        imageUrl: 'assets/benchdip.gif',
        youtubeUrl: 'https://youtu.be/XXvuYGCxpkk?si=ME8OEmrhPdMejGU9',
        types: ['Arm3']),

    Exercise(
        calories: 2.10, // Calories per second for 'tricep_rope_pulldown.gif'
        name: 'Kéo cáp tay sau',
        description:
            'Sử dụng dây cáp để thực hiện động tác kéo xuống, giúp phát triển cơ tay sau.',
        duration: 30,
        imageUrl: 'assets/tricep_rope_pulldown.gif',
        youtubeUrl: 'https://youtu.be/-xa-6cQaZKY?si=5WOgVxU87DtBBNTe',
        types: ['Arm2']),

    Exercise(
        calories: 1.80, // Calories per second for 'cable_curl.gif'
        name: 'Curl cáp',
        description:
            'Sử dụng dây cáp để thực hiện động tác curl, giúp phát triển cơ tay.',
        duration: 30,
        imageUrl: 'assets/cable_curl.gif',
        youtubeUrl: 'https://youtu.be/UsaY33N4KEw?si=IoaAsZEWJdqriza0e',
        types: ['Arm1', 'Arm3']),

    //Chan

    Exercise(
        calories: 1.75, // Calories per second for 'kickback.gif'
        name: 'Kickback',
        description:
            'Nằm nghiêng, chân duỗi thẳng, thực hiện động tác kickback để phát triển cơ mông.',
        duration: 30,
        imageUrl: 'assets/kickback.gif',
        youtubeUrl: 'https://youtu.be/SqO-VUEak2M?si=FS0kC49YYot2MYB-',
        types: ['Leg1']),
    Exercise(
        calories: 1.80, // Calories per second for 'bd_squat.gif'
        name: 'Bodyweight Squat',
        description: 'Thực hiện động tác squat với trọng lượng cơ thể.',
        duration: 30,
        imageUrl: 'assets/bd_squat.gif',
        youtubeUrl: 'https://youtu.be/m0GcZ24pK6k?si=bAfPrPwHzLL8i3IV',
        types: ['Leg1']),
    Exercise(
        calories: 1.70, // Calories per second for 'calf_band.gif'
        name: 'Calf Band',
        description: 'Sử dụng dây band để thực hiện động tác nâng bắp chân.',
        duration: 30,
        imageUrl: 'assets/calf_band.gif',
        youtubeUrl: 'https://youtu.be/c7WznjdHFFI?si=rvgluVy3EydfpXIO',
        types: ['Leg1']),
    Exercise(
        calories: 2.00, // Calories per second for 'lunge.gif'
        name: 'Lunge',
        description: 'Thực hiện động tác lunge để phát triển cơ đùi và mông.',
        duration: 30,
        imageUrl: 'assets/lunge.gif',
        youtubeUrl: 'https://youtu.be/tTej-ax9XiA?si=Rw3B_t5mtPWouDKQ',
        types: ['Leg2']),
    Exercise(
        calories: 2.10, // Calories per second for 'split_squat.gif'
        name: 'Split Squat',
        description: 'Thực hiện động tác split squat để phát triển cơ chân.',
        duration: 30,
        imageUrl: 'assets/split_squat.gif',
        youtubeUrl: 'https://youtu.be/hXpGSa5HYqY?si=dI83bIFWsjl4baaV',
        types: ['Leg2']),
    Exercise(
        calories: 2.00, // Calories per second for 'adductor.gif'
        name: 'Adductor',
        description: 'Thực hiện động tác adductor để phát triển cơ đùi trong.',
        duration: 30,
        imageUrl: 'assets/adductor.gif',
        youtubeUrl: 'https://youtu.be/V7YHfRT2PLE?si=Dx2zuF-mck64OKIu',
        types: ['Leg2']),

    Exercise(
        calories: 2.20, // Calories per second for 'sumo.gif'
        name: 'Sumo Squat',
        description:
            'Thực hiện động tác sumo squat để phát triển cơ đùi trong và mông.',
        duration: 30,
        imageUrl: 'assets/sumo.gif',
        youtubeUrl: 'https://youtu.be/vBA3vyOxJv0?si=Q0MWHidPu1Aj13ya',
        types: ['Leg2']),
    Exercise(
        calories: 2.50, // Calories per second for 'kneeling.gif'
        name: 'Kneeling Leg Press',
        description:
            'Thực hiện động tác leg press khi quỳ gối, phát triển cơ đùi.',
        duration: 30,
        imageUrl: 'assets/kneeling.gif',
        youtubeUrl: 'https://youtu.be/dUgr_vjDWNw?si=sFShtjVDRBPf9bBA',
        types: ['Leg3']),

    Exercise(
        calories: 2.70, // Calories per second for 'leg_press.gif'
        name: 'Leg Press',
        description:
            'Sử dụng máy leg press để thực hiện động tác leg press, phát triển cơ đùi và mông.',
        duration: 30,
        imageUrl: 'assets/leg_press.gif',
        youtubeUrl: 'https://youtu.be/uEsZWWiYNAQ?si=451lNM3JVQxnN_Rd',
        types: ['Leg3']),
    Exercise(
        calories: 1.80, // Calories per second for 'calf_raise.gif'
        name: 'Calf Raise',
        description:
            'Thực hiện động tác nâng bắp chân để phát triển cơ bắp chân.',
        duration: 30,
        imageUrl: 'assets/calf_raise.gif',
        youtubeUrl: 'https://youtu.be/c5Kv6-fnTj8?si=Y8QmkQAj_HREUiUR',
        types: ['Leg3']),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredExercises = exercises
        .where((exercise) => exercise.types.contains(filterType))
        .toList();
    return Scaffold(
      appBar: CustomAppBar(title: "Exercise List"),
      body: ListView.builder(
        itemCount: filteredExercises.length,
        itemBuilder: (context, index) {
          final exercise = filteredExercises[index];
          return ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.blueAccent),
            title: Text(exercise.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(exercise.description),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Màu chữ của nút
                shape: RoundedRectangleBorder(
                  // Tùy chỉnh viền nút
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12), // Padding của nút
              ),
              child: const Text(
                'Bắt đầu',
                style: TextStyle(fontSize: 14),
              ),
              onPressed: () {
                
              },
            ),
          );
        },
      ),
    );
  }
}