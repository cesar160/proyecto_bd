-- ============================================================================
-- PROYECTO: Sistema de Gestión Hotelera y Reservaciones
-- ETAPA 5: Carga de Datos de Prueba (Seed Dataset Inicial)
-- ARCHIVO: sql/03_seed.sql
-- DESCRIPCIÓN: Conjunto de datos coherente y representativo para pruebas:
--              - 20 Clientes
--              - 4 Tipos de Habitación
--              - 20 Habitaciones físicas
--              - 6 Servicios adicionales
--              - 25 Reservaciones
--              - 30 Asignaciones de Habitación (incluyendo reservas multi-habitación)
--              - 20 Pagos
--              - 20 Consumos de Servicio
-- MOTOR: PostgreSQL 17+
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. TIPOS DE HABITACIÓN (4 categorías)
-- ----------------------------------------------------------------------------
INSERT INTO tipos_habitacion (nombre, descripcion, capacidad, precio_noche) VALUES
('Sencilla Estándar', 'Habitación acogedora con 1 cama matrimonial, ideal para viajeros individuales o parejas.', 2, 750.00),
('Doble Confort', 'Habitación espaciosa con 2 camas matrimoniales, escritorio y vista a la ciudad.', 4, 1200.00),
('Junior Suite', 'Suite con cama King Size, sala de estar independiente, balcón y tina de hidromasaje.', 2, 1950.00),
('Master Suite Familiar', 'Suite de lujo con 2 habitaciones separadas, cocineta equipada y vista panorámica.', 6, 3200.00);

-- ----------------------------------------------------------------------------
-- 2. HABITACIONES (20 habitaciones físicas en 4 pisos)
-- Nota: La habitación 405 se configura inactiva (en remodelación/mantenimiento).
-- ----------------------------------------------------------------------------
INSERT INTO habitaciones (numero, id_tipo, piso, activa) VALUES
('101', 1, 1, TRUE),
('102', 1, 1, TRUE),
('103', 1, 1, TRUE),
('104', 1, 1, TRUE),
('105', 2, 1, TRUE),
('201', 1, 2, TRUE),
('202', 1, 2, TRUE),
('203', 2, 2, TRUE),
('204', 2, 2, TRUE),
('205', 2, 2, TRUE),
('301', 2, 3, TRUE),
('302', 2, 3, TRUE),
('303', 3, 3, TRUE),
('304', 3, 3, TRUE),
('305', 3, 3, TRUE),
('401', 3, 4, TRUE),
('402', 3, 4, TRUE),
('403', 4, 4, TRUE),
('404', 4, 4, TRUE),
('405', 4, 4, FALSE); -- Inactiva por mantenimiento

-- ----------------------------------------------------------------------------
-- 3. SERVICIOS (6 servicios complementarios)
-- ----------------------------------------------------------------------------
INSERT INTO servicios (nombre, precio, activo) VALUES
('Desayuno Buffet Continental', 180.00, TRUE),
('Servicio a la Habitación (Room Service)', 80.00, TRUE),
('Lavandería y Tintorería Express (por prenda)', 120.00, TRUE),
('Estacionamiento VIP Techado (por noche)', 150.00, TRUE),
('Sesión Spa & Masaje Relajante (60 min)', 650.00, TRUE),
('Alquiler de Sala de Juntas Ejecutiva (por hora)', 350.00, TRUE);

