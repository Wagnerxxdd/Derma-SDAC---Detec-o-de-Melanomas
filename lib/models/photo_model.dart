import 'package:hive/hive.dart';

part 'photo_model.g.dart';

@HiveType(typeId: 0)
class PhotoModel extends HiveObject {
  @HiveField(0)
  String path;

  @HiveField(1)
  DateTime date;

  PhotoModel({
    required this.path,
    required this.date,
  });
}