import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../common/util/logger.dart';

abstract interface class ILogbookRepository {
  Future<void> sendLog(
    Uri uri,
    Uint8List bytes, {
    required final String fileName,
    final Map<String, String>? fields,
  });
}

class LogbookRepository implements ILogbookRepository {
  @override
  Future<void> sendLog(
    Uri uri,
    Uint8List bytes, {
    required final String fileName,
    final Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(fields ?? {})
      ..files.add(
        http.MultipartFile.fromBytes('document', bytes, filename: fileName),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final responseBody = json.decode(response.body);

    l.i('Response: $responseBody');
  }
}
