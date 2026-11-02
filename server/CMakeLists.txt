# Servidor de Vapor (dueño: Jorge) | C++20 | CMake + vcpkg (modo manifiesto)
cmake_minimum_required(VERSION 3.25)
project(vapor_server VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)   # para clang-tidy y el autocompletado del IDE

option(VAPOR_SANITIZERS "Compilar con AddressSanitizer y UBSan (solo Debug, GCC/Clang)" ON)

# Dependencias (las instala vcpkg a partir de vcpkg.json)
find_package(spdlog CONFIG REQUIRED)
# Descomenta cada línea cuando empieces a usar esa librería (S1-S3):
# find_package(Boost CONFIG REQUIRED COMPONENTS asio beast json mysql)   # Boost::beast, Boost::json, Boost::mysql
# find_package(OpenSSL REQUIRED)                                         # OpenSSL::SSL, OpenSSL::Crypto
# find_package(unofficial-sodium CONFIG REQUIRED)                        # unofficial-sodium::sodium
# find_package(jwt-cpp CONFIG REQUIRED)                                  # jwt-cpp::jwt-cpp

# Avisos y sanitizers
add_library(vapor_warnings INTERFACE)
if(MSVC)
    target_compile_options(vapor_warnings INTERFACE /W4 /permissive- /utf-8)
else()
    target_compile_options(vapor_warnings INTERFACE -Wall -Wextra -Wpedantic -Wshadow -Wconversion)
    if(VAPOR_SANITIZERS AND CMAKE_BUILD_TYPE STREQUAL "Debug")
        target_compile_options(vapor_warnings INTERFACE -fsanitize=address,undefined -fno-omit-frame-pointer)
        target_link_options(vapor_warnings INTERFACE -fsanitize=address,undefined)
    endif()
endif()

# Librería con todo el código (la usan el ejecutable y los tests)
file(GLOB_RECURSE VAPOR_SOURCES CONFIGURE_DEPENDS src/*.cpp)
list(FILTER VAPOR_SOURCES EXCLUDE REGEX ".*/src/main\\.cpp$")

add_library(vapor_lib STATIC ${VAPOR_SOURCES})
target_include_directories(vapor_lib PUBLIC src)
target_compile_definitions(vapor_lib PUBLIC VAPOR_VERSION="${PROJECT_VERSION}")
target_link_libraries(vapor_lib
    PUBLIC
        spdlog::spdlog
        # Boost::beast Boost::json Boost::mysql OpenSSL::SSL OpenSSL::Crypto
        # unofficial-sodium::sodium jwt-cpp::jwt-cpp
    PRIVATE
        vapor_warnings)

# Ejecutable
add_executable(vapor_server src/main.cpp)
target_link_libraries(vapor_server PRIVATE vapor_lib vapor_warnings)

# Tests (GoogleTest)
include(CTest)
if(BUILD_TESTING)
    find_package(GTest CONFIG REQUIRED)
    file(GLOB_RECURSE VAPOR_TESTS CONFIGURE_DEPENDS tests/*.cpp)
    add_executable(vapor_tests ${VAPOR_TESTS})
    target_link_libraries(vapor_tests PRIVATE vapor_lib vapor_warnings GTest::gtest_main)
    include(GoogleTest)
    gtest_discover_tests(vapor_tests)
endif()
