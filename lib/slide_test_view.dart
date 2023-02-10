import 'package:flutter/material.dart';

import 'slide_view/slide_view.dart';

class MySliderApp extends StatelessWidget {
  const MySliderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const SlideTestView(),
    );
  }
}

class SlideTestView extends StatefulWidget {
  const SlideTestView({super.key});

  @override
  State<SlideTestView> createState() => _SlideTestViewState();
}

class _SlideTestViewState extends State<SlideTestView> {
  final controller = SlideController();

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(index.toString()),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                index = controller.index;
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _builtSlides(),
    );
  }

  Widget _builtSlides() {
    return SlideView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        return Container(
          width: 300,
          height: 300,
          color: Colors.amber,
          child: Center(child: Text('${(index + 1).toString()}/3')),
        );
      },
      itemCount: 3,
      indexBuilder: (context, index, length) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Text('${index + 1}/$length'),
        );
      },
    );
  }

  Widget _fixedSlides() {
    return SlideView(
      controller: controller,
      children: const [
        Center(
          child: Text('first'),
        ),
        Center(
          child: Text('second'),
        ),
        Center(
          child: Text('third'),
        ),
        Center(
          child: Text('fourth'),
        ),
      ],
      indexBuilder: (context, index, length) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Text('${index + 1}/$length'),
        );
      },
    );
  }
}
