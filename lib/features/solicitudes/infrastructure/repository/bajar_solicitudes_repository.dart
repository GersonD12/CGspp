import 'package:calet/features/solicitudes/infrastructure/data/bajar_solicitudes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' show log;

@override
class BajarSolicitudesRepository {
  Future<List<BajarSolicitudes>> bajarSolicitudesPorUID(
    String uidUsuario,
  ) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('solicitudes')
          .doc(uidUsuario)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final List<BajarSolicitudes> solicitudes = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            solicitudes.add(BajarSolicitudes.fromFirestore(value, key));
          }
        });

        return solicitudes;
      }
      return [];
    } catch (e) {
      log('Error al bajar solicitudes: $e');
      return [];
    }
  }
}
