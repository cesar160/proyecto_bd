# Bitácora de Desarrollo del Proyecto

Guía de seguimiento y estado de las 18 etapas del Sistema de Gestión Hotelera.

---

## Matriz de Etapas y Puntos de Control

| Etapa | Descripción | Estado | Artefacto Generado / Entregable |
|---|---|:---:|---|
| **0** | Preparación del entorno (PostgreSQL, DBeaver, Git) | 🟡 En progreso | Verificación local de PostgreSQL |
| **1** | Repositorio y estructura de carpetas | 🟢 Completado | `README.md`, `.gitignore`, `docs/`, `sql/`, `evidence/` |
| **2** | Creación de base de datos `hotel_db` | 🟡 En progreso | Script o comando DDL de base de datos |
| **3** | Creación de Esquema Relacional (8 tablas) | 🟢 Completado | `sql/01_schema.sql` |
| **4** | Implementación de Restricciones de Integridad | 🟢 Completado | `sql/02_constraints.sql` |
| **5** | Carga de Datos de Prueba Iniciales (Dataset) | 🟡 Siguiente | `sql/03_seed.sql` |
| **6** | Implementación de Operaciones CRUD Guiadas | ⚪ Pendiente | `sql/04_crud.sql` |
| **7** | Consultas Relacionales Avanzadas (Q01-Q10) | ⚪ Pendiente | `sql/05_queries.sql` |
| **8** | Resolución y Control de Traslapes en Fechas | ⚪ Pendiente | Lógica de prevención de traslape |
| **9** | Análisis y Creación de Índices con EXPLAIN ANALYZE | ⚪ Pendiente | `sql/06_indexes.sql` |
| **10** | Pruebas Formales de Integridad (Positivas/Negativas) | ⚪ Pendiente | `sql/07_tests.sql` |
| **11** | Pruebas de Carga y Volumen con generate_series() | ⚪ Pendiente | `sql/08_volume_tests.sql` |
| **12** | Manejo de Transacciones (BEGIN, COMMIT, ROLLBACK) | ⚪ Pendiente | Scripts de atomicidad |
| **13** | Pruebas de Concurrencia con Sesiones Paralelas | ⚪ Pendiente | Guía de prueba de aislamiento |
| **14** | Limpieza y Recreación Completa Determinística | ⚪ Pendiente | `sql/09_cleanup.sql` |
| **15** | Aprovisionamiento de PostgreSQL en Amazon RDS | ⚪ Pendiente | Configuración en AWS RDS |
| **16** | Conexión remota de DBeaver a RDS | ⚪ Pendiente | Conexión SSL segura a RDS |
| **17** | Despliegue de scripts SQL en RDS | ⚪ Pendiente | Validación remota del esquema |
| **18** | Validación y pruebas cruzadas Local vs. RDS | ⚪ Pendiente | Reporte y capturas de paridad |

---

## Registro de Decisiones y Cambios
* **2026-09-26:** Se aprobó el enfoque modular dividiendo la definición de tablas (`01_schema.sql`) de las restricciones (`02_constraints.sql`).
* **2026-09-26:** Se adoptó `GENERATED ALWAYS AS IDENTITY` para cumplir con las directrices de PostgreSQL 17.
