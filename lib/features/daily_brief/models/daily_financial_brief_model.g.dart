// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_financial_brief_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyFinancialBriefModelAdapter
    extends TypeAdapter<DailyFinancialBriefModel> {
  @override
  final int typeId = 15;

  @override
  DailyFinancialBriefModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyFinancialBriefModel(
      id: fields[0] as String?,
      date: fields[1] as DateTime,
      title: fields[2] as String,
      summary: fields[3] as String,
      priority: fields[4] as DailyBriefPriority,
      category: fields[5] as DailyBriefCategory,
      generatedAt: fields[6] as DateTime?,
      isRead: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DailyFinancialBriefModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.summary)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.generatedAt)
      ..writeByte(7)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyFinancialBriefModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyBriefPriorityAdapter extends TypeAdapter<DailyBriefPriority> {
  @override
  final int typeId = 16;

  @override
  DailyBriefPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DailyBriefPriority.info;
      case 1:
        return DailyBriefPriority.success;
      case 2:
        return DailyBriefPriority.warning;
      case 3:
        return DailyBriefPriority.danger;
      default:
        return DailyBriefPriority.info;
    }
  }

  @override
  void write(BinaryWriter writer, DailyBriefPriority obj) {
    switch (obj) {
      case DailyBriefPriority.info:
        writer.writeByte(0);
        break;
      case DailyBriefPriority.success:
        writer.writeByte(1);
        break;
      case DailyBriefPriority.warning:
        writer.writeByte(2);
        break;
      case DailyBriefPriority.danger:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyBriefPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyBriefCategoryAdapter extends TypeAdapter<DailyBriefCategory> {
  @override
  final int typeId = 17;

  @override
  DailyBriefCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DailyBriefCategory.budget;
      case 1:
        return DailyBriefCategory.goal;
      case 2:
        return DailyBriefCategory.emergency;
      case 3:
        return DailyBriefCategory.wealth;
      case 4:
        return DailyBriefCategory.gamification;
      case 5:
        return DailyBriefCategory.health;
      case 6:
        return DailyBriefCategory.general;
      default:
        return DailyBriefCategory.budget;
    }
  }

  @override
  void write(BinaryWriter writer, DailyBriefCategory obj) {
    switch (obj) {
      case DailyBriefCategory.budget:
        writer.writeByte(0);
        break;
      case DailyBriefCategory.goal:
        writer.writeByte(1);
        break;
      case DailyBriefCategory.emergency:
        writer.writeByte(2);
        break;
      case DailyBriefCategory.wealth:
        writer.writeByte(3);
        break;
      case DailyBriefCategory.gamification:
        writer.writeByte(4);
        break;
      case DailyBriefCategory.health:
        writer.writeByte(5);
        break;
      case DailyBriefCategory.general:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyBriefCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
