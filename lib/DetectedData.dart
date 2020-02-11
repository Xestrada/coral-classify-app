import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class DetectedData {
  final Map rect;
  final String detectedClass;
  final double prob;
  const DetectedData({this.rect, this.detectedClass, this.prob});
  factory DetectedData.fromJson(Map<String, dynamic> json) => _$DetectedDataFromJson(json);
  Map<String, dynamic> toJson() => _$DetectedDataToJson(this);
}