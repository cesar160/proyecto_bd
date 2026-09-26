# Bitácora de Desarrollo del Proyecto

Guía de seguimiento y estado de las 18 etapas del Sistema de Gestión Hotelera.

---

## Matriz de Etapas y Puntos de Control

| Etapa | Descripción | Estado | Artefacto Generado / Entregable |
|---|---|:---:|---|
| **0** | Preparación del entorno (PostgreSQL, pgAdmin/DBeaver, Git) | 🟢 Completado | Entorno local validado y en ejecución |
| **1** | Repositorio y estructura de carpetas | 🟢 Completado | `README.md`, `.gitignore`, `docs/`, `sql/`, `evidence/` |
| **2** | Creación de base de datos `hotel_db` | 🟢 Completado | Base de datos creada y conectada |
| **3** | Creación de Esquema Relacional (8 tablas) | 🟢 Completado | `sql/01_schema.sql` |
| **4** | Implementación de Restricciones de Integridad | 🟢 Completado | `sql/02_constraints.sql` |
| **5** | Carga de Datos de Prueba Iniciales (Dataset) | 🟢 Completado | `sql/03_seed.sql` |
| **6** | Implementación de Operaciones CRUD Guiadas | 🟢 Completado | `sql/04_crud.sql` |
| **7** | Consultas Relacionales Avanzadas (Q01-Q10) | 🟢 Completado | `sql/05_queries.sql` (Verificado con Q13) |
| **8** | Resolución y Control de Traslapes en Fechas | 🟢 Completado | Validado en `05_queries.sql` y `07_tests.sql` |
| **9** | Análisis y Creación de Índices con EXPLAIN ANALYZE | 🟢 Completado | `sql/06_indexes.sql` (Seq Scan vs Index Scan) |
| **10** | Pruebas Formales de Integridad (Positivas/Negativas) | 🟢 Completado | `sql/07_tests.sql` (Manejo de SQLSTATE 23001) |
| **11** | Pruebas de Carga y Volumen con generate_series() | 🟢 Completado | `sql/08_volume_tests.sql` (1,000+ filas inyectadas) |
| **12** | Manejo de Transacciones (BEGIN, COMMIT, ROLLBACK) | 🟡 Siguiente | Guía `docs/concurrencia-transacciones.md` |
| **13** | Pruebas de Concurrencia con Sesiones Paralelas | 🟡 Siguiente | Guía `docs/concurrencia-transacciones.md` |
| **14** | Limpieza y Recreación Completa Determinística | ⚪ Pendiente | `sql/09_cleanup.sql` |
| **15** | Aprovisionamiento de PostgreSQL en Amazon RDS | ⚪ Pendiente | Configuración en AWS RDS |
| **16** | Conexión remota de DBeaver/pgAdmin a RDS | ⚪ Pendiente | Conexión SSL segura a RDS |
| **17** | Despliegue de scripts SQL en RDS | ⚪ Pendiente | Validación remota del esquema |
| **18** | Validación y pruebas cruzadas Local vs. RDS | ⚪ Pendiente | Reporte y capturas de paridad |

---

## Registro de Decisiones y Cambios
* **2026-09-26:** Se aprobó el enfoque modular dividiendo la definición de tablas (`01_schema.sql`) de las restricciones (`02_constraints.sql`).
* **2026-09-26:** Se adoptó `GENERATED ALWAYS AS IDENTITY` para cumplir con las directrices de PostgreSQL 17.
