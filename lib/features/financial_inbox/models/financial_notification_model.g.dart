// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancialNotificationModelAdapter
    extends TypeAdapter<FinancialNotificationModel> {
  @override
  final int typeId = 18;

  @override
  FinancialNotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancialNotificationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      message: fields[2] as String,
      category: fields[3] as NotificationCategory,
      priority: fields[4] as NotificationPriority,
      actionRoute: fields[5] as String?,
      actionPayload: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      isRead: fields[8] as bool,
      isDismissed: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FinancialNotificationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.actionRoute)
      ..writeByte(6)
      ..write(obj.actionPayload)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isRead)
      ..writeByte(9)
      ..write(obj.isDismissed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialNotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationCategoryAdapter extends TypeAdapter<NotificationCategory> {
  @override
  final int typeId = 19;

  @override
  NotificationCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationCategory.aiCoach;
      case 1:
        return NotificationCategory.budgetAlert;
      case 2:
        return NotificationCategory.goalReminder;
      case 3:
        return NotificationCategory.emergencyFund;
      case 4:
        return NotificationCategory.achievement;
      case 5:
        return NotificationCategory.monthlyReport;
      case 6:
        return NotificationCategory.recurringTransaction;
      case 7:
        return NotificationCategory.smartSpending;
      default:
        return NotificationCategory.aiCoach;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationCategory obj) {
    switch (obj) {
      case NotificationCategory.aiCoach:
        writer.writeByte(0);
        break;
      case NotificationCategory.budgetAlert:
        writer.writeByte(1);
        break;
      case NotificationCategory.goalReminder:
        writer.writeByte(2);
        break;
      case NotificationCategory.emergencyFund:
        writer.writeByte(3);
        break;
      case NotificationCategory.achievement:
        writer.writeByte(4);
        break;
      case NotificationCategory.monthlyReport:
        writer.writeByte(5);
        break;
      case NotificationCategory.recurringTransaction:
        writer.writeByte(6);
        break;
      case NotificationCategory.smartSpending:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPriorityAdapter extends TypeAdapter<NotificationPriority> {
  @override
  final int typeId = 20;

  @override
  NotificationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationPriority.critical;
      case 1:
        return NotificationPriority.warning;
      case 2:
        return NotificationPriority.success;
      case 3:
        return NotificationPriority.info;
      default:
        return NotificationPriority.critical;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationPriority obj) {
    switch (obj) {
      case NotificationPriority.critical:
        writer.writeByte(0);
        break;
      case NotificationPriority.warning:
        writer.writeByte(1);
        break;
      case NotificationPriority.success:
        writer.writeByte(2);
        break;
      case NotificationPriority.info:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
