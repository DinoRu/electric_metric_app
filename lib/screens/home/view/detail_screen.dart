import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:electric_meter_app/blocs/auth_bloc.dart';
import 'package:electric_meter_app/components/my_formfield.dart';
import 'package:electric_meter_app/components/my_photo_button.dart';
import 'package:electric_meter_app/screens/home/bloc/metric_bloc/metric_bloc.dart';
import 'package:electric_meter_app/screens/home/bloc/prelevement_bloc/prelevement_bloc.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter_exif_plugin/tags.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:metric_repository/metric_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailScreen extends StatefulWidget {
  final Metric metric;
  const DetailScreen(this.metric, {super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController indexController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  bool submitted = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _meterImageFile;
  XFile? _metricImageFile;
  bool _isSecondButtonVisible = false;
  bool _photoMissing = false;
  late FlutterExif exif;
  // ignore: unused_field
  late Map<String, IfdTag>? _metadata;

  Future<void> checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
  }

  Future<bool> _checkGeotags(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final data = await readExifFromBytes(bytes);
    if (data.isNotEmpty) {
      return data.containsKey('GPS GPSLatitude') &&
          data.containsKey('GPS GPSLongitude');
    }
    return false;
  }

  Future<void> _readMetadata(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final data = await readExifFromBytes(bytes);
    if (data.isEmpty) {
      print("No EXIF information found");
    } else {
      setState(() {
        _metadata = data;
      });

      log(data.toString());
      // Example: Print GPS Latitude and Longitude
      if (data.containsKey('GPS GPSLatitude') &&
          data.containsKey('GPS GPSLongitude')) {
        print('Latitude: ${data['GPS GPSLatitude']}');
        print('Longitude: ${data['GPS GPSLongitude']}');
      }
    }
  }

  Future<Position> _determinePosition() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Future<void> _addGeotagFlutterExif(XFile image, Position position) async {
    List<int> latitude = _convertToExifFormat(position.latitude);
    List<int> longitude = _convertToExifFormat(position.longitude);
    try {
      exif = FlutterExif.fromPath(image.path);
      exif.setLatLong(position.latitude, position.longitude);
      exif.setAttribute(
          TAG_USER_COMMENT,
          jsonEncode({
            'GPS GPSLatitude': '${latitude[0]}, ${latitude[1]}, ${latitude[2]}',
            'GPS GPSLongitude':
                '${longitude[0]}, ${longitude[1]}, ${longitude[2]}',
            'GPS GPSLatitudeRef': position.latitude >= 0 ? 'N' : 'S',
            'GPS GPSLongitudeRef': position.longitude >= 0 ? 'E' : 'W',
          }));
      exif.saveAttributes();
    } catch (e) {
      log("Error writing EXIFS tags: ${e.toString()}");
      log(e.toString());
    }
  }

  List<int> _convertToExifFormat(double value) {
    final degrees = value.abs().floor();
    final minutes = ((value.abs() - degrees) * 60).floor();
    final seconds = (((value.abs() - degrees) * 60 - minutes) * 60).round();
    return [degrees, minutes, seconds];
  }

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user!;
    return ProgressHUD(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.metric.name ?? 'N/A'),
        ),
        body: BlocListener<PrelevementBloc, PrelevementState>(
          listener: (context, state) {
            final progressHUD = ProgressHUD.of(context);
            if (state is PrelevementLoading) {
              progressHUD?.show();
            } else if (state is PrelevementSuccess) {
              progressHUD?.dismiss();
              _showSnackBar(
                  context, 'Задание выполнено успешно!', Colors.greenAccent);
              context.read<MetricBloc>().add(FetchMetricByUser(user));
              Navigator.pop(context);
            } else if (state is PrelevementFailure) {
              progressHUD?.dismiss();
              _showSnackBar(context, state.error, Colors.red);
            }
          },
          child: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Title("Номер счетчика", widget.metric.number),
                    divider,
                    Title('Наименование', widget.metric.name),
                    divider,
                    Title('Предыдущие показания',
                        widget.metric.previousIndication.toString()),
                    divider,
                    const SizedBox(height: 10),
                    const Text('Текущие показания'),
                    const SizedBox(height: 10),
                    MyTextFormField(
                      controller: indexController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Пожалуйста, заполните это поле";
                        } else if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(val)) {
                          return "Пожалуйста, введите действительное значение";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Комментарий'),
                    const SizedBox(height: 10),
                    MyTextFormField(
                        controller: commentController,
                        hintText: 'Напишите комментарий',
                        keyboardType: TextInputType.text),
                    const SizedBox(height: 20),
                    if (_meterImageFile != null)
                      Image.file(
                        File(_meterImageFile!.path),
                        width: double.maxFinite,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    SizedBox(
                        width: double.maxFinite,
                        child: PictureButton('Фото показаний', () async {
                          final pickedFile = await _picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 40,
                              preferredCameraDevice: CameraDevice.rear);
                          if (pickedFile != null) {
                            File image = File(pickedFile.path);
                            bool hasGeo = await _checkGeotags(image);
                            log("Meter image has Geo tags: $hasGeo");
                            if (!hasGeo) {
                              Position position = await _determinePosition();
                              await _addGeotagFlutterExif(pickedFile, position);
                              await _readMetadata(image);
                              log(position.toString());
                            }
                            await _readMetadata(image);
                            setState(() {
                              _meterImageFile = pickedFile;

                              _isSecondButtonVisible = true;
                            });
                          }
                        })),
                    const SizedBox(height: 10),
                    if (_metricImageFile != null)
                      Image.file(
                        File(_metricImageFile!.path),
                        width: double.maxFinite,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    if (_isSecondButtonVisible)
                      SizedBox(
                          width: double.maxFinite,
                          child: PictureButton('Фото счётчика', () async {
                            final pickedFile = await _picker.pickImage(
                                source: ImageSource.camera, imageQuality: 40);
                            if (pickedFile != null) {
                              File metricImage = File(pickedFile.path);
                              bool hasGeoLocalisation =
                                  await _checkGeotags(metricImage);
                              log("Metric image has: $hasGeoLocalisation");
                            }
                            setState(() {
                              if (pickedFile != null) {
                                _metricImageFile = pickedFile;
                              }
                            });
                          })),
                    if (_photoMissing)
                      const Text(
                        'Пожалуйста, добавьте обе фотографии.',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    const SizedBox(height: 40),
                    !submitted
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      _validatePhotos()) {
                                    context.read<PrelevementBloc>().add(
                                        SubmitEvent(
                                            meterId: widget.metric.taskId!,
                                            meterName: widget.metric.number!,
                                            previousIndication: widget
                                                .metric.previousIndication!,
                                            currentIndication: double.parse(
                                                indexController.text),
                                            meterImage: _meterImageFile!,
                                            metricImage: _metricImageFile!,
                                            comment: commentController.text));
                                  } else {
                                    setState(() {
                                      _photoMissing = true;
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                    elevation: 3.0,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(60))),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 5),
                                  child: Text(
                                    'Выполнить',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validatePhotos() {
    return _metricImageFile != null && _meterImageFile != null;
  }

  TextStyle medium = const TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
  Divider divider = Divider(color: Colors.green[300]);

  Widget Title(String title, String? value) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 10),
          Expanded(
              child: Text(
            value ?? 'N/A',
            style: medium,
          ))
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
