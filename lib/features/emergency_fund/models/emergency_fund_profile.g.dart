// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_fund_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmergencyFundProfileAdapter extends TypeAdapter<EmergencyFundProfile> {
  @override
  final int typeId = 11;

  @override
  EmergencyFundProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmergencyFundProfile(
      id: fields[0] as String?,
      type: fields[1] as String,
      customMultiplier: fields[2] as int,
      updatedAt: fields[3] as DateTime?,
      isSynced: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyFundProfile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.customMultiplier)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyFundProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
