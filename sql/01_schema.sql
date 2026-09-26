-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 3: Creación del Esquema Relacional
-- ARCHIVO: sql/01_schema.sql
-- DESCRIPCIÓN: Definición DDL de las 8 tablas base del sistema.
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- Asegurar esquema limpio de extensiones si fuesen requeridas
SET client_encoding = 'UTF8';

-- ----------------------------------------------------------------------------
-- 1. TABLA: clientes
-- Representa a los huéspedes y titulares de reservaciones.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente)
);

COMMENT ON TABLE clientes IS 'Registro de huéspedes y personas titulares de reservaciones.';
COMMENT ON COLUMN clientes.id_cliente IS 'Identificador único del cliente (Identity).';
COMMENT ON COLUMN clientes.correo IS 'Correo electrónico de contacto (debe ser único).';

-- ----------------------------------------------------------------------------
-- 2. TABLA: tipos_habitacion
-- Catálogo de categorías de habitaciones (sencilla, doble, suite, etc.).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tipos_habitacion (
    id_tipo SMALLINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    capacidad SMALLINT NOT NULL,
    precio_noche NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_tipos_habitacion PRIMARY KEY (id_tipo)
);

COMMENT ON TABLE tipos_habitacion IS 'Categorías de habitaciones del hotel y sus tarifas base por noche.';

-- ----------------------------------------------------------------------------
-- 3. TABLA: habitaciones
-- Habitaciones físicas del hotel asociadas a una categoría.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS habitaciones (
    id_habitacion BIGINT GENERATED ALWAYS AS IDENTITY,
    numero VARCHAR(10) NOT NULL,
    id_tipo SMALLINT NOT NULL,
    piso SMALLINT NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_habitaciones PRIMARY KEY (id_habitacion)
);

COMMENT ON TABLE habitaciones IS 'Habitaciones físicas del inmueble con estado operativo y nivel de piso.';

-- ----------------------------------------------------------------------------
-- 4. TABLA: reservaciones
-- Folio general y ciclo de vida de la reserva de hospedaje.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reservaciones (
    id_reservacion BIGINT GENERATED ALWAYS AS IDENTITY,
    id_cliente BIGINT NOT NULL,
    fecha_reserva TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    total_estimado NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_reservaciones PRIMARY KEY (id_reservacion)
);

COMMENT ON TABLE reservaciones IS 'Cabecera de la reservación de alojamiento efectuada por un cliente.';

-- ----------------------------------------------------------------------------
-- 5. TABLA: reservacion_habitaciones
-- Relación N:M que permite que una reservación contenga una o más habitaciones.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reservacion_habitaciones (
    id_reservacion_habitacion BIGINT GENERATED ALWAYS AS IDENTITY,
    id_reservacion BIGINT NOT NULL,
    id_habitacion BIGINT NOT NULL,
    precio_noche NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_reservacion_habitaciones PRIMARY KEY (id_reservacion_habitacion)
);

COMMENT ON TABLE reservacion_habitaciones IS 'Detalle de habitaciones asignadas por cada folio de reservación con precio congelado.';

-- ----------------------------------------------------------------------------
-- 6. TABLA: pagos
-- Registro de transacciones financieras aplicadas a las reservaciones.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pagos (
    id_pago BIGINT GENERATED ALWAYS AS IDENTITY,
    id_reservacion BIGINT NOT NULL,
    fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto NUMERIC(12,2) NOT NULL,
    metodo VARCHAR(30) NOT NULL,
    referencia VARCHAR(100),
    CONSTRAINT pk_pagos PRIMARY KEY (id_pago)
);

COMMENT ON TABLE pagos IS 'Transacciones y cobros vinculados a una reservación.';

-- ----------------------------------------------------------------------------
-- 7. TABLA: servicios
-- Catálogo de servicios adicionales y consumibles ofrecidos por el hotel.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS servicios (
    id_servicio BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(80) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_servicios PRIMARY KEY (id_servicio)
);

COMMENT ON TABLE servicios IS 'Catálogo de servicios complementarios (desayuno, lavandería, etc.).';

-- ----------------------------------------------------------------------------
-- 8. TABLA: consumos_servicio
-- Servicios y amenidades consumidas en el transcurso de una estancia.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS consumos_servicio (
    id_consumo BIGINT GENERATED ALWAYS AS IDENTITY,
    id_reservacion BIGINT NOT NULL,
    id_servicio BIGINT NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    fecha_consumo TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_consumos_servicio PRIMARY KEY (id_consumo)
);

COMMENT ON TABLE consumos_servicio IS 'Registro de cargos por consumo de servicios durante el hospedaje.';

-- ============================================================================
-- CONSULTAS DE VERIFICACIÓN (PUNTO DE CONTROL 3)
-- ============================================================================
-- 1. Listar las 8 tablas creadas en el esquema público:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
--
-- 2. Conteo de tablas creadas:
-- SELECT COUNT(*) AS total_tablas FROM information_schema.tables WHERE table_schema = 'public';
