import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/printer_repository_impl.dart';
import 'domain/usecases/printer_usecase.dart';
import 'presentation/providers/printer_provider.dart';
import 'presentation/pages/printer_config_page.dart';

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
      ],
      child: MaterialApp(
        title: 'SellPOS - ConfiguraciÃ³n de Impresora',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Segoe UI',
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Segoe UI',
