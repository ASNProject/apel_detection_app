// Copyright 2024 ariefsetyonugroho
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:io';

import 'package:apel_detection_app/widgets/info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ModelObjectDetection _objectModel;
  // ignore: unused_field
  String? _imagePrediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  bool firststate = false;
  bool message = true;
  List<ResultObjectDetection?> filteredObjDetect = [];
  int numberOfPersonsDetected = 0;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/models/yolov5s.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          pathObjectDetectionModel, 80, 640, 640,
          labelPath: "assets/labels/labels.txt");
    } catch (e) {
      if (e is PlatformException) {}
    }
  }

  void handleTimeout() {
    setState(() {
      firststate = true;
    });
  }

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
  Future runObjectDetection() async {
    setState(() {
      firststate = false;
      message = false;
    });

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      objDetect = await _objectModel.getImagePrediction(
          await File(image.path).readAsBytes(),
          minimumScore: 0.1,
          IOUThershold: 0.3);

      filteredObjDetect =
          objDetect.where((obj) => obj?.className == 'peserta').toList();

      numberOfPersonsDetected = filteredObjDetect.length;

      // ignore: avoid_function_literals_in_foreach_calls
      filteredObjDetect.forEach((element) {
        // ignore: avoid_print
        print({
          "score": element?.score,
          "className": element?.className,
          "class": element?.classIndex,
          "rect": {
            "left": element?.rect.left,
            "top": element?.rect.top,
            "width": element?.rect.width,
            "height": element?.rect.height,
            "right": element?.rect.right,
            "bottom": element?.rect.bottom,
          },
        });
      });

      scheduleTimeout(5 * 1000);
      setState(() {
        _image = File(image.path);
      });
    } else {
      setState(() {
        message = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(32.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'Akademi Angkatan Udara',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  'Realtime Apel Taruna',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Gap(4),
                Text(
                  'Deteksi jumlah peserta apel Taruna AAU secara realtime menggunakan metode YOLO',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const Gap(16),
            Expanded(
              child: Stack(
                children: [
                  !firststate
                      ? !message
                          ? const Center(child: CircularProgressIndicator())
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/37294.jpg',
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: BoxFit.cover,
                              ),
                            )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: _objectModel.renderBoxesOnImage(
                              _image!, filteredObjDetect)),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InfoWidget(
                                filteredObjDetect: filteredObjDetect,
                                numberOfObjectDetection:
                                    numberOfPersonsDetected,
                              ),
                            );
                          },
                        );
                      },
                      child: const Icon(
                        Icons.info_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Jumlah Peserta: $numberOfPersonsDetected',
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Gap(8),
            InkWell(
              onTap: () {
                runObjectDetection();
                numberOfPersonsDetected = 0;
              },
              child: const Center(
                child: Icon(
                  Icons.camera,
                  size: 60,
                  color: Colors.lightBlue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
