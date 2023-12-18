
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
//import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:incitec/Constants/colors.dart';
import 'package:incitec/Views/reportes_view.dart';
import 'package:incitec/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //Ocultamos la barra de navegacion y la barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Palette.blueTec,
        useMaterial3: false,
      ),
      home: const ReportesPage(cat: 'Energía Eléctrica', path:  'assets/energia.jpg')
      // home: const LoginPage()

      // home: InfoReportesPage(
      //   cat: 'Energía Eléctrica', 
      //   path:  'energia',
      //   descripcion: 'Los contactos del salon 5 estan sacando chispas', 
      //   estado: "Pendiente", 
      //   fecha: DateTime.now().toString(), 
      //   imagen: 'https://firebasestorage.googleapis.com/v0/b/incitec-5ebe0.appspot.com/o/reportes%2Fbeaeeb4f-1d53-4d86-94b5-44bb9388ebbe8341832633978430195.jpg?alt=media&token=98b870e3-56ce-4702-b11d-c575d19c0a0d', 
      //   nombreCompleto: 'ULISES SHIE SOTELO CHOPIN', 
      //   ubicacion: 'Edificio 5',
      //   carrera: 'Ing. en Sistemas Computacionales',
      //   numeroControl: '19091435',
      //   incidencia: 'Foco prendido',
      // )

      // home: const Prueba()
      //  home: const CategoriasPage(),
      //home: const Graphics(),
      // home: const GraficosPage(),
      // home: const SubirReporte(),
    );
  }
}