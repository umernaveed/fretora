import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_models.dart';
import '../../core/storage/app_storage.dart';

class AuthController extends ChangeNotifier {
  AuthController.empty();

  AppStorage? _storage;
  ApiClient? _api;

  bool isBooting = true;
  bool isBusy = false;
  String? error;
  CourierWorkspace? activeCourier;
  AppBootstrap? bootstrapData;

  bool get isAuthenticated => bootstrapData != null;

  void bind(AppStorage storage, ApiClient api) {
    _storage = storage;
    _api = api;
  }

  Future<void> restore() async {
    isBooting = true;
    notifyListeners();
    activeCourier = await _storage!.activeCourier();
    if (activeCourier != null) {
      final token = await _storage!.tokenForTenant(activeCourier!.tenantId);
      if (token != null && token.isNotEmpty) {
        try {
          bootstrapData = await _api!.bootstrap();
        } catch (_) {
          bootstrapData = null;
        }
      }
    }
    isBooting = false;
    notifyListeners();
  }

  Future<bool> resolveCourier(String code) async {
    return _guard(() async {
      final courier = await _api!.resolveCourier(code);
      activeCourier = courier;
      bootstrapData = null;
      await _storage!.saveCourier(courier);
      return true;
    });
  }

  Future<bool> login(String email, String password) async {
    final courier = activeCourier;
    if (courier == null) return false;

    return _guard(() async {
      final result = await _api!.login(
        tenantId: courier.tenantId,
        email: email,
        password: password,
      );
      await _storage!.saveToken(courier.tenantId, result.token);
      bootstrapData = await _api!.bootstrap();
      return true;
    });
  }

  Future<void> logout() async {
    await _api?.logout();
    await _storage?.clearActiveToken();
    bootstrapData = null;
    notifyListeners();
  }

  Future<void> changeCourier() async {
    await _storage?.clearActiveCourier();
    activeCourier = null;
    bootstrapData = null;
    notifyListeners();
  }

  Future<bool> switchCourier(CourierWorkspace courier) async {
    activeCourier = courier;
    bootstrapData = null;
    await _storage!.setActiveTenant(courier.tenantId);
    notifyListeners();
    final token = await _storage!.tokenForTenant(courier.tenantId);
    if (token == null || token.isEmpty) return true;

    return _guard(() async {
      bootstrapData = await _api!.bootstrap();
      return true;
    });
  }

  Future<List<CourierWorkspace>> savedCouriers() {
    return _storage!.couriers();
  }

  Future<bool> _guard(Future<bool> Function() action) async {
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final result = await action();
      isBusy = false;
      notifyListeners();
      return result;
    } catch (exception) {
      error = apiErrorMessage(exception);
      isBusy = false;
      notifyListeners();
      return false;
    }
  }
}
