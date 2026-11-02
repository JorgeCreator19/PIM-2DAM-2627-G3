Modelo de datos de Vapor (versión 2.1).

- `Vapor_Modelo_de_datos.xlsx`: diccionario de datos, relaciones, orden de migración y hoja **Cambios**.
- `Vapor_ER_conceptual_v2.drawio`: diagrama E-R (4 páginas, una por módulo). **Añadirlo aquí.**

Las migraciones de `server/migrations/` salen de este modelo. Si cambia el modelo, se cambian los dos
(xlsx/drawio y una migración nueva) en el mismo PR, y se apunta en la hoja Cambios.

Cambios de la 2.1 (02/11/2026), ya aplicados en el xlsx y en `001_init.sql`:
- `amistad.solicitado_por` (FK → usuario, nulo): quién envió la solicitud pendiente.
- Valores de los ENUM de `participante`: rol_en_conversacion (miembro, admin), estado (activo, salido).
- Tabla técnica `migracion` (no es una entidad del E-R).

Pendiente en el `.drawio` (página «Cuentas y seguridad», relación reflexiva «se relaciona con» de USUARIO):
añadir el atributo `solicitado_por` junto a estado, bloqueado_por y actualizado_en.
