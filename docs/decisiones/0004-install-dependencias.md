# 0004- Instalador de dependencias con un script

- **Fecha:** 13/11/2026
- **Estado:** aceptada
- **Quién decide:** Jorge

## Contexto

Es mucha molestia descargar todas las dependencias necesarias en cada PC donde se tenga que trabajar con el proyecto,
así que es mejor hacer un script en CMD para poder instalarlas todas al mismo tiempo y así no perder tiempo haciiendolo
de forma manual.

## Decisión

Crear un script en CMD que instale todas las dependencias necesarias para poder trabajar con el proyecto, de forma que no haya que descargarlas de forma manual y se pueda hacer todo de una sola vez. Este script se llamará `install-dependencies.bat` y se colocará en la carpeta `docs/util/`.

## Alternativas descartadas

- Opción A: Hacerlo de forma manual.
- Opción B: Hacer un script en otro lenguaje de programación.

## Consecuencias

- La ventaja es que se ahorra tiempo y esfuerzo al instalar todas las dependencias de una sola vez.
- La desventaja es que si alguna dependencia falla al instalarse, el script puede no funcionar correctamente y habrá que solucionarlo de forma manual.
