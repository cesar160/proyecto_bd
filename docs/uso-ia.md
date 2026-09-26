# Registro de Uso de Inteligencia Artificial (IA)

> **Bitácora de desarrollo y validación.**  
> Este documento registra cada interacción relevante con el asistente de Inteligencia Artificial (Antigravity), detallando los prompts, el código o arquitectura propuesta, las modificaciones aplicadas, el método de verificación en PostgreSQL y la reflexión técnica correspondiente (de acuerdo a la sección 19 de la guía).

---

## Entrada 01 — Inicialización del Repositorio y Arquitectura

* **Fecha:** 2026-09-26
* **Etapa:** Etapa 0 y 1 — Preparación del entorno y estructura del repositorio.
* **Pregunta / Prompt del usuario:**
  > "de acuerdo a eso quiero que generes lo que se plantea ahi, ya tengo conectado la carpeta con mi repositorio de github, ahora antes de que empieces a trabajar quiero que me digas como lo haras para saber si comprendiste"
* **Respuesta / Propuesta técnica:**  
  Se presentó un plan estructurado en 6 fases respetando la filosofía de proyecto de base de datos puro (sin frontend/backend innecesarios), con 8 tablas, scripts SQL numerados del 01 al 09, bitácoras en Markdown y carpetas de evidencia separadas para local y AWS.
* **Qué se modificó / creó:**  
  Se inicializó la estructura de directorios (`sql/`, `docs/`, `evidence/`), `.gitignore`, `README.md` y bitácora `docs/uso-ia.md`.
* **Cómo se verificó:**  
  Verificación mediante `git status` y comandos de sistema de archivos para confirmar la existencia de rutas limpias sin archivos temporales rastreados.
* **Comentario reflexivo:**  
  La guía establece que no se debe programar todo de golpe, sino por etapas con puntos de verificación. Comprender el alcance exacto evita distracciones con frameworks externos.

---

## Entrada 02 — Diseño DDL del Esquema y Restricciones de Integridad

* **Fecha:** 2026-09-26
* **Etapa:** Etapas 3 y 4 — Creación de `01_schema.sql` y `02_constraints.sql`.
* **Pregunta / Prompt del usuario:**
  > Aprobación para iniciar la generación técnica según la guía.
* **Respuesta / Propuesta técnica:**  
  Separar la creación DDL base (esquema) de las restricciones avanzadas (constraints) para garantizar que el script de creación no falle por dependencias cruzadas de claves foráneas ni reglas circulares. Se utilizó el estándar SQL `BIGINT GENERATED ALWAYS AS IDENTITY`, tipos monetarios `NUMERIC(12,2)` y tipos temporales precisos (`DATE` y `TIMESTAMP`).
* **Qué se modificó / creó:**  
  Archivos `sql/01_schema.sql` y `sql/02_constraints.sql` con nombres explícitos para todas las restricciones (`pk_`, `fk_`, `chk_`, `uq_`).
* **Cómo se verificó:**  
  Se formularon pruebas con `information_schema.tables` y casos de prueba negativos intencionales (intentar registrar precios negativos, fechas con salida menor que entrada, correos duplicados y llaves foráneas inválidas) para asegurar que PostgreSQL detenga los datos no válidos.
* **Comentario reflexivo:**  
  Separar DDL y Constraints permite mayor mantenibilidad y facilita la portabilidad tanto en local como en Amazon RDS. Nombrar explícitamente las restricciones facilita la lectura de errores durante depuración.
