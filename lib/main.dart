import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/printer_repository_impl.dart';
import 'domain/usecases/printer_usecase.dart';
import 'presentation/providers/printer_provider.dart';
import 'presentation/providers/http_server_provider.dart';
import 'presentation/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => PrinterRepositoryImpl(),
          dispose: (_, repo) => repo.dispose(),
        ),
        ProxyProvider<PrinterRepositoryImpl, PrinterUseCase>(
          update: (_, repo, __) => PrinterUseCase(repo),
        ),
        ChangeNotifierProvider(
          create: (context) => PrinterProvider(
            context.read<PrinterUseCase>(),
          ),
        ),
        ChangeNotifierProxyProvider<PrinterProvider, HttpServerProvider>(
          create: (_) => HttpServerProvider(),
          update: (context, printerProvider, httpServerProvider) {
            httpServerProvider ??= HttpServerProvider();
            httpServerProvider.configurePrinterProvider(printerProvider);
            if (!httpServerProvider.isInitialized) {
              httpServerProvider.initialize();
            }
            return httpServerProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'SellPOS - Sistema de Impresoras',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Segoe UI',
          // Configuraciones adicionales de Material 3
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            elevation: 1,
            margin: EdgeInsets.zero,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Segoe UI',
          // Configuraciones adicionales de Material 3
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: const CardThemeData(
            elevation: 1,
            margin: EdgeInsets.zero,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const MainPage(),
      ),
    );
  }
}
