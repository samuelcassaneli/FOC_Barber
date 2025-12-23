/// Tipo de aplicativo
enum AppFlavor {
  /// App para clientes agendarem
  client,
  /// App para gestão da barbearia
  barbershop,
  /// Painel administrativo (webapp)
  admin,
}

/// Configuração global do aplicativo
class AppConfig {
  static AppFlavor? _flavor;
  static String? _barbershopId;
  static String? _barbershopSlug;
  static String? _barbershopName;

  /// Inicializa a configuração do app
  static void initialize({
    required AppFlavor flavor,
    String? barbershopId,
    String? barbershopSlug,
    String? barbershopName,
  }) {
    _flavor = flavor;
    _barbershopId = barbershopId;
    _barbershopSlug = barbershopSlug;
    _barbershopName = barbershopName;
  }

  /// Define apenas o flavor (compatibilidade com código antigo)
  static void setFlavor(AppFlavor flavor) {
    _flavor = flavor;
  }

  /// Define o ID da barbearia em runtime
  static void setBarbershopId(String id) {
    _barbershopId = id;
  }

  /// Define os dados da barbearia
  static void setBarbershopData({
    required String id,
    required String slug,
    required String name,
  }) {
    _barbershopId = id;
    _barbershopSlug = slug;
    _barbershopName = name;
  }

  /// Tipo do aplicativo
  static AppFlavor get flavor {
    if (_flavor == null) {
      throw Exception('AppFlavor not initialized! Call AppConfig.initialize() first.');
    }
    return _flavor!;
  }

  /// ID da barbearia (para apps de cliente e gestão)
  static String? get barbershopId => _barbershopId;

  /// Slug da barbearia
  static String? get barbershopSlug => _barbershopSlug;

  /// Nome da barbearia
  static String? get barbershopName => _barbershopName;

  /// Verifica se é app de gestão da barbearia
  static bool get isBarbershop => _flavor == AppFlavor.barbershop;

  /// Alias para compatibilidade
  static bool get isBarber => isBarbershop;

  /// Verifica se é app de cliente
  static bool get isClient => _flavor == AppFlavor.client;

  /// Verifica se é painel admin
  static bool get isAdmin => _flavor == AppFlavor.admin;

  /// Verifica se tem barbearia configurada
  static bool get hasBarbershop => _barbershopId != null && _barbershopId!.isNotEmpty;

  /// Obtém o ID da barbearia ou lança exceção se não configurado
  static String get requiredBarbershopId {
    if (_barbershopId == null || _barbershopId!.isEmpty) {
      throw Exception('Barbershop ID not configured! Set it via AppConfig.setBarbershopId()');
    }
    return _barbershopId!;
  }

  /// Limpa a configuração (útil para logout)
  static void clear() {
    _barbershopId = null;
    _barbershopSlug = null;
    _barbershopName = null;
  }

  /// Obtém valores do dart-define (build time)
  static String? get envBarbershopId =>
      const String.fromEnvironment('BARBERSHOP_ID', defaultValue: '');

  static String? get envBarbershopSlug =>
      const String.fromEnvironment('BARBERSHOP_SLUG', defaultValue: '');

  static AppFlavor get envAppType {
    const type = String.fromEnvironment('APP_TYPE', defaultValue: 'client');
    switch (type) {
      case 'barbershop':
      case 'barber':
        return AppFlavor.barbershop;
      case 'admin':
        return AppFlavor.admin;
      default:
        return AppFlavor.client;
    }
  }
}

/// Extensão para facilitar comparações
extension AppFlavorExtension on AppFlavor {
  bool get isClient => this == AppFlavor.client;
  bool get isBarbershop => this == AppFlavor.barbershop;
  bool get isAdmin => this == AppFlavor.admin;

  String get displayName {
    switch (this) {
      case AppFlavor.client:
        return 'Cliente';
      case AppFlavor.barbershop:
        return 'Barbearia';
      case AppFlavor.admin:
        return 'Administrador';
    }
  }
}
