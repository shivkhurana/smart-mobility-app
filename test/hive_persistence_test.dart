import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:smart_mobility_controller/data/datasources/device_local_data_source.dart';
import 'package:smart_mobility_controller/data/models/device_model.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DeviceModelAdapter());
    }
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('devices deserialize correctly after the box is reopened', () async {
    var box = await Hive.openBox<DeviceModel>(DeviceLocalDataSource.boxName);
    await DeviceLocalDataSource(box).saveDevices(const [
      DeviceModel(id: '1', name: 'Motor', isActive: true),
      DeviceModel(id: '2', name: 'Battery', isActive: false),
    ]);
    await box.close();

    // Reopening forces a read from disk through DeviceModelAdapter.read.
    box = await Hive.openBox<DeviceModel>(DeviceLocalDataSource.boxName);
    final devices = DeviceLocalDataSource(box).getDevices();

    expect(devices, hasLength(2));
    final motor = devices.firstWhere((d) => d.id == '1');
    final battery = devices.firstWhere((d) => d.id == '2');
    expect(motor.name, 'Motor');
    expect(motor.isActive, isTrue);
    expect(battery.name, 'Battery');
    expect(battery.isActive, isFalse);
  });
}
