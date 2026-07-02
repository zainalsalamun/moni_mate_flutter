// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonthlyReportModelAdapter extends TypeAdapter<MonthlyReportModel> {
  @override
  final int typeId = 9;

  @override
  MonthlyReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyReportModel(
      id: fields[0] as String,
      month: fields[1] as int,
      year: fields[2] as int,
      generatedAt: fields[3] as DateTime,
      pdfPath: fields[4] as String?,
      imagePath: fields[5] as String?,
      summaryDataJson: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyReportModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.generatedAt)
      ..writeByte(4)
      ..write(obj.pdfPath)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.summaryDataJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
