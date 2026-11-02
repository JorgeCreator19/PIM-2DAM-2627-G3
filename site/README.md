# site/ - Página informativa de Vapor (dueño: Matías)

Web estática que explica qué es Vapor, cómo se usa, descargas por plataforma, FAQ y privacidad.
Se publica gratis con **GitHub Pages** mediante `.github/workflows/pages.yml`, que sube esta carpeta
cada vez que cambia en `main`. Activarlo una vez: Settings -> Pages -> Source: **GitHub Actions**.

No confundir con la **versión web de la app**, que es Flutter (`app/`, `flutter build web`)
y se sirve desde el servidor de demo con Caddy.

Estructura prevista: `index.html`, `downloads.html`, `css/`, `js/`, `privacy.html`, `assets/` (logo, capturas, etc).
