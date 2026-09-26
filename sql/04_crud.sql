-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 6: Operaciones Básicas CRUD (Create, Read, Update, Delete)
-- ARCHIVO: sql/04_crud.sql
-- DESCRIPCIÓN: Demostración formal de operaciones CRUD en PostgreSQL,
--              incorporando comprobaciones previas y posteriores (SELECT)
--              y validando el respeto a la integridad referencial.
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- ============================================================================
-- 1. CREATE (Inserción de nuevos registros)
-- ============================================================================

-- 1.1 Registrar un nuevo cliente
INSERT INTO clientes (nombre, apellido, correo, telefono)
VALUES ('Guillermo', 'Del Toro', 'memo.deltoro@cine.com', '3399887766')
RETURNING id_cliente, nombre, apellido, correo;

-- 1.2 Registrar una nueva habitación en el piso 3
INSERT INTO habitaciones (numero, id_tipo, piso, activa)
VALUES ('306', 2, 3, TRUE)
RETURNING id_habitacion, numero, id_tipo, piso;

-- 1.3 Registrar una nueva reservación para el cliente recién creado
-- Asumimos el id_cliente generado (o consultado)
INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida, estado, total_estimado)
VALUES (
    (SELECT id_cliente FROM clientes WHERE correo = 'memo.deltoro@cine.com'),
    '2026-11-15',
    '2026-11-20',
    'CONFIRMADA',
    6000.00
)
RETURNING id_reservacion, id_cliente, fecha_entrada, fecha_salida, estado;

-- Asignar la habitación 306 a dicha reservación
INSERT INTO reservacion_habitaciones (id_reservacion, id_habitacion, precio_noche)
VALUES (
    (SELECT id_reservacion FROM reservaciones WHERE id_cliente = (SELECT id_cliente FROM clientes WHERE correo = 'memo.deltoro@cine.com') ORDER BY id_reservacion DESC LIMIT 1),
    (SELECT id_habitacion FROM habitaciones WHERE numero = '306'),
    1200.00
);

-- 1.4 Registrar un abono o pago a dicha reservación
INSERT INTO pagos (id_reservacion, monto, metodo, referencia)
VALUES (
    (SELECT id_reservacion FROM reservaciones WHERE id_cliente = (SELECT id_cliente FROM clientes WHERE correo = 'memo.deltoro@cine.com') ORDER BY id_reservacion DESC LIMIT 1),
    3000.00,
    'TRANSFERENCIA',
    'SPEI-ANTICIPO-DELTORO'
)
RETURNING id_pago, id_reservacion, monto, metodo;

-- 1.5 Registrar un consumo de servicio
INSERT INTO consumos_servicio (id_reservacion, id_servicio, cantidad, precio_unitario)
VALUES (
    (SELECT id_reservacion FROM reservaciones WHERE id_cliente = (SELECT id_cliente FROM clientes WHERE correo = 'memo.deltoro@cine.com') ORDER BY id_reservacion DESC LIMIT 1),
    1, -- Desayuno Buffet
    2,
    180.00
)
RETURNING id_consumo, id_reservacion, id_servicio, cantidad, precio_unitario;


-- ============================================================================
-- 2. READ (Lectura y Consultas Básicas)
-- ============================================================================

-- 2.1 Consultar clientes registrados recientemente
SELECT id_cliente, nombre, apellido, correo, telefono, fecha_registro
FROM clientes
ORDER BY id_cliente DESC
LIMIT 5;

-- 2.2 Consultar habitaciones activas y su categoría
SELECT h.id_habitacion, h.numero, th.nombre AS tipo, th.precio_noche, h.piso, h.activa
FROM habitaciones h
INNER JOIN tipos_habitacion th ON h.id_tipo = th.id_tipo
WHERE h.activa = TRUE
ORDER BY h.piso, h.numero;

-- 2.3 Consultar las últimas 5 reservaciones y el nombre del titular
SELECT r.id_reservacion, c.nombre || ' ' || c.apellido AS cliente, r.fecha_entrada, r.fecha_salida, r.estado, r.total_estimado
FROM reservaciones r
INNER JOIN clientes c ON r.id_cliente = c.id_cliente
ORDER BY r.id_reservacion DESC
LIMIT 5;

-- 2.4 Consultar pagos realizados ordenados cronológicamente
SELECT p.id_pago, p.id_reservacion, p.monto, p.metodo, p.referencia, p.fecha_pago
FROM pagos p
ORDER BY p.fecha_pago DESC
LIMIT 5;


-- ============================================================================
-- 3. UPDATE (Modificación con comprobaciones Pre y Post)
-- ============================================================================

-- 3.1 Modificar teléfono del cliente 1
-- Comprobación PRE:
SELECT id_cliente, nombre, apellido, telefono FROM clientes WHERE id_cliente = 1;

-- Actualización:
UPDATE clientes
SET telefono = '5599887766'
WHERE id_cliente = 1;

-- Comprobación POST:
SELECT id_cliente, nombre, apellido, telefono FROM clientes WHERE id_cliente = 1;


-- 3.2 Modificar estado de reservación (de PENDIENTE a CONFIRMADA)
-- Comprobación PRE:
SELECT id_reservacion, estado, total_estimado FROM reservaciones WHERE id_reservacion = 19;

-- Actualización:
UPDATE reservaciones
SET estado = 'CONFIRMADA'
WHERE id_reservacion = 19;

-- Comprobación POST:
SELECT id_reservacion, estado, total_estimado FROM reservaciones WHERE id_reservacion = 19;


-- 3.3 Modificar precio de un servicio (actualización de tarifa)
-- Comprobación PRE:
SELECT id_servicio, nombre, precio FROM servicios WHERE id_servicio = 4;

-- Actualización:
UPDATE servicios
SET precio = 175.00
WHERE id_servicio = 4;

-- Comprobación POST:
SELECT id_servicio, nombre, precio FROM servicios WHERE id_servicio = 4;


-- ============================================================================
-- 4. DELETE (Eliminación controlada y protección referencial)
-- ============================================================================

-- 4.1 ELIMINACIÓN EXITOSA (Registro sin relaciones dependientes)
-- Creamos un servicio temporal de prueba
INSERT INTO servicios (nombre, precio, activo)
VALUES ('Servicio Temporal Sin Uso', 50.00, FALSE);

-- Comprobar existencia PRE:
SELECT id_servicio, nombre FROM servicios WHERE nombre = 'Servicio Temporal Sin Uso';

-- Eliminar el registro aislado:
DELETE FROM servicios
WHERE nombre = 'Servicio Temporal Sin Uso';

-- Comprobar eliminación POST (debe devolver 0 filas):
SELECT id_servicio, nombre FROM servicios WHERE nombre = 'Servicio Temporal Sin Uso';


-- 4.2 PRUEBA DE PROTECCIÓN REFERENCIAL (Intento de eliminación con relaciones)
-- Intentar borrar el cliente 1, el cual tiene reservaciones históricas y activas.
-- RESULTADO ESPERADO: PostgreSQL debe ABORTAR la operación con un error de violación
-- de llave foránea (fk_reservaciones_cliente), evitando dejar datos huérfanos.
/*
DELETE FROM clientes WHERE id_cliente = 1;
-- ERROR: update or delete on table "clientes" violates foreign key constraint "fk_reservaciones_cliente" on table "reservaciones"
*/

-- Igualmente, intentar borrar una habitación con reservaciones asignadas:
/*
DELETE FROM habitaciones WHERE id_habitacion = 1;
-- ERROR: update or delete on table "habitaciones" violates foreign key constraint "fk_res_hab_habitacion" on table "reservacion_habitaciones"
*/
