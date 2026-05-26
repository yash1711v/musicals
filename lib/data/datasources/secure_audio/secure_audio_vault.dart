import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/audio_track_entity.dart';
import 'audio_sample_synthesizer.dart';

class SecureAudioVault {
  SecureAudioVault({
    required FlutterSecureStorage secureStorage,
    required AudioSampleSynthesizer synthesizer,
  }) : _secureStorage = secureStorage,
       _synthesizer = synthesizer;

  static const _keyName = 'secure_audio_vault_key';

  final FlutterSecureStorage _secureStorage;
  final AudioSampleSynthesizer _synthesizer;

  Future<Uint8List> loadDecryptedBytes(AudioTrackEntity track) async {
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

    return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
  }

  Future<bool> isProtected(AudioTrackEntity track) async {
    final file = await _fileFor(track);
    return file.exists();
  }

  Future<void> _writeEncryptedTrack(File file, AudioTrackEntity track) async {
    final key = await _key();
    final iv = encrypt.IV.fromSecureRandom(16);
    final bytes = _synthesizer.build(track);
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
