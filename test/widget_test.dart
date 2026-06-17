import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_mobility_controller/domain/entities/device.dart';
import 'package:smart_mobility_controller/domain/repositories/device_repository.dart';
import 'package:smart_mobility_controller/main.dart';

/// In-memory repository so widget tests run without Hive or network.
class FakeDeviceRepository implements DeviceRepository {
  FakeDeviceRepository(this._devices);

  List<Device> _devices;

  @override
  Future<List<Device>> getDevices() async => _devices;

  @override
  Future<void> saveDevices(List<Device> devices) async {
    _devices = devices;
  }

  @override
  Future<void> updateDevice(Device device) async {
    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index != -1) _devices[index] = device;
  }
}

void main() {
  testWidgets('renders the device list with switches', (tester) async {
    final repository = FakeDeviceRepository([
      const Device(id: '1', name: 'Front Motor Controller', isActive: true),
      const Device(id: '2', name: 'Cabin Climate Module', isActive: false),
    ]);

    await tester.pumpWidget(SmartMobilityApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Smart Mobility Controller'), findsOneWidget);
    expect(find.text('Front Motor Controller'), findsOneWidget);
    expect(find.text('Cabin Climate Module'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    expect(find.text('1 of 2 devices active'), findsOneWidget);
  });

  testWidgets('toggling a switch updates the active count', (tester) async {
    final repository = FakeDeviceRepository([
      const Device(id: '1', name: 'Front Motor Controller', isActive: false),
    ]);

    await tester.pumpWidget(SmartMobilityApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('0 of 1 devices active'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('1 of 1 devices active'), findsOneWidget);
  });
}
