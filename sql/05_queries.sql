-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 7 Y 8: Consultas de Negocio y Control de Traslapes
-- ARCHIVO: sql/05_queries.sql
-- DESCRIPCIÓN: Consultas multi-tabla complejas (JOINs, agrupaciones, cálculos de
--              saldos, ingresos y detección de disponibilidad/traslapes).
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- ============================================================================
-- Q01: Reservaciones realizadas por un cliente específico
-- ============================================================================
SELECT 
    c.id_cliente,
    c.nombre || ' ' || c.apellido AS cliente,
    c.correo,
    r.id_reservacion,
    r.fecha_entrada,
    r.fecha_salida,
    (r.fecha_salida - r.fecha_entrada) AS noches_estancia,
    r.estado,
    r.total_estimado
FROM reservaciones r
INNER JOIN clientes c ON r.id_cliente = c.id_cliente
WHERE c.id_cliente = 1
ORDER BY r.fecha_entrada DESC;


-- ============================================================================
-- Q02: Detalle de habitaciones asignadas a una reservación
-- (Cruza: reservaciones, reservacion_habitaciones, habitaciones, tipos_habitacion)
-- ============================================================================
SELECT 
    r.id_reservacion,
    r.fecha_entrada,
    r.fecha_salida,
    h.numero AS numero_habitacion,
    th.nombre AS tipo_habitacion,
    th.capacidad,
    rh.precio_noche AS tarifa_acordada
FROM reservaciones r
INNER JOIN reservacion_habitaciones rh ON r.id_reservacion = rh.id_reservacion
INNER JOIN habitaciones h ON rh.id_habitacion = h.id_habitacion
INNER JOIN tipos_habitacion th ON h.id_tipo = th.id_tipo
WHERE r.id_reservacion = 21 -- Ejemplo con reservación multi-habitación
ORDER BY h.numero;


-- ============================================================================
-- Q03: Total pagado por reservación (Agrupación y SUM)
-- ============================================================================
SELECT 
    r.id_reservacion,
    c.nombre || ' ' || c.apellido AS titular,
    r.total_estimado,
    COALESCE(SUM(p.monto), 0.00) AS total_pagado,
    COUNT(p.id_pago) AS numero_abonos
FROM reservaciones r
INNER JOIN clientes c ON r.id_cliente = c.id_cliente
LEFT JOIN pagos p ON r.id_reservacion = p.id_reservacion
GROUP BY r.id_reservacion, c.nombre, c.apellido, r.total_estimado
ORDER BY r.id_reservacion;


-- ============================================================================
-- Q04: Estado de cuenta y saldo pendiente por liquidar
-- Concepto: total_estimado - total_pagado
-- ============================================================================
SELECT 
    r.id_reservacion,
    c.nombre || ' ' || c.apellido AS cliente,
    r.estado,
    r.total_estimado,
    COALESCE(SUM(p.monto), 0.00) AS total_pagado,
    (r.total_estimado - COALESCE(SUM(p.monto), 0.00)) AS saldo_pendiente,
    CASE 
        WHEN (r.total_estimado - COALESCE(SUM(p.monto), 0.00)) <= 0 THEN 'LIQUIDADA'
        WHEN COALESCE(SUM(p.monto), 0.00) > 0 THEN 'ABONO_PARCIAL'
        ELSE 'SIN_PAGOS'
    END AS situacion_pago
FROM reservaciones r
INNER JOIN clientes c ON r.id_cliente = c.id_cliente
LEFT JOIN pagos p ON r.id_reservacion = p.id_reservacion
WHERE r.estado NOT IN ('CANCELADA')
GROUP BY r.id_reservacion, c.nombre, c.apellido, r.estado, r.total_estimado
ORDER BY saldo_pendiente DESC;


-- ============================================================================
-- Q05: Ingresos del hotel agrupados por mes y método de pago
-- ============================================================================
SELECT 
    TO_CHAR(p.fecha_pago, 'YYYY-MM') AS periodo_mes,
    p.metodo,
    COUNT(p.id_pago) AS total_transacciones,
    SUM(p.monto) AS total_ingresos
FROM pagos p
GROUP BY TO_CHAR(p.fecha_pago, 'YYYY-MM'), p.metodo
ORDER BY periodo_mes DESC, total_ingresos DESC;


-- ============================================================================
-- Q06: Habitaciones más solicitadas / utilizadas
-- ============================================================================
SELECT 
    h.numero,
    th.nombre AS categoria,
    h.piso,
    COUNT(rh.id_reservacion) AS veces_reservada,
    SUM(r.fecha_salida - r.fecha_entrada) AS total_noches_ocupada
FROM habitaciones h
INNER JOIN tipos_habitacion th ON h.id_tipo = th.id_tipo
LEFT JOIN reservacion_habitaciones rh ON h.id_habitacion = rh.id_habitacion
LEFT JOIN reservaciones r ON rh.id_reservacion = r.id_reservacion AND r.estado != 'CANCELADA'
GROUP BY h.id_habitacion, h.numero, th.nombre, h.piso
ORDER BY veces_reservada DESC, total_noches_ocupada DESC;


