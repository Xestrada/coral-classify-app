// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DetectedData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectedData _$DetectedDataFromJson(Map<String, dynamic> json) {
  return DetectedData(
    rect: json['rect'] as Map<String, dynamic>,
    detectedClass: json['detectedClass'] as String,
    prob: (json['prob'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$DetectedDataToJson(DetectedData instance) =>
    <String, dynamic>{
      'rect': instance.rect,
      'detectedClass': instance.detectedClass,
      'prob': instance.prob,
    };
