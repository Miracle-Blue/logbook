import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../common/util/logger.dart';

/// {@template i_logbook_repository}
/// Logbook repository interface.
/// {@endtemplate}
abstract interface class ILogbookRepository {
  /// {@macro i_logbook_repository}
  const ILogbookRepository();

  Future<void> sendLog(Uri uri, Uint8List bytes, {required final String fileName, final Map<String, String>? fields});
}

/// {@template logbook_repository_impl}
/// Logbook repository implementation.
/// {@endtemplate}
final class LogbookRepositoryImpl implements ILogbookRepository {
  /// {@macro logbook_repository_impl}
  const LogbookRepositoryImpl();

  @override
  Future<void> sendLog(
    Uri uri,
    Uint8List bytes, {
    required final String fileName,
    final Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(fields ?? {})
      ..files.add(http.MultipartFile.fromBytes('document', bytes, filename: fileName));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final responseBody = json.decode(response.body);

    l.i('Response: $responseBody');
  }
}
