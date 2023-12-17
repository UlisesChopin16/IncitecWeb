import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incitec/Services/firebase_service.dart';

class SubirReporte extends StatefulWidget {
  const SubirReporte({super.key,});

  @override
  State<SubirReporte> createState() => _SubirReporteState();
}

class _SubirReporteState extends State<SubirReporte> {

  final servicios = Get.put(FirebaseServicesInciTec());

  Uint8List selectedImage = Uint8List(0);
  File? imagen;
  final picker = ImagePicker();
  double w = 0;
  double h = 0;

  resolucion(){
    setState(() {
      w = MediaQuery.of(context).size.width;
      h = MediaQuery.of(context).size.height;
    });
  }

  Future selImagen(op) async{

    var pickedFile;

    if(op == 1){
      pickedFile == await picker.pickImage(source: ImageSource.camera).then((value) {
        if (value != null) {
          setState(() {
            imagen = File(value.path);
            selectedImage = imagen!.readAsBytesSync();
          });
        }else{
        }
      });
    }else{
      pickedFile == await picker.pickImage(source: ImageSource.gallery).then((value) {
        if (value != null) {
          setState(() {
            imagen = File(value.path);
            selectedImage = imagen!.readAsBytesSync();
          });
        }else{
        }
      });
    }
    if(!context.mounted)return;
    Navigator.of(context).pop();
  }

