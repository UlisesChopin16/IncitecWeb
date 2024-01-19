import 'dart:typed_data';
import 'package:get/get.dart';

import 'package:incitec/Models/reportes_model.dart';
import 'package:incitec/Views/principal_view.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseServicesInciTec extends GetxController {

  // MAGR581021G56

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  var getDataReportes = GetDataModelReportes(reportes: []).obs;
  var filtroReportes = <Reporte>[].obs;

  var listaPorcentajes = <double>[].obs;

  var datosAlumno = <String,dynamic>{}.obs;
  var datosEmpleado = <String,dynamic>{}.obs;
  var datosCarrera = <String,dynamic>{}.obs;

  var pdf = Uint8List(0).obs;

  var loading = false.obs;
  var verificarTelefono = false.obs;
  var estudiante = false.obs;
  var administrativo = false.obs;
  var jefe = false.obs;

  var usuario = ''.obs;
  var nombre = ''.obs;
  var email = ''.obs;
  var mensajeError = ''.obs;
  var carrera = ''.obs;
  var periodo = ''.obs;
  var periodoIngreso = ''.obs;
  var telefono = ''.obs;
  var iniciales = ''.obs;
  var estado = 'Pendiente'.obs;
  var permisos = <String>[].obs;

  var activo = false.obs;




  User? user;

  snackBarSucces({required String message, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      )
    );
  }
  

  snackBarError({required String message, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      )
    );
  }

  snackBarPending({required String message, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      )
    );
  }

  
  Future<void> loginUsingEmailPassword({required String rfc, required String password, required BuildContext context}) async{
    loading.value = true;
    try{
      email.value = '$rfc@tecnamex.com';
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email.value, password: password);
      user = userCredential.user;
      if(user == null){
        loading.value = false;
        if(!context.mounted) return;
        snackBarError(message: 'Hubo un error en el usuario o contraseña', context: context);
        return;
      }
      else{
        usuario.value = rfc;
        loading.value = false;
        if(!context.mounted) return;
        await obtenerDatosEmpleado(rfc: rfc.toUpperCase(), context: context);
        if(!activo.value){
          loading.value = false;
          if(!context.mounted) return;
          snackBarError(message: 'Lo sentimos, no puedes ingresar al sistema', context: context);
          return;
        }
        if(estudiante.value){
          loading.value = false;
          if(!context.mounted) return;
          snackBarError(message: 'Lo sentimos, no puedes ingresar al sistema', context: context);
          return;
        }
        if(!context.mounted) return;
        snackBarSucces(message: 'Bienvenido', context: context);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const CategoriasPage()));
      }
    }catch(e){
      loading.value = false;
      if(!context.mounted) return;
      snackBarError(message: 'Algo salio mal, por favor intente de nuevo más tarde', context: context);
    }
  }

  Future<void> obtenerDatosEmpleado({required String rfc, required BuildContext context}) async{
    String collection = '/itz/tecnamex/';
    loading.value = true;
    try{
      collection += 'usuarios';
      activo.value = false;
      estudiante.value = false;
      administrativo.value = false;
      jefe.value = false;
      
      DocumentSnapshot ds = await firestore.collection(collection).doc(rfc).get();
      datosEmpleado.value = ds.data() as Map<String, dynamic>;
      activo.value = datosEmpleado['activo'];
      if(!activo.value){
        return;
      }
      permisos.value = datosEmpleado['permisos'].cast<String>();
      for(int i = 0; i < permisos.length; i++){
        if(permisos[i] == 'Estudiante' || permisos[i] == 'Docente' || permisos[i] == 'Administrativo'){
          estudiante.value = true;
          return;
        }
        if(permisos[i] == 'JefeRecursosMateriales'){
          jefe.value = true;
          break;
        }
        if(permisos[i] == 'AdministrativoRecursosMateriales'){
          administrativo.value = true;
          break;
        }
        
      }
      collection = '/itz/tecnamex/';
      collection += 'empleados';
      QuerySnapshot querySnapshot = await firestore.collection(collection).where('rfc',isEqualTo: rfc).get();
      datosEmpleado.value = querySnapshot.docs[0].data() as Map<String, dynamic>;
      obtenerIniciales(datosEmpleado['apellidosNombre'].toString());
      email.value = datosEmpleado['correoInstitucional'].toString();
      nombre.value = datosEmpleado['apellidosNombre'];
      loading.value = false;
    }catch(e){
      loading.value = false;
      if(!context.mounted) return;
      snackBarError(message: 'Algo salio mal, por favor intente de nuevo más tarde', context: context);
    }
  }

  Future<void> getReportes({required String categoria}) async {
    loading.value = true;
    
    Map<String, List<Map<String, dynamic>>> resultMap = {};

    List<Map<String, dynamic>> reportesList = [];

    CollectionReference reportesRef = firestore.collection('reportes');

    QuerySnapshot querySnapshot = await reportesRef.where('categoria',isEqualTo: categoria).get();

    querySnapshot.docs.forEach((element) {
      reportesList.add(element.data() as Map<String, dynamic>);
    });

    resultMap['Reportes'] = reportesList;
    getDataReportes.value = GetDataModelReportes.fromJson(resultMap);
    getDataReportes.value.ordenarReportes(OrdenReportes.pendiente);
    filtroReportes.value = getDataReportes.value.reportes;
    loading.value = false;
  }

  // metodo para obtener todos los reportes por edificio
  Future<void> getReportesEdificio({required String edificio}) async {
    loading.value = true;
    
    Map<String, List<Map<String, dynamic>>> resultMap = {};

    List<Map<String, dynamic>> reportesList = [];

    CollectionReference reportesRef = firestore.collection('reportes');

    QuerySnapshot querySnapshot = await reportesRef.where('ubicacion',isEqualTo: edificio).get();

    querySnapshot.docs.forEach((element) {
      reportesList.add(element.data() as Map<String, dynamic>);
    });

    resultMap['Reportes'] = reportesList;
    getDataReportes.value = GetDataModelReportes.fromJson(resultMap);

    listaPorcentajes.value = getPorcentajes();

    loading.value = false;
  }

  // metodo para obtener todos los reportes
  Future<void> getReportesTotales() async {
    loading.value = true;
    
    Map<String, List<Map<String, dynamic>>> resultMap = {};

    List<Map<String, dynamic>> reportesList = [];

    CollectionReference reportesRef = firestore.collection('reportes');

    QuerySnapshot querySnapshot = await reportesRef.get();

    querySnapshot.docs.forEach((element) {
      reportesList.add(element.data() as Map<String, dynamic>);
    });

    resultMap['Reportes'] = reportesList;
    getDataReportes.value = GetDataModelReportes.fromJson(resultMap);

    listaPorcentajes.value = getPorcentajes();

    loading.value = false;
  }

  // metodo para obtener el porcentaje de reportes por categoria, son 4 categorias y lo sacaremos con el largo de cada lista
  List<double> getPorcentajes(){
    // primero obtenemos el largo de la lista
    int largo = getDataReportes.value.reportes.length;
    // luego obtenemos el porcentaje de cada categoria: Agua, Energía Eléctrica, Desechos Peligrosos, Otros
    double porcentajeAgua = (getDataReportes.value.reportes.where((element) => element.categoria == 'Agua').length / largo) * 100;
    double porcentajeEnergia = (getDataReportes.value.reportes.where((element) => element.categoria == 'Energía Eléctrica').length / largo) * 100;
    double porcentajeDesechos = (getDataReportes.value.reportes.where((element) => element.categoria == 'Desechos Peligrosos').length / largo) * 100;
    double porcentajeOtros = (getDataReportes.value.reportes.where((element) => element.categoria == 'Otros').length / largo) * 100;

    if(porcentajeAgua.isNaN){
      porcentajeAgua = 0;
    }
    if(porcentajeEnergia.isNaN){
      porcentajeEnergia = 0;
    }
    if(porcentajeDesechos.isNaN){
      porcentajeDesechos = 0;
    }
    if(porcentajeOtros.isNaN){
      porcentajeOtros = 0;
    }
    // retornamos una lista con los porcentajes
    return [porcentajeAgua, porcentajeEnergia, porcentajeDesechos, porcentajeOtros];
  }

  // Metodo para actualizar el estado de un reporte
  Future<void> updateReporte({required int index,required String id, required String responsable, required String nuevoEstado, required BuildContext context}) async {
    loading.value = true;
    try{
      // Primero checamos que el reporte tenga el estado mismo estado, si el estado es el mismo no se actualiza
      String estado = getDataReportes.value.reportes[index].estado;
      if(estado == nuevoEstado || estado == 'Revisado'){
        loading.value = false;
        return;
      }
      await firestore.collection('reportes').doc(id).update({'estado': nuevoEstado, 'revisadoPor': responsable});

      loading.value = false;
      if(!context.mounted) return;
      if(nuevoEstado == 'En revisión'){
        snackBarPending(message: 'Reporte en revisión', context: context);
      }else if(nuevoEstado == 'Revisado'){
        snackBarSucces(message: 'Reporte revisado', context: context);
      }
    }catch(e){
      print(e);
      loading.value = false;
      if(!context.mounted) return;
      snackBarError(message: 'Algo salio mal, por favor intente de nuevo más tarde', context: context);
    }
  }

  // Metodo para subir un archivo pdf a firebase storage con Uint8List
  Future<void> subirArchivo({required Uint8List data,required String nombre,required BuildContext context}) async {
    try {
      loading.value = true;
      final Reference ref = storage.ref().child('reportesPDF').child(nombre);
      final UploadTask uploadTask = ref.putData(data);

      await uploadTask.whenComplete(() => true);
      loading.value = false;
    } catch (e) {
      mensajeError.value = 'Algo salio mal, porfavor intente de nuevo más tarde';
      if(!context.mounted) return;
      snackBarError(message: mensajeError.value, context: context);
      loading.value = false;
    }
  }

  obtenerIniciales(String nombre){
    String nombreCompleto = nombre;
    List<String> nombreCompletoSeparado = nombreCompleto.split(' ');
    int largo = nombreCompletoSeparado.length;

    // Inicial del apellido paterno
    String letraA = nombreCompletoSeparado[0].substring(0, 1);
    // Inicial del nombre
    String letraB = '';
    if (largo == 4) {
      letraB = nombreCompletoSeparado[(nombreCompletoSeparado.length - 2)].substring(0, 1);
    }else if(largo == 3){
      letraB = nombreCompletoSeparado[(nombreCompletoSeparado.length - 1)].substring(0, 1);
    }else if(largo == 2){
      letraB = nombreCompletoSeparado[(nombreCompletoSeparado.length - 1)].substring(0, 1);
    }
    
    // Iniciales completas ej: US
    iniciales.value = letraB + letraA;
  }

  void buscarReporte(String query){
    filtroReportes.value = getDataReportes.value.reportes.where(
      (reporte) {
        return reporte.numeroControl.toLowerCase().contains(query.toLowerCase()) || 
        reporte.revisadoPor.toLowerCase().contains(query.toLowerCase());
      }
    ).toList();
  }
}


