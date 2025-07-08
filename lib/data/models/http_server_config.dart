class HttpServerConfig {
  final bool isEnabled;
  final String host;
  final int port;
  final bool corsEnabled;
  final List<String> allowedOrigins;

  const HttpServerConfig({
    this.isEnabled = false,
    this.host = 'localhost',
    this.port = 8080,
    this.corsEnabled = true,
    this.allowedOrigins = const ['*'],
  });

  HttpServerConfig copyWith({
    bool? isEnabled,
    String? host,
    int? port,
    bool? corsEnabled,
    List<String>? allowedOrigins,
  }) {
    return HttpServerConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      host: host ?? this.host,
      port: port ?? this.port,
      corsEnabled: corsEnabled ?? this.corsEnabled,
      allowedOrigins: allowedOrigins ?? this.allowedOrigins,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'host': host,
      'port': port,
      'corsEnabled': corsEnabled,
      'allowedOrigins': allowedOrigins,
    };
  }

  factory HttpServerConfig.fromJson(Map<String, dynamic> json) {
    return HttpServerConfig(
      isEnabled: json['isEnabled'] ?? false,
      host: json['host'] ?? 'localhost',
      port: json['port'] ?? 8080,
      corsEnabled: json['corsEnabled'] ?? true,
      allowedOrigins: (json['allowedOrigins'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? const ['*'],
    );
  }

  @override
  String toString() {
    return 'HttpServerConfig(isEnabled: $isEnabled, host: $host, port: $port, corsEnabled: $corsEnabled)';
  }
}