  opciones(context) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  selImagen(1);
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(width: 1, color: Colors.grey))),
                  child: const Row(
                    children:  [
                      Expanded(
                        child: Text(
                          'Tomar una foto',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.camera_alt, color: Colors.blue)
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  selImagen(2);
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Seleccionar una foto',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.image, color: Colors.blue)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  final _formKey = GlobalKey<FormState>(); 

  String categoria = '';
  String incidencia = '';
  String descripcion = '';
  String edificios = '';


  TextStyle textoNormal(double sizet) {
    return TextStyle(
      color: Colors.black,
      fontSize: sizet,
      height: 1.5,
    );
  }

  void categoriasOnChanged(dynamic selectedValue) {
    setState(() {
      categoria = selectedValue!;
    });
  }

  void incidenciaOnChanged(dynamic selectedValue) {
    setState(() {
      incidencia = selectedValue!;
    });
  }

  void edificiosOnChanged(dynamic selectedValue) {
    setState(() {
      edificios = selectedValue!;
    });
  }

  void descripcionOnChanged(dynamic selectedValue) {
    setState(() {
      descripcion = selectedValue!;
    });
  }

  String? edificiosValidator(dynamic value){
    if (edificios.isEmpty || edificios.trim() == '') {
      return 'Campo obligatorio *';
    }
    return null;
  }

  String? categoriaValidator(dynamic value){
    if (categoria.isEmpty || categoria.trim() == '') {
      return 'Campo obligatorio *';
    }
    return null;
  }

  String? incidenciaValidator(dynamic value){
    if (incidencia.isEmpty || incidencia.trim() == '') {
      return 'Campo obligatorio *';
    }
    return null;
  }

  String? descripcionValidator(dynamic value){
    if (descripcion.isEmpty || descripcion.trim() == '') {
      return 'Campo obligatorio *';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    resolucion();
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Subir Reporte'),
          ),
          body: Center(
            child: !servicios.loading.value ? Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: w > 500 ? 500 : w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 20,),
                        dropEdifcios(),
                        const SizedBox(height: 20,),
                        dropCategoria(),
                        const SizedBox(height: 20,),
                        dropIncidencias(),
                        const SizedBox(height: 20,),
                        textDescripcion(),
                        const SizedBox(height: 20,),
                        const Text('Fotos'),
                        botonFoto(),
                        const SizedBox(height: 30,),
                        // imagen == null ? Center() : Image.file(imagen!),
                        const SizedBox(height: 20,),
                        botonSubirReporte(),
                        const SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ),
              ),
            ): const CircularProgressIndicator(),
          )
        );
      },
    );
  }

  dropCategoria(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoria'),
        DropdownButtonFormField(
          items: const [
            DropdownMenuItem(
              value: 'Energía Eléctrica',
              child: Text('Energía Eléctrica'),
            ),
            DropdownMenuItem(
              value: 'Agua',
              child: Text('Agua'),
            ),
            DropdownMenuItem(
              value: 'Sustancias peligrosas',
              child: Text('Sustancias peligrosas'),
            ),
            DropdownMenuItem(
              value: 'Otros',
              child: Text('Otros'),
            ),
          ], 
          // declaramos un validator para validar el campo
          validator: categoriaValidator,
          
          // declaramos un onChanged para obtener el valor seleccionado
          onChanged: categoriasOnChanged ,

          style: textoNormal(18),
          
          // cambiamos el color del dropdown
          dropdownColor: Colors.white,
          
          // cambiamos el icono
          icon: Icon(Icons.keyboard_arrow_down_outlined,),
          isExpanded: true,
          
          // cambiamos el tamaño del icono
          iconSize: 32,
          
          // cambiamos el color del dropdown
          

          // Le damos un estilo al dropdown
          decoration: InputDecoration(
            // ponemos el fondo del dropdown transparente
            filled: true,
            
            // le damos un color al fondo del dropdown
            fillColor:Colors.grey[300],
            
            // Le damos un icono al dropdown
            hintText: 'Energía Electrica',
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none
            )
          ),
        ),
      ],
    );
  }
 
  dropIncidencias(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Incidencia'),
        DropdownButtonFormField(
          items: const [
            DropdownMenuItem(
              value: 'Foco prendido en el día',
              child: Text('Foco prendido en el día'),
            ),
            DropdownMenuItem(
              value: 'Aire acondicionado prendido en el día en salones vacios',
              child: Text('Aire acondicionado prendido en el día en salones vacios'),
            ),
            DropdownMenuItem(
              value: 'Desperdicio de agua',
              child: Text('Desperdicio de agua'),
            ),
            DropdownMenuItem(
              value: 'Manguera de gas rota',
              child: Text('Manguera de gas rota'),
            ),
            DropdownMenuItem(
              value: 'Falso contacto',
              child: Text('Falso contacto'),
            ),
            DropdownMenuItem(
              value: 'Computadora prendida en el día en salones vacios',
              child: Text('Computadora prendida en el día en salones vacios'),
            ),
            DropdownMenuItem(
              value: 'Otros',
              child: Text('Otros'),
            ),

          ], 
          onChanged: incidenciaOnChanged,
          validator: incidenciaValidator,
          style: textoNormal(18),
          dropdownColor: Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_outlined,),
          isExpanded: true,
          iconSize: 32,
          decoration: InputDecoration(
            filled: true,
            fillColor:Colors.grey[300],
            hintText: 'Foco prendido en el día',
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none
            )
          ),
        ),
      ],
    );
  }
  
  dropEdifcios(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Edificio'),
        DropdownButtonFormField(
          items: const [
            DropdownMenuItem(
              value: 'Edificio 1',
              child: Text('Edificio 1'),
            ),
            DropdownMenuItem(
              value: 'Edificio 2',
              child: Text('Edificio 2'),
            ),
            DropdownMenuItem(
              value: 'Edificio 3',
              child: Text('Edificio 3'),
            ),
            DropdownMenuItem(
              value: 'Edificio 4',
              child: Text('Edificio 4'),
            ),
            DropdownMenuItem(
              value: 'Edificio 5',
              child: Text('Edificio 5'),
            ),
            DropdownMenuItem(
              value: 'Edificio 6',
              child: Text('Edificio 6'),
            ),
            DropdownMenuItem(
              value: 'Edificio 7',
              child: Text('Edificio 7'),
            ),
            DropdownMenuItem(
              value: 'Edificio 8',
              child: Text('Edificio 8'),
            ),
            DropdownMenuItem(
              value: 'Edificio 9',
              child: Text('Edificio 9'),
            ),
            DropdownMenuItem(
              value: 'Edificio 10',
              child: Text('Edificio 10'),
            ),
          ], 
          onChanged: edificiosOnChanged,
          validator: edificiosValidator,
          style: textoNormal(18),
          dropdownColor: Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_outlined,),
          isExpanded: true,
          iconSize: 32,
          decoration: InputDecoration(
            filled: true,
            fillColor:Colors.grey[300],
            hintText: 'Edificio 1',
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none
            )
          ),
        ),
      ],
    );
  }

  textDescripcion(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descripción'),
        TextFormField(
          style: textoNormal(18),
          onChanged: descripcionOnChanged,
          validator: descripcionValidator,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor:Colors.grey[300],
            hintText: 'El foco de la sala 1 esta prendido en el día',
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 2.0
              )
            )
          ),
        ),
      ],
    );
  }
  
  botonFoto(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300)
      ),
      onPressed: () {
        opciones(context);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          Text('Agregar Imagen',
            style: TextStyle(
              color: Colors.black.withOpacity(0.50), 
              fontWeight: FontWeight.bold,
              fontSize: 30
            ),
          ),
          const SizedBox(height: 20,),
          if(imagen != null) 
            Image.memory(
              selectedImage,
              width: 401,
              height: 313,
            )
          else
            Image.asset('assets/camara.png',
              color: Colors.black.withOpacity(0.50),
            ),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }

  botonSubirReporte(){
    return ElevatedButton(
      onPressed: () async {
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoriasPage()));
        if(_formKey.currentState!.validate()){

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subiendo Reporte')));

          // estampa de tiempo
          String data = await servicios.subirImagen(imagen!);
          if(data != ''){
            DateTime fecha = DateTime.now();
            bool data2 = await servicios.agregarReporte(
              descripcion: descripcion, 
              fecha: fecha,
              ubicacion: edificios, 
              estado: 'Pendiente', 
              imagen: data,
              categoria: categoria,
              nombreCompleto: servicios.email.value
            );
            if(!context.mounted)return;
            if(data2){
              servicios.snackBarSucces(message: 'Reporte subido correctamente', context: context);
              setState(() {
                imagen = null;
                descripcion = '';
                categoria = '';
                incidencia = '';
                edificios = '';
              });
            }else{
              servicios.snackBarError(message: 'Error al subir el reporte', context: context);
            }
          }else{
            if(!context.mounted)return;
            servicios.snackBarError(message: 'Error al subir la imagen', context: context);
          }
        }
        // Navigator.of(context).pop();
      }, 
      child: const Text('Subir Reporte')
    );
  }

}