-- ----------------------------------------------------------------------------
-- 4. CLIENTES (20 huéspedes registrados)
-- ----------------------------------------------------------------------------
INSERT INTO clientes (nombre, apellido, correo, telefono, fecha_registro) VALUES
('Carlos', 'Mendoza Garza', 'carlos.mendoza@email.com', '5511223344', '2026-08-01 10:15:00'),
('Ana Laura', 'Gómez Ruiz', 'ana.gomez@email.com', '5522334455', '2026-08-03 12:30:00'),
('Roberto', 'Sánchez Torres', 'roberto.sanchez@email.com', '5533445566', '2026-08-05 14:00:00'),
('Mariana', 'Vázquez Cruz', 'mariana.vazquez@email.com', '5544556677', '2026-08-07 09:45:00'),
('Diego', 'Hernández Ríos', 'diego.hdez@email.com', '5555667788', '2026-08-10 16:20:00'),
('Sofía', 'Ramírez Peña', 'sofia.ramirez@email.com', '5566778899', '2026-08-12 11:10:00'),
('Javier', 'Morales Silva', 'javier.morales@email.com', '5577889900', '2026-08-15 17:35:00'),
('Valeria', 'Castillo Luna', 'valeria.castillo@email.com', '5588990011', '2026-08-18 13:50:00'),
('Fernando', 'Ortega Morales', 'fernando.ortega@email.com', '5599001122', '2026-08-20 08:25:00'),
('Camila', 'Flores Jiménez', 'camila.flores@email.com', '5500112233', '2026-08-22 15:05:00'),
('Alejandro', 'Reyes Aguilar', 'alejandro.reyes@email.com', '8111223344', '2026-08-25 10:40:00'),
('Daniela', 'Guerrero Bravo', 'daniela.guerrero@email.com', '8122334455', '2026-08-28 14:15:00'),
('Mauricio', 'Paredes Canto', 'mauricio.paredes@email.com', '8133445566', '2026-09-01 11:55:00'),
('Paola', 'Navarro Domínguez', 'paola.navarro@email.com', '8144556677', '2026-09-03 16:45:00'),
('Esteban', 'Salazar Vidal', 'esteban.salazar@email.com', '8155667788', '2026-09-05 09:10:00'),
('Lucía', 'Medina Rosas', 'lucia.medina@email.com', '3311223344', '2026-09-08 13:20:00'),
('Héctor', 'Vega Cervantes', 'hector.vega@email.com', '3322334455', '2026-09-10 18:00:00'),
('Gabriela', 'Pacheco Lara', 'gabriela.pacheco@email.com', '3333445566', '2026-09-12 10:30:00'),
('Arturo', 'Chávez Solís', 'arturo.chavez@email.com', '3344556677', '2026-09-15 15:40:00'),
('Elena', 'Montes Ibarra', 'elena.montes@email.com', '3355667788', '2026-09-18 12:00:00');

-- ----------------------------------------------------------------------------
-- 5. RESERVACIONES (25 reservaciones con distintos estados y fechas)
-- ----------------------------------------------------------------------------
INSERT INTO reservaciones (id_cliente, fecha_reserva, fecha_entrada, fecha_salida, estado, total_estimado) VALUES
(1,  '2026-09-01 10:00:00', '2026-09-10', '2026-09-13', 'FINALIZADA', 2250.00), -- 3 noches Sencilla
(2,  '2026-09-02 11:30:00', '2026-09-12', '2026-09-15', 'FINALIZADA', 3600.00), -- 3 noches Doble
(3,  '2026-09-03 15:00:00', '2026-09-14', '2026-09-16', 'FINALIZADA', 3900.00), -- 2 noches Junior Suite
(4,  '2026-09-05 09:20:00', '2026-09-15', '2026-09-18', 'FINALIZADA', 1500.00), -- 2 noches Sencilla
(5,  '2026-09-06 14:10:00', '2026-09-16', '2026-09-20', 'FINALIZADA', 4800.00), -- 4 noches Doble
(6,  '2026-09-08 16:45:00', '2026-09-18', '2026-09-21', 'FINALIZADA', 9600.00), -- 3 noches Master Suite
(7,  '2026-09-10 10:15:00', '2026-09-20', '2026-09-23', 'FINALIZADA', 2250.00), -- 3 noches Sencilla
(8,  '2026-09-11 13:00:00', '2026-09-21', '2026-09-25', 'CANCELADA',  4800.00), -- Cancelada
(9,  '2026-09-12 17:30:00', '2026-09-22', '2026-09-24', 'FINALIZADA', 3900.00), -- 2 noches Jr Suite
(10, '2026-09-14 08:50:00', '2026-09-24', '2026-09-27', 'FINALIZADA', 2250.00), -- 3 noches Sencilla
(11, '2026-09-15 12:00:00', '2026-09-25', '2026-09-28', 'EN_CURSO',   3600.00), -- 3 noches Doble
(12, '2026-09-16 14:40:00', '2026-09-25', '2026-09-29', 'EN_CURSO',   5850.00), -- 3 noches Jr Suite
(13, '2026-09-17 11:20:00', '2026-09-26', '2026-09-30', 'EN_CURSO',   3000.00), -- 4 noches Sencilla
(14, '2026-09-18 16:15:00', '2026-09-27', '2026-10-01', 'CONFIRMADA', 4800.00), -- 4 noches Doble
(15, '2026-09-19 10:05:00', '2026-10-01', '2026-10-04', 'CONFIRMADA', 2250.00), -- 3 noches Sencilla
(16, '2026-09-20 15:30:00', '2026-10-02', '2026-10-05', 'CONFIRMADA', 5850.00), -- 3 noches Jr Suite
(17, '2026-09-21 09:40:00', '2026-10-05', '2026-10-08', 'CONFIRMADA', 3600.00), -- 3 noches Doble
(18, '2026-09-22 13:10:00', '2026-10-06', '2026-10-10', 'CONFIRMADA', 12800.00),-- 4 noches Master Suite
(19, '2026-09-23 18:25:00', '2026-10-10', '2026-10-12', 'PENDIENTE',  1500.00), -- 2 noches Sencilla
(20, '2026-09-24 11:00:00', '2026-10-12', '2026-10-15', 'PENDIENTE',  3600.00), -- 3 noches Doble
(1,  '2026-09-24 14:00:00', '2026-10-15', '2026-10-18', 'CONFIRMADA', 4500.00), -- Cliente 1 recurrente (2 habs)
(2,  '2026-09-25 10:20:00', '2026-10-18', '2026-10-22', 'CONFIRMADA', 7800.00), -- Cliente 2 recurrente (2 habs)
(3,  '2026-09-25 16:50:00', '2026-10-20', '2026-10-23', 'CONFIRMADA', 5850.00), -- Cliente 3 recurrente
(4,  '2026-09-26 09:15:00', '2026-10-25', '2026-10-28', 'CONFIRMADA', 7200.00), -- Cliente 4 recurrente (2 habs)
(5,  '2026-09-26 13:45:00', '2026-10-28', '2026-10-31', 'CONFIRMADA', 9600.00); -- Cliente 5 recurrente (Master)

