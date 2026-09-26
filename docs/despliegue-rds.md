# Guía de Despliegue en Amazon RDS for PostgreSQL (Etapas 15 a 18)

Instrucciones de configuración, seguridad y replicación del esquema en la nube mediante **Amazon RDS**.

---

## 1. Aprovisionamiento de la Instancia RDS (Etapa 15)

Al crear la base de datos en la consola de AWS RDS:

* **Motor:** PostgreSQL (versión mayor: **17.x** para mantener paridad con el entorno local).
* **Plantilla:** Capa gratuita (*Free Tier*).
* **Identificador de BD:** `hotel-db-instance`.
* **Nombre de la base de datos inicial:** `hotel_db`.
* **Credenciales maestras:**
  * Usuario maestro: (ej. `postgres` o `admin_hotel`).
  * Contraseña maestra: Contraseña robusta (mínimo 16 caracteres alfanuméricos).
* **Almacenamiento:** 20 GiB gp3 (predeterminado).
* **Conectividad:**
  * *Acceso público:* **Sí** (para conectarse desde DBeaver en tu computadora).

---

## 2. Configuración Crítica de Seguridad (Security Group)

> [!CAUTION]
> **REGLA DE ORO DE SEGURIDAD:**
> Nunca permitas el acceso a PostgreSQL desde cualquier IP (`0.0.0.0/0`). Esto expondría la base de datos a ataques automatizados de fuerza bruta y vulnerabilidades.

1. Ir a la sección de **VPC Security Groups** de la instancia en la consola de AWS.
2. Editar las reglas de entrada (*Inbound Rules*):
   * **Tipo:** PostgreSQL (Puerto `5432`).
   * **Origen (Source):** Seleccionar **Mi IP** (*My IP*), lo que generará una regla con tu dirección IP pública actual (ej. `201.140.x.x/32`).
3. Guardar las reglas.

> [!WARNING]
> **NUNCA subas a GitHub:**
> * El endpoint público de RDS (ej. `hotel-db-instance.c12345.us-east-1.rds.amazonaws.com`).
> * Tu usuario maestro o contraseña.
> El archivo `.gitignore` ya está configurado para evitar rastrear archivos `.env` o credenciales.

---

## 3. Conexión de DBeaver a Amazon RDS (Etapa 16)

1. En DBeaver, crear una nueva conexión seleccionando **PostgreSQL**.
2. Completar los campos con la información de AWS:
   * **Host:** `[tu-endpoint-de-rds].rds.amazonaws.com`
   * **Port:** `5432`
   * **Database:** `hotel_db`
   * **Username:** `[tu_usuario_maestro]`
   * **Password:** `[tu_contraseña]`
3. En la pestaña **SSL**, verificar que el modo esté habilitado (preferentemente `require`).
4. Hacer clic en **Test Connection**. Al ver el mensaje de conexión exitosa, guardar la conexión con el nombre `Hotel DB - AWS RDS`.
5. Probar con:
   ```sql
   SELECT version();
   SELECT current_database();
   ```

---

## 4. Despliegue del Esquema en RDS (Etapa 17)

Una vez conectado a la instancia remota `hotel_db` en DBeaver, ejecutar en orden estricto los mismos scripts utilizados localmente:

1. `sql/01_schema.sql`
2. `sql/02_constraints.sql`
3. `sql/03_seed.sql`
4. `sql/06_indexes.sql`

Verificar en RDS:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

SELECT 'clientes' AS tabla, COUNT(*) FROM clientes
UNION ALL SELECT 'habitaciones', COUNT(*) FROM habitaciones
UNION ALL SELECT 'reservaciones', COUNT(*) FROM reservaciones;
```

---

## 5. Validación Final de Paridad Local vs. Remota (Etapa 18)

Ejecutar en DBeaver sobre la conexión de RDS:
* `sql/07_tests.sql` (certificar que las restricciones CHECK y UNIQUE se comportan idénticamente).
* `sql/05_queries.sql` (certificar que las consultas de negocio y cálculo de saldos devuelven los mismos resultados lógicos).
* Tomar capturas de pantalla de las consultas exitosas y guardarlas en `evidence/aws/validation/` (asegurándose de no incluir contraseñas en las capturas).
