import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/note_model.dart';

/// Opens and exposes the singleton Isar database instance.
class IsarService {
  /// [directoryPath] overrides the documents directory (used in unit tests).
  /// [instanceName] isolates Isar files when running tests in parallel.
  IsarService({
    String? directoryPath,
    String? instanceName,
  })  : _directoryPath = directoryPath,
        _instanceName = instanceName ?? AppConstants.isarInstanceName;

  final String? _directoryPath;
  final String _instanceName;

  Isar? _isar;

  Future<Isar> get database async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final directoryPath = _directoryPath ??
        (await getApplicationDocumentsDirectory()).path;
    _isar = await Isar.open(
      [NoteModelSchema],
      directory: directoryPath,
      name: _instanceName,
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
