// Punto de entrada del servidor de Vapor.
// S1: solo carga la configuración y la muestra. En S1-S2 se añade aquí:
//   io_context + hilos, signal_set (Ctrl+C), listener HTTP/WebSocket (Beast) y pool de MySQL.

#include <exception>

#include <spdlog/spdlog.h>

#include "config/config.hpp"

int main() {
    try {
        const vapor::Config config = vapor::load_config_from_env();
        spdlog::set_level(spdlog::level::from_str(config.log_level));
        spdlog::info("Vapor server {} · escuchará en {}:{} · MySQL {}:{}/{}", VAPOR_VERSION,
                     config.host, config.port, config.mysql_host, config.mysql_port,
                     config.mysql_database);
        // Nunca registres config.jwt_secret ni config.mysql_password.
        return 0;
    } catch (const std::exception& e) {
        spdlog::critical("No se pudo arrancar: {}", e.what());
        return 1;
    }
}