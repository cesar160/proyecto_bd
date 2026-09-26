-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 14: Script de Limpieza y Recreación Completa (Teardown)
-- ARCHIVO: sql/09_cleanup.sql
-- DESCRIPCIÓN: Eliminación ordenada de todos los objetos de la base de datos
--              para permitir reconstruir el sistema de manera 100% determinística.
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- Desactivar temporalmente avisos ruidosos durante el borrado
SET client_min_messages = WARNING;

-- 1. Eliminar Procedimientos y Funciones auxiliares
DROP PROCEDURE IF EXISTS sp_generar_volumen_reservaciones(INT);

-- 2. Eliminar Tablas en orden inverso de dependencias relacionales
DROP TABLE IF EXISTS consumos_servicio CASCADE;
DROP TABLE IF EXISTS pagos CASCADE;
DROP TABLE IF EXISTS reservacion_habitaciones CASCADE;
DROP TABLE IF EXISTS reservaciones CASCADE;
DROP TABLE IF EXISTS habitaciones CASCADE;
DROP TABLE IF EXISTS tipos_habitacion CASCADE;
DROP TABLE IF EXISTS servicios CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- 3. Verificación de limpieza total
-- La siguiente consulta debe devolver 0 tablas en el esquema public:
SELECT COUNT(*) AS tablas_restantes
FROM information_schema.tables
WHERE table_schema = 'public';

-- ============================================================================
-- SECUENCIA DETERMINÍSTICA PARA RECONSTRUIR DESDE CERO:
-- 1. \i sql/01_schema.sql
-- 2. \i sql/02_constraints.sql
-- 3. \i sql/03_seed.sql
-- 4. \i sql/06_indexes.sql
-- ============================================================================
