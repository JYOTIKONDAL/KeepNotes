import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/note_model.dart';

/// Opens and exposes the singleton Isar database instance.
class IsarService {
  IsarService();

  Isar? _isar;

  Future<Isar> get database async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final directory = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [NoteModelSchema],
      directory: directory.path,
      name: AppConstants.isarInstanceName,
    );
    return _isar!;
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}
