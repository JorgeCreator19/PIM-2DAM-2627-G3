# Vapor

App de mensajería multiplataforma para gaming y e-sports, con **cifrado de extremo a extremo**
en todos los mensajes y **bloqueo de imágenes +18 en el dispositivo**.

Proyecto Intermodular de 2.º DAM - IES El Pla (Alicante)

Grupo **Fruit Salad**:
Jorge Ferrando, Matías Acosta e Iker Mollá  

Tutor: Vicente Jesús Santonja Ivorra.

| Parte | Tecnología | Dueño |
| ------- | ------------ | ------- |
| App (Android, iOS, web, Windows, macOS, Linux) | Flutter + Bloc | Matías (interfaz), Iker (móvil), Jorge (escritorio) |
| Núcleo de cifrado y moderación | Rust (vodozemac, tract-onnx) | Iker |
| Servidor | C++20 (Boost.Beast, Boost.MySQL) | Jorge |
| Datos | MySQL 8.4 + SeaweedFS (S3) | Jorge |

## Estructura del repositorio

```
app/       Cliente Flutter (todas las plataformas)
core/      Núcleo Rust: cifrado E2EE, cifrado de archivos, clasificador +18
server/    Servidor C++: API REST + WebSocket, migraciones SQL y tests
infra/     Docker Compose (MySQL, SeaweedFS, Mailpit, Caddy), scripts y pruebas de carga
docs/      Protocolo, decisiones técnicas, actas, modelo de datos, memoria y pruebas
site/      Página informativa de Vapor (GitHub Pages)
.github/   CI, plantillas de PR e issues, revisores automáticos
```
