//! Funciones de prueba del puente (S1): si `core_version()` funciona desde Flutter,
//! el puente está bien montado en esa plataforma.

/// Versión del núcleo, para mostrarla en Ajustes y en los informes de errores.
pub fn core_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Ejercicio de S1: llamar a esta función desde un botón de Flutter.
pub fn sumar(a: i64, b: i64) -> i64 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn suma_bien() {
        assert_eq!(sumar(2, 3), 5);
    }
}
