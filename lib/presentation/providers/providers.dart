import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:proyecto/data/datasources/local/database_helper.dart';
import 'package:proyecto/data/datasources/local/local_user_datasource.dart';
import 'package:proyecto/data/datasources/local/local_category_datasource.dart';
import 'package:proyecto/data/datasources/local/local_inventory_datasource.dart';
import 'package:proyecto/data/datasources/remote/remote_auth_datasource.dart';
import 'package:proyecto/data/datasources/remote/remote_category_datasource.dart';
import 'package:proyecto/data/datasources/remote/remote_inventory_datasource.dart';
import 'package:proyecto/data/repositories/auth_repository_impl.dart';
import 'package:proyecto/data/repositories/category_repository_impl.dart';
import 'package:proyecto/data/repositories/inventory_repository_impl.dart';
import 'package:proyecto/domain/repositories/auth_repository.dart';
import 'package:proyecto/domain/repositories/category_repository.dart';
import 'package:proyecto/domain/repositories/inventory_repository.dart';
import 'package:proyecto/core/network/network_info.dart';
import 'package:proyecto/core/services/sync_service.dart';

// External dependencies
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    // OAuth 2.0 Web client ID desde google-services.json
    serverClientId: '270408680143-deulerujl47lvfk3kohngsbkna74n3gt.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
    ],
  );
});

final facebookAuthProvider = Provider<FacebookAuth>((ref) {
  return FacebookAuth.instance;
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

// Database
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Network
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(ref.watch(connectivityProvider));
});

// Local Data Sources
final localUserDataSourceProvider = Provider<LocalUserDataSource>((ref) {
  return LocalUserDataSource(ref.watch(databaseHelperProvider));
});

final localCategoryDataSourceProvider = Provider<LocalCategoryDataSource>((ref) {
  return LocalCategoryDataSource(ref.watch(databaseHelperProvider));
});

final localInventoryDataSourceProvider = Provider<LocalInventoryDataSource>((ref) {
  return LocalInventoryDataSource(ref.watch(databaseHelperProvider));
});

// Remote Data Sources
final remoteAuthDataSourceProvider = Provider<RemoteAuthDataSource>((ref) {
  return RemoteAuthDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    facebookAuth: ref.watch(facebookAuthProvider),
    httpClient: ref.watch(httpClientProvider),
  );
});

final remoteCategoryDataSourceProvider = Provider<RemoteCategoryDataSource>((ref) {
  return RemoteCategoryDataSource(ref.watch(firestoreProvider));
});

final remoteInventoryDataSourceProvider = Provider<RemoteInventoryDataSource>((ref) {
  return RemoteInventoryDataSource(ref.watch(firestoreProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(remoteAuthDataSourceProvider),
    localDataSource: ref.watch(localUserDataSourceProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    remoteDataSource: ref.watch(remoteCategoryDataSourceProvider),
    localDataSource: ref.watch(localCategoryDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    remoteDataSource: ref.watch(remoteInventoryDataSourceProvider),
    localDataSource: ref.watch(localInventoryDataSourceProvider),
    localCategoryDataSource: ref.watch(localCategoryDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Sync Service
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    inventoryRepository: ref.watch(inventoryRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
    networkInfo: ref.watch(networkInfoProvider),
    connectivity: ref.watch(connectivityProvider),
  );
});
