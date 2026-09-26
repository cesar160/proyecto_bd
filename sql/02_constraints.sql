-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 4: Implementación de Restricciones de Integridad
-- ARCHIVO: sql/02_constraints.sql
-- DESCRIPCIÓN: Definición formal de Llaves Foráneas (FK), Restricciones de
--              Unicidad (UNIQUE) y Reglas de Dominio/Negocio (CHECK).
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- ============================================================================
-- 1. RESTRICCIONES DE UNICIDAD (UNIQUE)
-- ============================================================================

-- Un cliente no puede registrarse con un correo ya existente
ALTER TABLE clientes
    ADD CONSTRAINT uq_clientes_correo UNIQUE (correo);

-- El nombre de una categoría o tipo de habitación no debe repetirse
ALTER TABLE tipos_habitacion
    ADD CONSTRAINT uq_tipos_habitacion_nombre UNIQUE (nombre);

-- El número identificador de la habitación debe ser único en el hotel
ALTER TABLE habitaciones
    ADD CONSTRAINT uq_habitaciones_numero UNIQUE (numero);

-- El nombre de un servicio en el catálogo debe ser único
ALTER TABLE servicios
    ADD CONSTRAINT uq_servicios_nombre UNIQUE (nombre);

-- Una misma habitación no debe ser agregada dos veces en la misma reservación
ALTER TABLE reservacion_habitaciones
    ADD CONSTRAINT uq_res_hab_habitacion_reserva UNIQUE (id_reservacion, id_habitacion);


-- ============================================================================
-- 2. RESTRICCIONES DE LLAVE FORÁNEA (FOREIGN KEY)
-- ============================================================================

-- Cada habitación debe pertenecer a un tipo de habitación existente.
-- ON DELETE RESTRICT impide borrar tipos de habitación en uso.
ALTER TABLE habitaciones
    ADD CONSTRAINT fk_habitaciones_tipo
    FOREIGN KEY (id_tipo)
    REFERENCES tipos_habitacion (id_tipo)
    ON DELETE RESTRICT;

-- Una reservación debe pertenecer forzosamente a un cliente registrado.
-- ON DELETE RESTRICT protege el historial de reservas de un cliente.
ALTER TABLE reservaciones
    ADD CONSTRAINT fk_reservaciones_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES clientes (id_cliente)
    ON DELETE RESTRICT;

-- Las habitaciones asignadas a una reservación dependen de ella.
-- Si se cancela o elimina el borrador de reservación, su detalle se depura en cascada.
ALTER TABLE reservacion_habitaciones
    ADD CONSTRAINT fk_res_hab_reservacion
    FOREIGN KEY (id_reservacion)
    REFERENCES reservaciones (id_reservacion)
    ON DELETE CASCADE;

-- La habitación asignada debe existir físicamente y no puede eliminarse si tiene historial.
ALTER TABLE reservacion_habitaciones
    ADD CONSTRAINT fk_res_hab_habitacion
    FOREIGN KEY (id_habitacion)
    REFERENCES habitaciones (id_habitacion)
    ON DELETE RESTRICT;

-- Un pago debe asociarse a una reservación existente.
-- ON DELETE RESTRICT previene la eliminación de reservaciones con pagos aplicados.
ALTER TABLE pagos
    ADD CONSTRAINT fk_pagos_reservacion
    FOREIGN KEY (id_reservacion)
    REFERENCES reservaciones (id_reservacion)
    ON DELETE RESTRICT;

-- Un consumo debe estar vinculado a una reservación activa.
ALTER TABLE consumos_servicio
    ADD CONSTRAINT fk_consumos_reservacion
    FOREIGN KEY (id_reservacion)
    REFERENCES reservaciones (id_reservacion)
    ON DELETE RESTRICT;

-- El servicio consumido debe existir en el catálogo.
ALTER TABLE consumos_servicio
    ADD CONSTRAINT fk_consumos_servicio
    FOREIGN KEY (id_servicio)
    REFERENCES servicios (id_servicio)
    ON DELETE RESTRICT;


