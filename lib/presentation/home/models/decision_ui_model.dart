import 'package:flutter/material.dart';

/// Modelo de presentación de una decisión financiera.
///
/// Contiene únicamente lo que la UI necesita para renderizar:
/// nada de tipos del Core, nada de lógica financiera.
/// Se construye exclusivamente a través de DecisionUiMapper.
class DecisionUiModel {
  /// Identificador de la decisión de origen (para trazabilidad).
  final String id;

  /// Icono según el tipo semántico de la decisión.
  final String emoji;

  /// Texto corto y directo.
  final String title;

  /// Contexto explicativo.
  final String context;

  /// Color de acento según prioridad.
  final Color color;

  /// Texto del botón de acción principal.
  /// Null cuando la decisión es solo informativa (NoAction).
  final String? actionLabel;

  /// Orden de presentación derivado de la prioridad
  /// (menor = más prioritaria). La UI solo ordena por este
  /// número, sin conocer el concepto de prioridad del Core.
  final int sortOrder;

  const DecisionUiModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.context,
    required this.color,
    required this.actionLabel,
    required this.sortOrder,
  });
}
