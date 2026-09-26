-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 11: Pruebas de Carga y Rendimiento a Gran Escala
-- ARCHIVO: sql/08_volume_tests.sql
-- DESCRIPCIÓN: Inserción de datos sintéticos masivos mediante generate_series()
--              para evaluar el comportamiento del motor con 1,000, 10,000
--              y hasta 50,000 reservaciones y sus planes de ejecución.
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- ============================================================================
-- 1. PROCEDIMIENTO PARA GENERAR VOLUMEN SINTÉTICO CONTROLADO
-- ============================================================================

-- Creamos una función auxiliar para generar N reservaciones aleatorias con pagos y consumos
CREATE OR REPLACE PROCEDURE sp_generar_volumen_reservaciones(p_cantidad INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_cliente BIGINT;
    v_id_res BIGINT;
    v_fecha_in DATE;
    v_fecha_out DATE;
    v_noches INT;
    v_hab INT;
    v_total NUMERIC(12,2);
BEGIN
    RAISE NOTICE 'Iniciando generación de % reservaciones sintéticas...', p_cantidad;

    FOR i IN 1..p_cantidad LOOP
        -- Seleccionar cliente aleatorio entre los existentes (1 a 20)
        v_id_cliente := 1 + (floor(random() * 20)::INT);
        
        -- Fecha de entrada aleatoria en los últimos 365 días
        v_fecha_in := CURRENT_DATE - (floor(random() * 365)::INT);
        v_noches := 1 + (floor(random() * 7)::INT); -- Estancia de 1 a 7 noches
        v_fecha_out := v_fecha_in + v_noches;
        
        -- Habitación aleatoria entre las 19 activas
        v_hab := 1 + (floor(random() * 19)::INT);
        v_total := v_noches * 1000.00;

        -- Insertar reservación
        INSERT INTO reservaciones (id_cliente, fecha_reserva, fecha_entrada, fecha_salida, estado, total_estimado)
        VALUES (
            v_id_cliente, 
            v_fecha_in - INTERVAL '5 days', 
            v_fecha_in, 
            v_fecha_out, 
            CASE (floor(random() * 4)::INT)
                WHEN 0 THEN 'CONFIRMADA'
                WHEN 1 THEN 'EN_CURSO'
                WHEN 2 THEN 'CANCELADA'
                ELSE 'FINALIZADA'
            END,
            v_total
        ) RETURNING id_reservacion INTO v_id_res;

        -- Asignar habitación
        INSERT INTO reservacion_habitaciones (id_reservacion, id_habitacion, precio_noche)
        VALUES (v_id_res, v_hab, 1000.00);

        -- Insertar pago asociado (80% de probabilidad de tener pago)
        IF random() > 0.20 THEN
            INSERT INTO pagos (id_reservacion, fecha_pago, monto, metodo)
            VALUES (
                v_id_res, 
                v_fecha_in - INTERVAL '2 days', 
                v_total, 
                CASE (floor(random() * 3)::INT)
                    WHEN 0 THEN 'TARJETA'
                    WHEN 1 THEN 'TRANSFERENCIA'
                    ELSE 'EFECTIVO'
                END
            );
        END IF;

    END LOOP;

    RAISE NOTICE 'Generación completada exitosamente.';
END;
$$;


-- ============================================================================
-- 2. EJECUCIÓN DE PRUEBAS DE ESCALA
-- ============================================================================

-- Escala 1: Inyectar 1,000 reservaciones de prueba
-- CALL sp_generar_volumen_reservaciones(1000);

-- Escala 2: Inyectar 9,000 adicionales (Total acumulado: 10,000)
-- CALL sp_generar_volumen_reservaciones(9000);

-- Escala 3: Inyectar 40,000 adicionales (Total acumulado: 50,000)
-- CALL sp_generar_volumen_reservaciones(40000);


-- ============================================================================
-- 3. BENCHMARKING DE CONSULTAS CON EXPLAIN ANALYZE
-- Ejecutar estas consultas para comparar tiempos con 25 vs 1,000 vs 10,000+ filas
-- ============================================================================

-- Benchmark A: Consulta de ingresos por mes (Q05)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    TO_CHAR(p.fecha_pago, 'YYYY-MM') AS mes,
    SUM(p.monto) AS ingresos
FROM pagos p
GROUP BY TO_CHAR(p.fecha_pago, 'YYYY-MM');

-- Benchmark B: Consulta de balance y saldos pendientes (Q04)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    r.id_reservacion,
    r.total_estimado - COALESCE(SUM(p.monto), 0) AS saldo
FROM reservaciones r
LEFT JOIN pagos p ON r.id_reservacion = p.id_reservacion
GROUP BY r.id_reservacion, r.total_estimado
HAVING (r.total_estimado - COALESCE(SUM(p.monto), 0)) > 0;

-- Benchmark C: Disponibilidad de habitación con índice compuesto (Q10)
EXPLAIN (ANALYZE, BUFFERS)
SELECT rh.id_habitacion
FROM reservacion_habitaciones rh
INNER JOIN reservaciones r ON rh.id_reservacion = r.id_reservacion
WHERE r.estado IN ('CONFIRMADA', 'EN_CURSO')
  AND (r.fecha_entrada < '2026-11-20' AND r.fecha_salida > '2026-11-15');
