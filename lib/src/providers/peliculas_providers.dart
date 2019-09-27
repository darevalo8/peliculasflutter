import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/pelicula_model.dart';
class PeliculasProvider{

  String _apikey = '08cff841ebe391d430abe838f7af31e3';
  String _url = 'api.themoviedb.org';
  String _languaje = 'es-MX';
  int _popularesPage = 1;
  bool _cargando = false;
  List<Pelicula> _populares = new List();
  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink =>_popularesStreamController.sink.add;
  Stream<List<Pelicula>>get popularesStream => _popularesStreamController.stream;

  void disposeStreams(){
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url)async{
    final respuesta = await http.get(url);
    final decodeData = json.decode(respuesta.body);
    final peliculas = Peliculas.fromJsonList(decodeData['results']);
    return peliculas.items;

  }
  Future<List<Pelicula>> getEnCines()async{
    final url = Uri.https(_url, '3/movie/now_playing',{
      'api_key': _apikey,
      'languaje': _languaje
    });
    return await this._procesarRespuesta(url);
    // final respuesta = await http.get(url);
    // print(respuesta);
    // final decodeData = json.decode(respuesta.body);
    // print(decodeData['results']);
    // final peliculas = Peliculas.fromJsonList(decodeData['results']);
    // print(peliculas.items[1].title);
    // return peliculas.items;
  }
  Future<List<Pelicula>> getPopulares()async{
    if(_cargando){
      return [];
    }
    _cargando = true;
    this._popularesPage++;
    final url = Uri.https(_url, '3/movie/popular',{
      'api_key': _apikey,
      'languaje': _languaje,
      'page': _popularesPage.toString()
    });
    final respuesta = await this._procesarRespuesta(url);
    _populares.addAll(respuesta);
    popularesSink(_populares);
    _cargando = false;
    return respuesta;
    
  }
}