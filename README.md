# Smart Mobility Controller

A Flutter reference app for managing smart mobility devices. It demonstrates
**Clean Architecture**, **Hive** local caching for offline-first persistence,
and an automated **CI/CD pipeline** with GitHub Actions.

## Highlights

- **Clean Architecture** — strict separation of `domain`, `data`, and
  `presentation` layers with dependencies pointing inward.
- **Offline-first persistence** — devices are cached locally with
  [Hive](https://pub.dev/packages/hive); toggles survive app restarts.
- **State management** — [`provider`](https://pub.dev/packages/provider) +
  `ChangeNotifier` drive a reactive UI.
- **Remote seeding** — an [`http`](https://pub.dev/packages/http) data source
  seeds the initial roster, gracefully falling back to a bundled set offline.
- **Automated CI** — `flutter analyze` + `flutter test` run on every push/PR.

## Architecture

```
lib/
├── domain/                     # Pure business layer (no Flutter/Hive/HTTP)
│   ├── entities/device.dart
│   └── repositories/device_repository.dart   # abstract contract
├── data/                       # Implementation details
│   ├── models/device_model.dart              # Hive + JSON (de)serialization
│   ├── datasources/
│   │   ├── device_local_data_source.dart     # Hive box
│   │   └── device_remote_data_source.dart    # http client
│   └── repositories/device_repository_impl.dart
├── presentation/               # UI + state
│   ├── providers/device_provider.dart        # ChangeNotifier
│   ├── screens/device_list_screen.dart
│   └── widgets/device_tile.dart
└── main.dart                   # Composition root (DI + Hive init)
```

The dependency rule is enforced: `presentation` and `data` depend on `domain`,
never the reverse. `main.dart` is the composition root that wires the concrete
data sources and repository into the provider.

## DeviceModel

```dart
class Device {
  final String id;
  final String name;
  final bool isActive;
}
```

`DeviceModel` (data layer) extends `Device` and adds Hive `TypeAdapter` and JSON
serialization. The adapter is hand-written, so **no `build_runner` step** is
required.

## Data flow

```
DeviceListScreen ──▶ DeviceProvider (ChangeNotifier)
                         │
                         ▼
                 DeviceRepository (domain interface)
                         │
        DeviceRepositoryImpl (data) ──┬── DeviceLocalDataSource  (Hive)
                                      └── DeviceRemoteDataSource (http, seed)
```

On first launch the repository seeds the Hive cache (via HTTP, falling back to a
bundled list). Every toggle is written straight back to Hive, so state is
restored on the next launch.

## Getting started

```bash
flutter pub get
flutter run        # choose a device / emulator
```

Run the checks locally (these mirror CI):

```bash
flutter analyze
flutter test
```

## Continuous Integration

[`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml) runs on
every push and pull request to `main`:

1. Sets up the Flutter stable toolchain.
2. `flutter pub get`
3. `dart format --set-exit-if-changed`
4. `flutter analyze`
5. `flutter test`

## Dependencies

- [`hive`](https://pub.dev/packages/hive) / [`hive_flutter`](https://pub.dev/packages/hive_flutter) — local persistence
- [`provider`](https://pub.dev/packages/provider) — state management
- [`http`](https://pub.dev/packages/http) — remote data source
