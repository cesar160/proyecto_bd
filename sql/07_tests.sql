-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 10: Suite de Pruebas Formales de Integridad
-- ARCHIVO: sql/07_tests.sql
-- DESCRIPCIÓN: Casos de prueba positivos (datos válidos) y negativos (violaciones
--              intencionales de restricciones) para certificar la robustez del motor.
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- ============================================================================
-- BLOQUE 1: PRUEBAS POSITIVAS (Operaciones Válidas)
-- ============================================================================

-- Limpieza previa para permitir re-ejecución idempotente de la suite de pruebas
DELETE FROM reservaciones WHERE id_cliente IN (SELECT id_cliente FROM clientes WHERE correo = 'huesped.valido@test.com');
DELETE FROM clientes WHERE correo = 'huesped.valido@test.com';

-- T01: Inserción de cliente válido
INSERT INTO clientes (nombre, apellido, correo, telefono)
VALUES ('Huésped', 'Válido', 'huesped.valido@test.com', '5511002200');

-- Verificación T01:
SELECT id_cliente, nombre, correo FROM clientes WHERE correo = 'huesped.valido@test.com';

-- T02: Inserción de reservación con fechas válidas (salida > entrada)
INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida, estado, total_estimado)
VALUES (
    (SELECT id_cliente FROM clientes WHERE correo = 'huesped.valido@test.com'),
    '2026-12-01',
    '2026-12-05',
    'CONFIRMADA',
    3000.00
);

-- Verificación T02:
SELECT id_reservacion, fecha_entrada, fecha_salida, estado
FROM reservaciones
WHERE id_cliente = (SELECT id_cliente FROM clientes WHERE correo = 'huesped.valido@test.com');


-- ============================================================================
-- BLOQUE 2: PRUEBAS NEGATIVAS (Deben ser rechazadas por PostgreSQL)
-- ============================================================================

-- T03 [RECHAZO]: Violación de UNIQUE en correo de clientes
-- RESULTADO ESPERADO: ERROR 23505 (unique_violation)
DO $$
BEGIN
    INSERT INTO clientes (nombre, apellido, correo) 
    VALUES ('Duplicado', 'Test', 'carlos.mendoza@email.com');
    RAISE EXCEPTION 'FALLO DE PRUEBA: PostgreSQL debió rechazar el correo duplicado.';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'ÉXITO T03: Restricción UNIQUE de correo funcionó correctamente.';
END $$;


-- T04 [RECHAZO]: Violación de Llave Foránea inexistente
-- RESULTADO ESPERADO: ERROR 23503 (foreign_key_violation)
DO $$
BEGIN
    INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida) 
    VALUES (999999, '2026-11-01', '2026-11-03');
    RAISE EXCEPTION 'FALLO DE PRUEBA: PostgreSQL debió rechazar el id_cliente inexistente.';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'ÉXITO T04: Restricción FOREIGN KEY de cliente funcionó correctamente.';
END $$;


-- T05 [RECHAZO]: Violación de CHECK en coherencia de fechas (salida <= entrada)
-- RESULTADO ESPERADO: ERROR 23514 (check_violation)
DO $$
BEGIN
    INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida) 
    VALUES (1, '2026-11-10', '2026-11-08');
    RAISE EXCEPTION 'FALLO DE PRUEBA: PostgreSQL debió rechazar fecha_salida < fecha_entrada.';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO T05: Restricción CHECK de fechas funcionó correctamente.';
END $$;


-- T06 [RECHAZO]: Violación de CHECK en monto de pago (monto <= 0)
-- RESULTADO ESPERADO: ERROR 23514 (check_violation)
DO $$
BEGIN
    INSERT INTO pagos (id_reservacion, monto, metodo) 
    VALUES (1, -150.00, 'EFECTIVO');
    RAISE EXCEPTION 'FALLO DE PRUEBA: PostgreSQL debió rechazar monto de pago negativo.';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO T06: Restricción CHECK de monto positivo funcionó correctamente.';
END $$;


-- T07 [RECHAZO]: Violación de CHECK en cantidad de consumo (cantidad = 0)
-- RESULTADO ESPERADO: ERROR 23514 (check_violation)
DO $$
BEGIN
    INSERT INTO consumos_servicio (id_reservacion, id_servicio, cantidad, precio_unitario) 
    VALUES (1, 1, 0, 180.00);
    RAISE EXCEPTION 'FALLO DE PRUEBA: PostgreSQL debió rechazar cantidad igual a cero.';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO T07: Restricción CHECK de cantidad positiva funcionó correctamente.';
