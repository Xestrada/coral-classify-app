import 'package:json_annotation/json_annotation.dart';

part 'DetectedData.g.dart';

@JsonSerializable()
class DetectedData {
  Map rect;
  String detectedClass;
  double prob;
  DetectedData({this.rect, this.detectedClass, this.prob});
  factory DetectedData.fromJson(Map<String, dynamic> json) => _$DetectedDataFromJson(json);
  Map<String, dynamic> toJson() => _$DetectedDataToJson(this);
}