-- ============================================================================
-- Q07: Clientes más frecuentes (Top Huéspedes)
-- ============================================================================
SELECT 
    c.id_cliente,
    c.nombre || ' ' || c.apellido AS cliente,
    c.correo,
    COUNT(r.id_reservacion) AS total_reservaciones,
    SUM(r.total_estimado) AS derrama_total_estimada
FROM clientes c
INNER JOIN reservaciones r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido, c.correo
ORDER BY total_reservaciones DESC, derrama_total_estimada DESC
LIMIT 10;


-- ============================================================================
-- Q08: Servicios adicionales más consumidos y rentables
-- ============================================================================
SELECT 
    s.id_servicio,
    s.nombre AS servicio,
    s.precio AS precio_actual,
    COALESCE(SUM(cs.cantidad), 0) AS unidades_consumidas,
    COALESCE(SUM(cs.cantidad * cs.precio_unitario), 0.00) AS ingresos_generados
FROM servicios s
LEFT JOIN consumos_servicio cs ON s.id_servicio = cs.id_servicio
GROUP BY s.id_servicio, s.nombre, s.precio
ORDER BY unidades_consumidas DESC, ingresos_generados DESC;


-- ============================================================================
-- Q09: Reservaciones activas actualmente (CONFIRMADA o EN_CURSO)
-- ============================================================================
SELECT 
    r.id_reservacion,
    c.nombre || ' ' || c.apellido AS huesped,
    c.telefono,
    r.fecha_entrada,
    r.fecha_salida,
    r.estado,
    STRING_AGG(h.numero, ', ') AS habitaciones_asignadas
FROM reservaciones r
INNER JOIN clientes c ON r.id_cliente = c.id_cliente
INNER JOIN reservacion_habitaciones rh ON r.id_reservacion = rh.id_reservacion
INNER JOIN habitaciones h ON rh.id_habitacion = h.id_habitacion
WHERE r.estado IN ('CONFIRMADA', 'EN_CURSO')
GROUP BY r.id_reservacion, c.nombre, c.apellido, c.telefono, r.fecha_entrada, r.fecha_salida, r.estado
ORDER BY r.fecha_entrada ASC;


-- ============================================================================
-- Q10 (ETAPA 8): Consulta de Disponibilidad de Habitaciones entre dos fechas
-- ============================================================================
-- Regla hotelera de traslape:
-- Dos rangos [E1, S1) y [E2, S2) chocan si: E1 < S2 AND S1 > E2.
-- Si la salida de la existente coincide con la entrada de la nueva (S1 = E2),
-- NO es conflicto (el huésped sale al mediodía y el nuevo entra en la tarde).
-- Parámetros de prueba: Entrada = 2026-11-10, Salida = 2026-11-14
-- ============================================================================
SELECT 
    h.id_habitacion,
    h.numero,
    th.nombre AS tipo_habitacion,
    th.capacidad,
    th.precio_noche,
    h.piso
FROM habitaciones h
INNER JOIN tipos_habitacion th ON h.id_tipo = th.id_tipo
WHERE h.activa = TRUE
  AND h.id_habitacion NOT IN (
      -- Subconsulta: Habitaciones con reservaciones activas que se traslapan con el periodo
      SELECT rh.id_habitacion
      FROM reservacion_habitaciones rh
      INNER JOIN reservaciones r ON rh.id_reservacion = r.id_reservacion
      WHERE r.estado IN ('CONFIRMADA', 'EN_CURSO', 'PENDIENTE')
        AND (r.fecha_entrada < '2026-11-14' AND r.fecha_salida > '2026-11-10')
  )
ORDER BY h.piso, h.numero;


-- ============================================================================
-- CONSULTAS COMPLEMENTARIAS (SECCIÓN 12 DE LA GUÍA)
-- ============================================================================

-- Q11: Habitaciones temporalmente fuera de servicio (Inactivas)
SELECT id_habitacion, numero, piso, activa
FROM habitaciones
WHERE activa = FALSE;

-- Q12: Reservaciones canceladas y motivo/fecha
SELECT r.id_reservacion, c.nombre || ' ' || c.apellido AS cliente, r.fecha_reserva, r.total_estimado
FROM reservaciones r
INNER JOIN clientes c ON r.id_cliente = c.id_cliente
WHERE r.estado = 'CANCELADA';

-- Q13: Total consolidado por estancia (Alojamiento + Servicios adicionales)
SELECT 
    r.id_reservacion,
    c.nombre || ' ' || c.apellido AS cliente,
    r.total_estimado AS base_alojamiento,
    COALESCE(SUM(cs.cantidad * cs.precio_unitario), 0.00) AS total_servicios,
    (r.total_estimado + COALESCE(SUM(cs.cantidad * cs.precio_unitario), 0.00)) AS gran_total
FROM reservaciones r
INNER JOIN clientes c ON r.id_cliente = c.id_cliente
LEFT JOIN consumos_servicio cs ON r.id_reservacion = cs.id_reservacion
WHERE r.estado != 'CANCELADA'
GROUP BY r.id_reservacion, c.nombre, c.apellido, r.total_estimado
ORDER BY gran_total DESC;
