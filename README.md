# Secure Practice Deck

A Flutter practice deck for protected backing tracks. The screen gives learners quick playback controls, looped audio, track switching, and live security diagnostics.

## Architecture

The app uses a layered structure:

- `presentation`: pages, widgets, and BLoCs
- `domain`: entities, repository contracts, and use cases
- `data`: local track metadata, encrypted audio storage, and playback service
- `core`: security, theme, and shared utilities
- `di`: service registration through `get_it`

UI state is handled with `flutter_bloc`. Playback never talks directly to widgets; the flow is UI to BLoC to use case to repository to service.

## Audio Handling

The bundled WAV files in `assets/audio` are read by the local audio data source, encrypted with AES, and stored in the app support directory with obfuscated filenames. At playback time bytes are decrypted in memory and streamed to `just_audio` through a custom audio source. After the first load, decrypted bytes stay in a memory cache so returning to a track avoids disk and decrypt work, while the active player source is still stopped and replaced on every switch.

Loop mode uses `just_audio` loop controls after preloading the selected source. Switching tracks stops the current source before loading the next encrypted buffer.

## Security

The security service enables Android `FLAG_SECURE`, screenshot prevention, data leakage protection, and iOS capture listeners where the platform supports them. The diagnostics panel shows secure window status, screenshot blocking, recording detection, audio protection, and current capture state.

## Run

```sh
flutter pub get
flutter run
```

## Limitations

External microphone recording and analog loopback cannot be reliably blocked by an app. A production build would combine these controls with licensing, watermarking, audio session policies, and server-side access checks.