-- ----------------------------------------------------------------------------
-- 6. ASIGNACIÓN DE HABITACIONES (30 registros)
-- Permite que ciertas reservaciones (ej. 21, 22, 24) tengan más de 1 habitación.
-- ----------------------------------------------------------------------------
INSERT INTO reservacion_habitaciones (id_reservacion, id_habitacion, precio_noche) VALUES
(1,  1,  750.00),  -- Res 1 -> Hab 101
(2,  5,  1200.00), -- Res 2 -> Hab 105
(3,  13, 1950.00), -- Res 3 -> Hab 303
(4,  2,  750.00),  -- Res 4 -> Hab 102
(5,  8,  1200.00), -- Res 5 -> Hab 203
(6,  18, 3200.00), -- Res 6 -> Hab 403
(7,  3,  750.00),  -- Res 7 -> Hab 103
(8,  9,  1200.00), -- Res 8 -> Hab 204 (Cancelada)
(9,  14, 1950.00), -- Res 9 -> Hab 304
(10, 4,  750.00),  -- Res 10 -> Hab 104
(11, 10, 1200.00), -- Res 11 -> Hab 205
(12, 15, 1950.00), -- Res 12 -> Hab 305
(13, 6,  750.00),  -- Res 13 -> Hab 201
(14, 11, 1200.00), -- Res 14 -> Hab 301
(15, 7,  750.00),  -- Res 15 -> Hab 202
(16, 16, 1950.00), -- Res 16 -> Hab 401
(17, 12, 1200.00), -- Res 17 -> Hab 302
(18, 19, 3200.00), -- Res 18 -> Hab 404
(19, 1,  750.00),  -- Res 19 -> Hab 101
(20, 5,  1200.00), -- Res 20 -> Hab 105
-- Reservaciones multi-habitación:
(21, 2,  750.00),  -- Res 21 (Habitacion 1: 102)
(21, 3,  750.00),  -- Res 21 (Habitacion 2: 103)
(22, 13, 1950.00), -- Res 22 (Habitacion 1: 303)
(22, 14, 1950.00), -- Res 22 (Habitacion 2: 304)
(23, 15, 1950.00), -- Res 23 -> Hab 305
(24, 8,  1200.00), -- Res 24 (Habitacion 1: 203)
(24, 9,  1200.00), -- Res 24 (Habitacion 2: 204)
(25, 18, 3200.00), -- Res 25 -> Hab 403
(24, 10, 1200.00), -- Res 24 (Habitacion 3: 205)
(21, 4,  750.00);  -- Res 21 (Habitacion 3: 104)

