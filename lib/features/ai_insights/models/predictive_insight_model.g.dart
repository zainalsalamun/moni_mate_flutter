// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predictive_insight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PredictiveInsightModelAdapter
    extends TypeAdapter<PredictiveInsightModel> {
  @override
  final int typeId = 10;

  @override
  PredictiveInsightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PredictiveInsightModel(
      id: fields[0] as String,
      title: fields[1] as String,
      message: fields[2] as String,
      type: fields[3] as String,
      severity: fields[4] as String,
      source: fields[5] as String,
      createdAt: fields[6] as DateTime,
      actionLabel: fields[7] as String,
      actionRoute: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PredictiveInsightModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.severity)
      ..writeByte(5)
      ..write(obj.source)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.actionLabel)
      ..writeByte(8)
      ..write(obj.actionRoute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictiveInsightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
