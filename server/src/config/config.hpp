#pragma once
// Configuración del servidor leída de variables de entorno (ver .env.example).

#include <cstdint>
#include <string>

namespace vapor {

struct Config {
    std::string host = "0.0.0.0";
    std::uint16_t port = 8080;
    std::string log_level = "info";
    std::string mysql_host = "127.0.0.1";
    std::uint16_t mysql_port = 3306;
    std::string mysql_user = "vapor";
    std::string mysql_password;
    std::string mysql_database = "vapor";
    std::string jwt_secret;
    int max_upload_mb = 10;
};

// Lee la configuración del entorno. Lanza std::runtime_error si falta algo obligatorio
// o si un número no es válido.
Config load_config_from_env();

// Convierte un texto a puerto (1-65535). Lanza std::invalid_argument si no es válido.
std::uint16_t parse_port(const std::string& text);

}  // namespace vapor