END $$;


-- T08 [RECHAZO]: Violación de CHECK en método de pago no reconocido
-- RESULTADO ESPERADO: ERROR 23514 (check_violation)
DO $$
BEGIN
    INSERT INTO pagos (id_reservacion, monto, metodo) 
    VALUES (1, 500.00, 'CRIPTOMONEDA_BITCOIN');
    RAISE EXCEPTION 'FALLO DE PRUEBA: PostgreSQL debió rechazar método de pago no permitido.';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'ÉXITO T08: Restricción CHECK de método de pago funcionó correctamente.';
END $$;


-- ============================================================================
-- BLOQUE 3: PRUEBAS DE INTEGRIDAD REFERENCIAL Y BORRADO (ON DELETE RESTRICT)
-- ============================================================================

-- T09 [RECHAZO]: Intento de borrar cliente con historial de reservaciones
-- NOTA: Al violar ON DELETE RESTRICT, PostgreSQL lanza SQLSTATE 23001 (restrict_violation)
DO $$
BEGIN
    DELETE FROM clientes WHERE id_cliente = 1;
    RAISE EXCEPTION 'FALLO DE PRUEBA: No debe permitirse borrar un cliente con reservaciones históricas.';
EXCEPTION
    WHEN restrict_violation OR foreign_key_violation THEN
        RAISE NOTICE 'ÉXITO T09: Protección referencial RESTRICT protegió el historial del cliente.';
END $$;


-- ============================================================================
-- BLOQUE 4: PRUEBAS DE TRASLAPE DE FECHAS (ETAPA 8 DE LA GUÍA)
-- Reserva A existente: Habitación 101, del 10 al 15 de Noviembre
-- ============================================================================

-- Función anónima para simular y clasificar colisiones de fechas
DO $$
DECLARE
    -- Rango de reserva base A:
    a_entrada DATE := '2026-11-10';
    a_salida  DATE := '2026-11-15';
    
    -- Función de evaluación de conflicto
    -- Dos estancias chocan si (E1 < S2 AND S1 > E2)
    conflicto BOOLEAN;
BEGIN
    -- Caso 1: B (12 al 14) -> Debe haber conflicto
    conflicto := (a_entrada < '2026-11-14' AND a_salida > '2026-11-12');
    IF NOT conflicto THEN RAISE EXCEPTION 'FALLO CASO 1: Debió detectar conflicto.'; END IF;
    RAISE NOTICE 'Caso 1 (12 al 14 dentro de 10 al 15): CONFLICTO DETECTADO CORRECTAMENTE';

    -- Caso 2: B (08 al 11) -> Debe haber conflicto (se traslapan el 10)
    conflicto := (a_entrada < '2026-11-11' AND a_salida > '2026-11-08');
    IF NOT conflicto THEN RAISE EXCEPTION 'FALLO CASO 2: Debió detectar conflicto.'; END IF;
    RAISE NOTICE 'Caso 2 (08 al 11 traslapa 10 al 15): CONFLICTO DETECTADO CORRECTAMENTE';

    -- Caso 3: B (14 al 18) -> Debe haber conflicto (se traslapan el 14)
    conflicto := (a_entrada < '2026-11-18' AND a_salida > '2026-11-14');
    IF NOT conflicto THEN RAISE EXCEPTION 'FALLO CASO 3: Debió detectar conflicto.'; END IF;
    RAISE NOTICE 'Caso 3 (14 al 18 traslapa 10 al 15): CONFLICTO DETECTADO CORRECTAMENTE';

    -- Caso 4: B (15 al 20) -> NO hay conflicto (Huésped A sale el 15 al mediodía, Huésped B entra el 15)
    conflicto := (a_entrada < '2026-11-20' AND a_salida > '2026-11-15');
    IF conflicto THEN RAISE EXCEPTION 'FALLO CASO 4: Salida = Entrada no debe ser conflicto.'; END IF;
    RAISE NOTICE 'Caso 4 (15 al 20 consecutivo a 10 al 15): DISPONIBLE (SIN CONFLICTO)';

    -- Caso 5: B (16 al 20) -> Completamente fuera de rango
    conflicto := (a_entrada < '2026-11-20' AND a_salida > '2026-11-16');
    IF conflicto THEN RAISE EXCEPTION 'FALLO CASO 5: No debe haber conflicto.'; END IF;
    RAISE NOTICE 'Caso 5 (16 al 20 posterior a 10 al 15): DISPONIBLE (SIN CONFLICTO)';
END $$;