-- ----------------------------------------------------------------------------
-- 7. PAGOS (20 registros de pago)
-- ----------------------------------------------------------------------------
INSERT INTO pagos (id_reservacion, fecha_pago, monto, metodo, referencia) VALUES
(1,  '2026-09-01 10:10:00', 2250.00, 'TARJETA', 'TXN-90214-VISA'),
(2,  '2026-09-02 11:45:00', 3600.00, 'TRANSFERENCIA', 'SPEI-8823194'),
(3,  '2026-09-03 15:20:00', 3900.00, 'TARJETA', 'TXN-90215-MC'),
(4,  '2026-09-05 09:30:00', 1500.00, 'EFECTIVO', 'REC-EF-001'),
(5,  '2026-09-06 14:25:00', 2000.00, 'TRANSFERENCIA', 'SPEI-8823241'), -- Pago parcial
(5,  '2026-09-16 11:00:00', 2800.00, 'TARJETA', 'TXN-90250-VISA'), -- Finiquito Res 5
(6,  '2026-09-08 17:00:00', 9600.00, 'TRANSFERENCIA', 'SPEI-8823290'),
(7,  '2026-09-10 10:30:00', 2250.00, 'TARJETA', 'TXN-90288-AMEX'),
(9,  '2026-09-12 17:45:00', 3900.00, 'EFECTIVO', 'REC-EF-002'),
(10, '2026-09-14 09:05:00', 2250.00, 'TARJETA', 'TXN-90310-VISA'),
(11, '2026-09-15 12:15:00', 1800.00, 'TRANSFERENCIA', 'SPEI-8823350'), -- Anticipo 50%
(12, '2026-09-16 15:00:00', 5850.00, 'TARJETA', 'TXN-90345-MC'),
(13, '2026-09-17 11:35:00', 3000.00, 'EFECTIVO', 'REC-EF-003'),
(14, '2026-09-18 16:30:00', 4800.00, 'TARJETA', 'TXN-90380-VISA'),
(15, '2026-09-19 10:20:00', 1000.00, 'TRANSFERENCIA', 'SPEI-8823410'), -- Anticipo
(16, '2026-09-20 15:45:00', 5850.00, 'TARJETA', 'TXN-90412-AMEX'),
(17, '2026-09-21 09:55:00', 3600.00, 'TARJETA', 'TXN-90430-VISA'),
(18, '2026-09-22 13:30:00', 6400.00, 'TRANSFERENCIA', 'SPEI-8823499'), -- Anticipo 50%
(21, '2026-09-24 14:15:00', 4500.00, 'TARJETA', 'TXN-90480-VISA'),
(22, '2026-09-25 10:35:00', 7800.00, 'TRANSFERENCIA', 'SPEI-8823544');

-- ----------------------------------------------------------------------------
-- 8. CONSUMOS DE SERVICIO (20 consumos durante estancias)
-- ----------------------------------------------------------------------------
INSERT INTO consumos_servicio (id_reservacion, id_servicio, cantidad, precio_unitario, fecha_consumo) VALUES
(1,  1, 2, 180.00, '2026-09-11 08:30:00'), -- 2 Desayunos buffet
(1,  4, 3, 150.00, '2026-09-10 18:00:00'), -- 3 noches estacionamiento
(2,  1, 4, 180.00, '2026-09-13 09:00:00'), -- 4 Desayunos buffet
(2,  2, 1, 80.00,  '2026-09-14 21:30:00'), -- Room service
(3,  5, 2, 650.00, '2026-09-15 16:00:00'), -- 2 Sesiones de Spa
(3,  2, 2, 80.00,  '2026-09-15 22:00:00'), -- Room service
(4,  3, 3, 120.00, '2026-09-16 11:00:00'), -- Lavandería
(5,  1, 4, 180.00, '2026-09-17 08:45:00'), -- Desayunos
(5,  4, 4, 150.00, '2026-09-16 19:00:00'), -- Estacionamiento
(6,  6, 3, 350.00, '2026-09-19 10:00:00'), -- 3 hrs Sala de juntas
(6,  5, 1, 650.00, '2026-09-20 17:30:00'), -- Spa
(7,  1, 2, 180.00, '2026-09-21 08:15:00'), -- Desayunos
(9,  2, 1, 80.00,  '2026-09-23 20:45:00'), -- Room service
(10, 4, 3, 150.00, '2026-09-24 15:30:00'), -- Estacionamiento
(11, 1, 3, 180.00, '2026-09-26 08:30:00'), -- Desayuno
(11, 2, 2, 80.00,  '2026-09-26 21:00:00'), -- Room service
(12, 5, 2, 650.00, '2026-09-26 15:00:00'), -- Spa
(13, 3, 2, 120.00, '2026-09-27 10:00:00'), -- Lavandería
(14, 1, 2, 180.00, '2026-09-28 09:15:00'), -- Desayuno
(18, 6, 4, 350.00, '2026-10-07 11:00:00'); -- 4 hrs Sala de juntas

-- ============================================================================
-- VERIFICACIÓN DE CARGA (PUNTO DE CONTROL 5)
-- ============================================================================
-- SELECT 'clientes' AS tabla, COUNT(*) FROM clientes
-- UNION ALL
-- SELECT 'tipos_habitacion', COUNT(*) FROM tipos_habitacion
-- UNION ALL
-- SELECT 'habitaciones', COUNT(*) FROM habitaciones
-- UNION ALL
-- SELECT 'servicios', COUNT(*) FROM servicios
-- UNION ALL
-- SELECT 'reservaciones', COUNT(*) FROM reservaciones
-- UNION ALL
-- SELECT 'reservacion_habitaciones', COUNT(*) FROM reservacion_habitaciones
-- UNION ALL
-- SELECT 'pagos', COUNT(*) FROM pagos
-- UNION ALL
-- SELECT 'consumos_servicio', COUNT(*) FROM consumos_servicio;
