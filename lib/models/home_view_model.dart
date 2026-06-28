import 'package:flutter/material.dart';

class BloquePresupuesto {
  final String nombre;
  final String emoji;
  final double max;
  final double gasto;
  final Color color;

  const BloquePresupuesto({
    required this.nombre,
    required this.emoji,
    required this.max,
    required this.gasto,
    required this.color,
  });

  double get porcentaje => (gasto / max).clamp(0.0, 1.0);
  double get saldo => max - gasto;
  bool get excedido => gasto > max;
  bool get enRiesgo => porcentaje >= 0.85 && !excedido;

  String get mensaje {
    if (excedido) return 'Debes mejorar';
    if (enRiesgo) return 'Ten cuidado';
    return 'Excelente';
  }

  Color get mensajeColor {
    if (excedido) return const Color(0xFFFF4757);
    if (enRiesgo) return const Color(0xFFF5A623);
    return const Color(0xFF00D4AA);
  }
}

class HomeViewModel {
  final double ingresosMes;
  final double gastosMes;
  final double disponibleHoy;
  final double sinAsignar;
  final int diasRestantes;
  final List<BloquePresupuesto> bloques;
  final List<MovimientoReciente> movimientos;

  const HomeViewModel({
    required this.ingresosMes,
    required this.gastosMes,
    required this.disponibleHoy,
    required this.sinAsignar,
    required this.diasRestantes,
    required this.bloques,
    required this.movimientos,
  });

  double get balance => ingresosMes - gastosMes;

  EstadoSemaforo get estadoSemaforo {
    if (sinAsignar == 0) return EstadoSemaforo.perfecto;
    if (sinAsignar > 0) return EstadoSemaforo.flotando;
    return EstadoSemaforo.negativo;
  }
}

enum EstadoSemaforo { perfecto, flotando, negativo }

class MovimientoReciente {
  final String emoji;
  final String nombre;
  final String subtitulo;
  final double monto;
  final bool esTransferencia;

  const MovimientoReciente({
    required this.emoji,
    required this.nombre,
    required this.subtitulo,
    required this.monto,
    this.esTransferencia = false,
  });
}
