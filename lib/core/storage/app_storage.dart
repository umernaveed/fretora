import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_models.dart';

class AppStorage {
  static const _activeTenantKey = 'active_tenant_id';
  static const _couriersKey = 'courier_workspaces';
  static const _secure = FlutterSecureStorage();

  Future<List<CourierWorkspace>> couriers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_couriersKey);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List;
    return list
        .map((item) => CourierWorkspace.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveCourier(CourierWorkspace courier) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await couriers();
    final next = [
      courier,
      ...existing.where((item) => item.tenantId != courier.tenantId),
    ];
    await prefs.setString(
      _couriersKey,
      jsonEncode(next.map((item) => item.toJson()).toList()),
    );
    await prefs.setInt(_activeTenantKey, courier.tenantId);
  }

  Future<CourierWorkspace?> activeCourier() async {
    final prefs = await SharedPreferences.getInstance();
    final tenantId = prefs.getInt(_activeTenantKey);
    if (tenantId == null) return null;

    for (final courier in await couriers()) {
      if (courier.tenantId == tenantId) return courier;
    }
    return null;
  }

  Future<void> setActiveTenant(int tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeTenantKey, tenantId);
  }

  Future<void> saveToken(int tenantId, String token) {
    return _secure.write(key: 'tenant_token_$tenantId', value: token);
  }

  Future<String?> tokenForTenant(int tenantId) {
    return _secure.read(key: 'tenant_token_$tenantId');
  }

  Future<String?> tokenForActiveCourier() async {
    final courier = await activeCourier();
    if (courier == null) return null;
    return tokenForTenant(courier.tenantId);
  }

  Future<void> clearActiveToken() async {
    final courier = await activeCourier();
    if (courier != null) {
      await _secure.delete(key: 'tenant_token_${courier.tenantId}');
    }
  }

  Future<void> clearActiveCourier() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeTenantKey);
  }
}
