#include "config/config.hpp"

#include <cstdlib>
#include <stdexcept>

namespace vapor {

namespace {

std::string env_or(const char* name, const std::string& fallback) {
    const char* value = std::getenv(name);
    return (value != nullptr && *value != '\0') ? std::string(value) : fallback;
}

}  // namespace

std::uint16_t parse_port(const std::string& text) {
    std::size_t used = 0;
    const int value = std::stoi(text, &used);  // lanza std::invalid_argument si no es número
    if (used != text.size() || value < 1 || value > 65535) {
        throw std::invalid_argument("puerto no válido: " + text);
    }
    return static_cast<std::uint16_t>(value);
}

Config load_config_from_env() {
    Config c;
    c.host = env_or("VAPOR_HOST", c.host);
    c.port = parse_port(env_or("VAPOR_PORT", "8080"));
    c.log_level = env_or("VAPOR_LOG_LEVEL", c.log_level);
    c.mysql_host = env_or("MYSQL_HOST", c.mysql_host);
    c.mysql_port = parse_port(env_or("MYSQL_PORT", "3306"));
    c.mysql_user = env_or("MYSQL_USER", c.mysql_user);
    c.mysql_password = env_or("MYSQL_PASSWORD", "");
    c.mysql_database = env_or("MYSQL_DATABASE", c.mysql_database);
    c.jwt_secret = env_or("VAPOR_JWT_SECRET", "");
    c.max_upload_mb = std::stoi(env_or("VAPOR_MAX_UPLOAD_MB", "10"));

    if (c.jwt_secret.size() < 32) {
        throw std::runtime_error("VAPOR_JWT_SECRET falta o tiene menos de 32 caracteres");
    }
    return c;
}

}  // namespace vapor
