
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Carmen, cadê você ?",
      home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool _serviceEnabled; //verifica o GPS (on/off)
  late PermissionStatus _permissionGranted; //verificar a permissão de acesso
  LocationData? _userLocation;
  String? address;

  Future<void> _getUserLocation() async {
    Location location = Location();

    //1. verificar se o serviço de localização está ativado
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    //2. solicitar a permissão para o app acessar a localização
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();

    Future<List<Geocoding.Placemark>> places;
    double? lat;
    double? lng;


    setState(() {
      _userLocation = _locationData;
      lat = _userLocation!.latitude;
      lng = _userLocation!.longitude;
      places = Geocoding.placemarkFromCoordinates(lat!, lng!,
          localeIdentifier: "pt_BR");
      places.then((value) {
        Geocoding.Placemark place = value[1];
        address = place.street; //nome da rua
        print(_locationData.accuracy); //acurácia da localização
      });
    });
  }

  @override
  Widget build(BuildContext context) {

     var markes = <Marker>[
        Marker(
          point: LatLng(-8.89074, -36.4966),
          builder: (context) => Icon(Icons.pin_drop,color: Colors.red,),),
        Marker(
            point:  LatLng(-7.89074, -38.4966),
            builder:  (context) => Icon(Icons.pin_drop,color: Colors.green,)),
        Marker(
            point:  LatLng(-6.89074, -35.4966),
            builder:  (context) => Icon(Icons.pin_drop,color: Colors.blue,)),
        Marker(
            point:  LatLng(-5.89074, -39.4966),
            builder:  (context) => Icon(Icons.pin_drop,color: Colors.deepPurple,)
            )
    ];
      
    List<Marker> construirMarkes() {
      var marker = <Marker>[];
      for(var i = 0;i<5;i++){
        marker = <Marker>[markes[i]];
      }
        
      return marker;  
    } 

    final points = <LatLng> [
       LatLng(-8.89074, -36.4966),
       LatLng(-7.89074, -38.4966),
       LatLng(-6.89074, -35.4966),
       LatLng(-5.89074, -39.4966),
    ];
        
      
    



    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: 
        Text("Onde está Carmen Sandiego?"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              
              child: Container(
                child: Column(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(-8.89074, -36.4966),
                          zoom: 6,
                        ),
                        layers: [

                          TileLayerOptions(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c']),
                              
                          MarkerLayerOptions(
                            
                          markers: [
                          markes[0],
                          markes[1],
                          markes[2],
                          markes[3] ],
                         
                          ),
                           PolylineLayerOptions(
                             polylineCulling: false,
                             polylines: [Polyline(
                               points: points,
                               color: Colors.black,
                             )],


                          ),


                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _getUserLocation,
                    child: Text('Carmen,cadê você?(Acessar informações dos locais)'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                        minimumSize: const Size.fromHeight(40)),
                  ),
                  Text(''),
                  
                  // Adicionar markes ao clicar 
                  ElevatedButton(
                    onPressed:construirMarkes,
                    child: Text('Ver Locais por onde Carmen passou(Mapeamento)'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                        minimumSize: const Size.fromHeight(40)),
                  ),
                  if (_userLocation != null)
                    Text(
                      'LAT: ${_userLocation!.latitude}, LNG: ${_userLocation!.longitude}' +
                          "\n" +
                          "Endereço: " +
                          address!,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


/*
    [RF01]: Ao menos quatro lugares devem ser escolhidos com os respectivos pontos de LatLng, sendo indicados em um mapa através de cores diferentes.
    [RF02]: Traçar uma linha entre os pontos indicando a trajetória (polyline) percorrida pela personagem do anime;
    [RF03]: Utilizar a biblioteca flutter_map_marker_popup para indicar o nome (ou latlng) do local quando o marcador for pressionado
*/