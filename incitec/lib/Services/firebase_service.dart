import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:incitec/Models/reportes_model.dart';
import 'package:incitec/Views/principal_view.dart';

class FirebaseServicesInciTec extends GetxController {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  var getDataReportes = GetDataModelReportes(reportes: []).obs;

  var datosAlumno = <String,dynamic>{}.obs;
  var datosCarrera = <String,dynamic>{}.obs;

  var pdf = Uint8List(0).obs;

  var loading = false.obs;
  var verificarTelefono = false.obs;

  var usuario = ''.obs;
  var nombre = ''.obs;
  var email = ''.obs;
  var mensajeError = ''.obs;
  var carrera = ''.obs;
  var periodo = ''.obs;
  var periodoIngreso = ''.obs;
  var telefono = ''.obs;
  var estado = 'Pendiente'.obs;

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

  
  Future<void> loginUsingEmailPassword({required String numeroControl, required String password, required BuildContext context}) async{
    loading.value = true;
    try{
      email.value = '$numeroControl@tecnamex.com';
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email.value, password: password);
      user = userCredential.user;
      if(user != null){
        usuario.value = numeroControl;
        loading.value = false;
        if(!context.mounted) return;
        snackBarSucces(message: 'Bienvenido', context: context);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const CategoriasPage()));

      }else{
        loading.value = false;
        if(!context.mounted) return;
        snackBarError(message: 'Error al iniciar sesión', context: context);
      }
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
    loading.value = false;
  }

  // Metodo para actualizar el estado de un reporte
  Future<void> updateReporte({required int index,required String id, required String nuevoEstado, required BuildContext context}) async {
    loading.value = true;
    try{
      // Primero checamos que el reporte tenga el estado mismo estado, si el estado es el mismo no se actualiza
      String estado = getDataReportes.value.reportes[index].estado;
      if(estado == nuevoEstado || estado == 'Revisado'){
        loading.value = false;
        return;
      }
      await firestore.collection('reportes').doc(id).update({'estado': nuevoEstado});

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
  
}


