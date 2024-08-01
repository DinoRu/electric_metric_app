class PendingMeter {
  final String meterId;
  final String meterName;
  final String meterImagePath;
  final String metricImagePath;
  final double previousIndication;
  final double currentIndication;
  String? comment;

  PendingMeter(
      {required this.meterId,
      required this.meterName,
      required this.currentIndication,
      required this.previousIndication,
      required this.meterImagePath,
      required this.metricImagePath,
      required this.comment});

  factory PendingMeter.fromJson(Map<String, dynamic> json) {
    return PendingMeter(
        meterId: json['meterId'],
        meterName: json['meterName'],
        currentIndication: json['currentIndication'],
        previousIndication: json['previousIndication'],
        meterImagePath: json['meterImagePath'],
        metricImagePath: json['metricImagePath'],
        comment: json['comment'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'meterId': meterId,
      'meterName': meterName,
      'meterImagePath': meterImagePath,
      'metricImagePath': metricImagePath,
      'previousIndication': previousIndication,
      'currentIndication': currentIndication,
      'comment': comment ?? "",
    };
  }
}
