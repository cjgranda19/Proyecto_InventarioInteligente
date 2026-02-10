import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:proyecto/domain/repositories/inventory_repository.dart';
import 'package:proyecto/domain/repositories/category_repository.dart';
import 'package:proyecto/core/network/network_info.dart';

class SyncService {
  final InventoryRepository inventoryRepository;
  final CategoryRepository categoryRepository;
  final NetworkInfo networkInfo;
  final Connectivity connectivity;
  
  StreamSubscription<bool>? _connectivitySubscription;
  String? _currentUserId;
  bool _isSyncing = false;

  SyncService({
    required this.inventoryRepository,
    required this.categoryRepository,
    required this.networkInfo,
    required this.connectivity,
  });

  /// Inicializa el servicio de sincronización para un usuario
  void initialize(String userId) {
    _currentUserId = userId;
    _startListeningToConnectivity();
    // Intentar sincronizar inmediatamente
    _syncIfConnected();
  }

  /// Detiene el servicio de sincronización
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _currentUserId = null;
  }

  /// Comienza a escuchar cambios en la conectividad
  void _startListeningToConnectivity() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((isConnected) {
      print(' Cambio de conectividad detectado: ${isConnected ? "Conectado" : "Desconectado"}');
      
      if (isConnected && _currentUserId != null) {
        print(' Conexión restaurada, iniciando sincronización automática...');
        _syncIfConnected();
      }
    });
  }

  /// Sincroniza datos si hay conexión disponible
  Future<void> _syncIfConnected() async {
    if (_isSyncing) {
      print('Ya hay una sincronización en curso, omitiendo...');
      return;
    }

    if (_currentUserId == null) {
      print(' No hay usuario logueado, cancelando sincronización');
      return;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      print(' Sin conexión a internet, sincronización pospuesta');
      return;
    }

    _isSyncing = true;
    print(' Iniciando sincronización automática...');

    try {
      // Sincronizar items del inventario
      print(' Sincronizando items...');
      await inventoryRepository.syncItems(_currentUserId!);
      
      // Sincronizar categorías
      print('Sincronizando categorías...');
      await categoryRepository.syncCategories(_currentUserId!);
      
      print('Sincronización completada exitosamente');
    } catch (e) {
      print(' Error durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Fuerza una sincronización manual
  Future<bool> forceSync() async {
    if (_currentUserId == null) {
      print('⚠️ No hay usuario logueado');
      return false;
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      print('📵 Sin conexión a internet');
      return false;
    }

    await _syncIfConnected();
    return true;
  }
}
