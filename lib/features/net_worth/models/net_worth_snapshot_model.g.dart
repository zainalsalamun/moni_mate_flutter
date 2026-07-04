// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_snapshot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetWorthSnapshotModelAdapter extends TypeAdapter<NetWorthSnapshotModel> {
  @override
  final int typeId = 12;

  @override
  NetWorthSnapshotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetWorthSnapshotModel(
      id: fields[0] as String,
      year: fields[1] as int,
      month: fields[2] as int,
      snapshotDate: fields[3] as DateTime,
      totalAssets: fields[4] as double,
      totalLiabilities: fields[5] as double,
      netWorth: fields[6] as double,
      growthPercentMoM: fields[7] as double,
      growthPercentYoY: fields[8] as double,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NetWorthSnapshotModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.snapshotDate)
      ..writeByte(4)
      ..write(obj.totalAssets)
      ..writeByte(5)
      ..write(obj.totalLiabilities)
      ..writeByte(6)
      ..write(obj.netWorth)
      ..writeByte(7)
      ..write(obj.growthPercentMoM)
      ..writeByte(8)
      ..write(obj.growthPercentYoY)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetWorthSnapshotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
