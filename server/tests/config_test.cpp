#include <stdexcept>

#include <gtest/gtest.h>

#include "config/config.hpp"

TEST(ParsePort, AceptaPuertosValidos) {
    EXPECT_EQ(vapor::parse_port("8080"), 8080);
    EXPECT_EQ(vapor::parse_port("1"), 1);
    EXPECT_EQ(vapor::parse_port("65535"), 65535);
}

TEST(ParsePort, RechazaPuertosNoValidos) {
    EXPECT_THROW(vapor::parse_port("0"), std::invalid_argument);
    EXPECT_THROW(vapor::parse_port("70000"), std::invalid_argument);
    EXPECT_THROW(vapor::parse_port("80a"), std::invalid_argument);
    EXPECT_THROW(vapor::parse_port("abc"), std::invalid_argument);
}
