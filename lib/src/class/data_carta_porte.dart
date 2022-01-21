class CartaPorteFoto {
  final int clave;
  final double? latitud;
  final double longitud;
  final String fechaUpdate;
  final String operador;
  final String ruta;
  final String texto;

  CartaPorteFoto(
      {required this.clave,
      required this.fechaUpdate,
      required this.latitud,
      required this.longitud,
      required this.operador,
      required this.ruta,
      required this.texto});

  factory CartaPorteFoto.fromJson(Map<String, dynamic> json) {
    return CartaPorteFoto(
      clave: json['Clave'],
      latitud: json['Latitud'],
      longitud: json['Longitud'],
      fechaUpdate: json['FechaUpdate'],
      operador: json['Operador'],
      ruta: json['Ruta'],
      texto: json['Texto'],
    );
  }
}
