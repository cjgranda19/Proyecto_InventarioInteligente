import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  static StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // Accelerometer
  static void startAccelerometer(Function(AccelerometerEvent) onData) {
    _accelerometerSubscription = accelerometerEvents.listen(onData);
  }

  static void stopAccelerometer() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  // Gyroscope
  static void startGyroscope(Function(GyroscopeEvent) onData) {
    _gyroscopeSubscription = gyroscopeEvents.listen(onData);
  }

  static void stopGyroscope() {
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }

  // Detect shake
  static void detectShake({
    required Function() onShake,
    double threshold = 15.0,
  }) {
    startAccelerometer((event) {
      final acceleration = event.x.abs() + event.y.abs() + event.z.abs();
      if (acceleration > threshold) {
        onShake();
      }
    });
  }

  // Stop all sensors
  static void stopAll() {
    stopAccelerometer();
    stopGyroscope();
  }
}
