import 'dart:convert';

Metric metricFromJson(String str) => Metric.fromJson(json.decode(str));

String metricToJson(Metric data) => json.encode(data.toJson());

class Metric {
  String? taskId;
  String? code;
  String? name;
  String? address;
  double? currentIndication;
  double? previousIndication;
  String? comment;
  String? status;
  String? nearPhotoUrl;
  String? farPhotoUrl;
  String? number;

  Metric({
    this.taskId,
    this.code,
    this.name,
    this.address,
    this.currentIndication,
    this.previousIndication,
    this.comment,
    this.status,
    this.nearPhotoUrl,
    this.farPhotoUrl,
    this.number,
  });

  factory Metric.fromJson(Map<String, dynamic> json) => Metric(
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
