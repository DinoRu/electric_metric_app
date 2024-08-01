import 'dart:convert';

MetricEntity metricEntityFromJson(String str) =>
    MetricEntity.fromJson(json.decode(str));

String metricEntityToJson(MetricEntity data) => json.encode(data.toJson());

class MetricEntity {
  final String taskId;
  final String code;
  final String name;
  final String address;
  final int currentIndication;
  final int previousIndication;
  final String comment;
  final String status;
  final String nearPhotoUrl;
  final String farPhotoUrl;
  final String number;

  MetricEntity({
    required this.taskId,
    required this.code,
    required this.name,
    required this.address,
    required this.currentIndication,
    required this.previousIndication,
    required this.comment,
    required this.status,
    required this.nearPhotoUrl,
    required this.farPhotoUrl,
    required this.number,
  });

  factory MetricEntity.fromJson(Map<String, dynamic> json) => MetricEntity(
        taskId: json["task_id"],
        code: json["code"],
        name: json["name"],
        address: json["address"],
        currentIndication: json["current_indication"],
        previousIndication: json["previous_indication"],
        comment: json["comment"],
        status: json["status"],
        nearPhotoUrl: json["near_photo_url"],
        farPhotoUrl: json["far_photo_url"],
        number: json["number"],
      );

  Map<String, dynamic> toJson() => {
        "task_id": taskId,
        "code": code,
        "name": name,
        "address": address,
        "current_indication": currentIndication,
        "previous_indication": previousIndication,
        "comment": comment,
        "status": status,
        "near_photo_url": nearPhotoUrl,
        "far_photo_url": farPhotoUrl,
        "number": number,
      };
}
