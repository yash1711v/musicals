import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/audio_track_entity.dart';
import '../local/local_audio_file_data_source.dart';

class SecureAudioVault {
  SecureAudioVault({
    required FlutterSecureStorage secureStorage,
    required LocalAudioFileDataSource localAudioFileDataSource,
  }) : _secureStorage = secureStorage,
       _localAudioFileDataSource = localAudioFileDataSource;

  static const _keyName = 'secure_audio_vault_key';

  final FlutterSecureStorage _secureStorage;
  final LocalAudioFileDataSource _localAudioFileDataSource;
  final Map<String, Uint8List> _decryptedCache = {};

  Future<Uint8List> loadDecryptedBytes(AudioTrackEntity track) async {
    final cached = _decryptedCache[track.id];
    if (cached != null) {
      return cached;
    }

    final file = await _fileFor(track);

    if (!await file.exists()) {
      await _writeEncryptedTrack(file, track);
    }

    final payload = await file.readAsBytes();

    if (payload.length <= 16) {
      await file.delete();
      await _writeEncryptedTrack(file, track);
      return loadDecryptedBytes(track);
    }

    final key = await _key();
    final iv = encrypt.IV(Uint8List.fromList(payload.sublist(0, 16)));
    final encrypted = encrypt.Encrypted(
      Uint8List.fromList(payload.sublist(16)),
    );
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final decrypted = Uint8List.fromList(
      encrypter.decryptBytes(encrypted, iv: iv),
    );
    _decryptedCache[track.id] = decrypted;
    return decrypted;
  }

  Future<bool> isProtected(AudioTrackEntity track) async {
    final file = await _fileFor(track);
    return file.exists();
  }

  bool isCached(AudioTrackEntity track) {
    return _decryptedCache.containsKey(track.id);
  }

  Future<void> _writeEncryptedTrack(File file, AudioTrackEntity track) async {
    final key = await _key();
    final iv = encrypt.IV.fromSecureRandom(16);
    final bytes = await _localAudioFileDataSource.load(track);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    final payload = BytesBuilder(copy: false)
      ..add(iv.bytes)
      ..add(encrypted.bytes);

    await file.parent.create(recursive: true);
    await file.writeAsBytes(payload.toBytes(), flush: true);
  }

  Future<encrypt.Key> _key() async {
    final stored = await _secureStorage.read(key: _keyName);

    if (stored != null) {
      return encrypt.Key(Uint8List.fromList(base64Decode(stored)));
    }

    final key = encrypt.Key.fromSecureRandom(32);
    await _secureStorage.write(key: _keyName, value: base64Encode(key.bytes));
    return key;
  }

  Future<File> _fileFor(AudioTrackEntity track) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/audio_vault/${track.encryptedPath}');
  }
}
