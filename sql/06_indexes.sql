-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 9: Optimización mediante Índices
-- ARCHIVO: sql/06_indexes.sql
-- DESCRIPCIÓN: Creación justificada de índices en llaves foráneas y columnas de
--              filtrado/rango frecuente, con comparativa mediante EXPLAIN ANALYZE.
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- NOTA TÉCNICA:
-- En PostgreSQL, las restricciones PRIMARY KEY y UNIQUE generan índices B-Tree
-- de forma automática. Por lo tanto, no se duplican índices sobre id_cliente,
-- id_reservacion, numero de habitacion, etc.

-- ----------------------------------------------------------------------------
-- 1. ÍNDICES SOBRE LLAVES FORÁNEAS (Mejora de JOINs frecuentes)
-- ----------------------------------------------------------------------------

-- Acelera la búsqueda de reservaciones por cliente (Q01, Q07)
CREATE INDEX IF NOT EXISTS idx_reservaciones_id_cliente
    ON reservaciones (id_cliente);

-- Acelera la búsqueda de pagos asociados a una reservación (Q03, Q04)
CREATE INDEX IF NOT EXISTS idx_pagos_id_reservacion
    ON pagos (id_reservacion);

-- Acelera la búsqueda inversa de habitaciones asignadas (Q02, Q06, Q10)
CREATE INDEX IF NOT EXISTS idx_res_hab_id_habitacion
    ON reservacion_habitaciones (id_habitacion);

-- Acelera el cruce de consumos por reservación
CREATE INDEX IF NOT EXISTS idx_consumos_id_reservacion
    ON consumos_servicio (id_reservacion);

-- Acelera el cruce de consumos por servicio
CREATE INDEX IF NOT EXISTS idx_consumos_id_servicio
    ON consumos_servicio (id_servicio);


-- ----------------------------------------------------------------------------
-- 2. ÍNDICES COMPUESTOS Y DE FILTRADO FRECUENTE
-- ----------------------------------------------------------------------------

-- Acelera el reporte financiero de ingresos agrupados por fecha_pago (Q05)
CREATE INDEX IF NOT EXISTS idx_pagos_fecha_pago
    ON pagos (fecha_pago);

-- Índice compuesto para la consulta crítica de disponibilidad y traslapes (Q10)
-- Permite indexar simultáneamente el estado y el rango de estancia
CREATE INDEX IF NOT EXISTS idx_reservaciones_fechas_estado
    ON reservaciones (fecha_entrada, fecha_salida, estado);


-- ============================================================================
-- PROTOCOLO DE EVALUACIÓN DE RENDIMIENTO (EXPLAIN ANALYZE)
-- ============================================================================
/*
PASO A: Consulta sin índice (o antes de crear idx_reservaciones_fechas_estado)
Ejecutar en DBeaver:

EXPLAIN ANALYZE
SELECT r.id_reservacion, r.fecha_entrada, r.fecha_salida
FROM reservaciones r
WHERE r.estado IN ('CONFIRMADA', 'EN_CURSO')
  AND r.fecha_entrada < '2026-11-14' 
  AND r.fecha_salida > '2026-11-10';

Registrar:
- Tipo de escaneo: Seq Scan (Escaneo secuencial completo de la tabla)
- Costo y tiempo de ejecución (Execution Time en ms)

---

PASO B: Consulta con índice activo
Ejecutar tras crear el índice:

EXPLAIN ANALYZE
SELECT r.id_reservacion, r.fecha_entrada, r.fecha_salida
FROM reservaciones r
WHERE r.estado IN ('CONFIRMADA', 'EN_CURSO')
  AND r.fecha_entrada < '2026-11-14' 
  AND r.fecha_salida > '2026-11-10';

Registrar:
- Tipo de escaneo: Index Scan o Bitmap Index Scan
- Reducción del tiempo de respuesta y de buffers procesados
*/