-- ============================================================================
-- 3. RESTRICCIONES DE VALIDACIÓN (CHECK)
-- ============================================================================

-- tipos_habitacion: capacidad y precio por noche mayores a 0
ALTER TABLE tipos_habitacion
    ADD CONSTRAINT chk_tipo_capacidad_positiva CHECK (capacidad > 0),
    ADD CONSTRAINT chk_tipo_precio_positivo CHECK (precio_noche > 0);

-- habitaciones: nivel de piso válido (al menos piso 1 o superior)
ALTER TABLE habitaciones
    ADD CONSTRAINT chk_habitacion_piso_valido CHECK (piso >= 1);

-- reservaciones:
-- a) La fecha de salida debe ser estrictamente posterior a la fecha de entrada
-- b) El estado solo puede ser uno de los estados oficiales del hotel
-- c) El total estimado no puede ser un importe negativo
ALTER TABLE reservaciones
    ADD CONSTRAINT chk_reserva_fechas_validas CHECK (fecha_salida > fecha_entrada),
    ADD CONSTRAINT chk_reserva_estado_valido CHECK (
        estado IN ('PENDIENTE', 'CONFIRMADA', 'EN_CURSO', 'FINALIZADA', 'CANCELADA')
    ),
    ADD CONSTRAINT chk_reserva_total_no_negativo CHECK (total_estimado >= 0);

-- reservacion_habitaciones: precio por noche congelado mayor a cero
ALTER TABLE reservacion_habitaciones
    ADD CONSTRAINT chk_res_hab_precio_positivo CHECK (precio_noche > 0);

-- pagos:
-- a) El importe del abono debe ser estrictamente mayor a 0
-- b) El medio de pago debe corresponder al catálogo autorizado
ALTER TABLE pagos
    ADD CONSTRAINT chk_pago_monto_positivo CHECK (monto > 0),
    ADD CONSTRAINT chk_pago_metodo_valido CHECK (
        metodo IN ('EFECTIVO', 'TARJETA', 'TRANSFERENCIA')
    );

-- servicios: el precio no puede ser negativo (puede ser 0 si fuese una cortesía)
ALTER TABLE servicios
    ADD CONSTRAINT chk_servicio_precio_no_negativo CHECK (precio >= 0);

-- consumos_servicio:
-- a) La cantidad solicitada debe ser de al menos 1 unidad
-- b) El precio unitario histórico no puede ser negativo
ALTER TABLE consumos_servicio
    ADD CONSTRAINT chk_consumo_cantidad_positiva CHECK (cantidad > 0),
    ADD CONSTRAINT chk_consumo_precio_no_negativo CHECK (precio_unitario >= 0);


-- ============================================================================
-- VERIFICACIÓN DE RESTRICCIONES (PUNTO DE CONTROL 4)
-- Pruebas de falla esperada (deben arrojar error al ejecutarse individualmente):
-- ============================================================================

/*
-- PRUEBA A: Intento de precio negativo en catálogo de servicios (Falla por chk_servicio_precio_no_negativo)
INSERT INTO servicios (nombre, precio) VALUES ('Prueba Invalida', -50.00);

-- PRUEBA B: Intento de correo duplicado (Falla por uq_clientes_correo)
-- INSERT INTO clientes (nombre, apellido, correo) VALUES ('Juan', 'Perez', 'cliente_duplicado@hotel.com');
-- INSERT INTO clientes (nombre, apellido, correo) VALUES ('Maria', 'Lopez', 'cliente_duplicado@hotel.com');

-- PRUEBA C: Reservación con cliente inexistente (Falla por fk_reservaciones_cliente)
INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida) 
VALUES (999999, '2026-11-01', '2026-11-05');

-- PRUEBA D: Fecha de salida menor o igual a fecha de entrada (Falla por chk_reserva_fechas_validas)
INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida) 
VALUES (1, '2026-10-20', '2026-10-18');
*/
