// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_login.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalLoginAdapter extends TypeAdapter<LocalLogin> {
  @override
  final int typeId = 0;

  @override
  LocalLogin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalLogin(
      fields[0] as String,
      fields[1] as String,
      fields[3] as String,
      fields[2] as String,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalLogin obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.senderUid)
      ..writeByte(4)
      ..write(obj.ciudad);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalLoginAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
