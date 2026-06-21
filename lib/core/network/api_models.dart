class CourierWorkspace {
  const CourierWorkspace({
    required this.tenantId,
    required this.courierCode,
    required this.companyName,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.loginBackgroundUrl,
    this.modules = const {},
  });

  final int tenantId;
  final String courierCode;
  final String companyName;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? loginBackgroundUrl;
  final Map<String, bool> modules;

  factory CourierWorkspace.fromJson(Map<String, dynamic> json) {
    return CourierWorkspace(
      tenantId: int.parse('${json['tenant_id'] ?? json['id']}'),
      courierCode: '${json['courier_code'] ?? json['code'] ?? ''}',
      companyName: '${json['company_name'] ?? json['name'] ?? 'Courier'}',
      logoUrl: json['logo']?.toString(),
      primaryColor: json['primary_color']?.toString(),
      secondaryColor: json['secondary_color']?.toString(),
      loginBackgroundUrl: json['login_background']?.toString(),
      modules: (json['modules'] as Map? ?? const {})
          .map((key, value) => MapEntry('$key', value == true)),
    );
  }

  Map<String, dynamic> toJson() => {
        'tenant_id': tenantId,
        'courier_code': courierCode,
        'company_name': companyName,
        'logo': logoUrl,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
        'login_background': loginBackgroundUrl,
        'modules': modules,
      };
}

class LoginResult {
  const LoginResult({required this.token, required this.user});

  final String token;
  final Map<String, dynamic> user;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: '${json['token'] ?? json['access_token'] ?? ''}',
      user: (json['user'] as Map? ?? const {}).cast<String, dynamic>(),
    );
  }
}

class AppBootstrap {
  const AppBootstrap({
    required this.user,
    required this.tenant,
    required this.modules,
    required this.summary,
  });

  final Map<String, dynamic> user;
  final CourierWorkspace tenant;
  final Map<String, bool> modules;
  final Map<String, dynamic> summary;

  factory AppBootstrap.fromJson(Map<String, dynamic> json) {
    final tenantJson = (json['tenant'] as Map? ?? const {}).cast<String, dynamic>();
    final modules = (json['modules'] as Map? ?? const {})
        .map((key, value) => MapEntry('$key', value == true));

    return AppBootstrap(
      user: (json['user'] as Map? ?? const {}).cast<String, dynamic>(),
      tenant: CourierWorkspace.fromJson(tenantJson),
      modules: modules,
      summary: (json['summary'] as Map? ?? const {}).cast<String, dynamic>(),
    );
  }
}
