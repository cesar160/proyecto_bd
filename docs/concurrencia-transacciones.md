# Guía de Pruebas de Transacciones y Concurrencia (Etapas 12 y 13)

Instrucciones paso a paso para validar la atomicidad transaccional y el aislamiento de operaciones concurrentes en PostgreSQL utilizando DBeaver.

---

## 1. Prueba de Transacciones y Atomicidad (Etapa 12)

El objetivo de esta prueba es comprobar que ante cualquier fallo intermedio, la base de datos no almacene datos parciales o huérfanos gracias a `ROLLBACK`.

### Escenario: Reservación con error intencional

Abra un editor SQL en DBeaver y ejecute el siguiente bloque:

```sql
-- 1. Iniciar transacción explícita
BEGIN;

-- 2. Insertar cabecera de reservación
INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida, estado, total_estimado)
VALUES (1, '2026-12-20', '2026-12-25', 'PENDIENTE', 5000.00);

-- 3. Provocar un error intencional (ejemplo: asignar una habitación que NO existe)
-- Esto viola la restricción fk_res_hab_habitacion
INSERT INTO reservacion_habitaciones (id_reservacion, id_habitacion, precio_noche)
VALUES (
    (SELECT id_reservacion FROM reservaciones WHERE fecha_entrada = '2026-12-20' AND id_cliente = 1),
    999999, -- Habitación inexistente
    1000.00
);

-- PostgreSQL marcará la transacción en estado de error
-- Ejecutamos ROLLBACK para cancelar todo
ROLLBACK;
```

### Comprobación del Punto de Control 12:
Ejecutar:
```sql
SELECT * FROM reservaciones 
WHERE fecha_entrada = '2026-12-20' AND id_cliente = 1;
```
**Resultado esperado:** Cero filas devueltas. La cabecera de la reservación fue completamente revertida.

---

## 2. Prueba de Concurrencia con Dos Sesiones Simultáneas (Etapa 13)

Esta prueba simula a dos huéspedes intentando apartar la misma habitación física para fechas incompatibles al mismo tiempo.

### Preparación en DBeaver:
1. Asegúrese de que en DBeaver el modo de confirmación esté en **Manual Commit** (desactive Auto-Commit en el menú superior o barra de estado).
2. Abra dos pestañas de SQL independientes:
   * **Consola A** (Usuario 1)
   * **Consola B** (Usuario 2)

---

### Paso a Paso de la Simulación:

#### En Consola A:
```sql
-- Consola A: Inicia el Usuario 1
BEGIN;

-- Bloquea la habitación para verificar y apartar
SELECT id_habitacion, numero 
FROM habitaciones 
WHERE numero = '101' 
FOR UPDATE;

-- El Usuario 1 inserta la reservación para las fechas del 10 al 15 de Noviembre
INSERT INTO reservaciones (id_cliente, fecha_entrada, fecha_salida, estado, total_estimado)
VALUES (1, '2026-11-10', '2026-11-15', 'CONFIRMADA', 3750.00);

INSERT INTO reservacion_habitaciones (id_reservacion, id_habitacion, precio_noche)
VALUES (
    (SELECT CURRVAL(pg_get_serial_sequence('reservaciones','id_reservacion'))),
    (SELECT id_habitacion FROM habitaciones WHERE numero = '101'),
    750.00
);

-- NO EJECUTAR COMMIT TODAVÍA. Dejar la transacción abierta en Consola A.
```

#### En Consola B (Al mismo tiempo):
```sql
-- Consola B: El Usuario 2 intenta apartar la misma habitación 101 para fechas que chocan (12 al 14)
BEGIN;

SELECT id_habitacion, numero 
FROM habitaciones 
WHERE numero = '101' 
FOR UPDATE;
```

#### Observación del Punto de Control 13:
* **Consola B se quedará en espera (Bloqueada / Lock Wait)** debido a que la fila de la habitación 101 está tomada por la transacción del Usuario A.
* Regrese a la **Consola A** y ejecute:
  ```sql
  COMMIT;
  ```
* Inmediatamente, la **Consola B** se desbloqueará y retornará el control.
* Si el Usuario 2 consulta la disponibilidad tras el lock, detectará que la habitación ya no está disponible para sus fechas, evitando el fenómeno de la **doble reservación**.
* Ejecutar en **Consola B**:
  ```sql
  ROLLBACK;
  ```
