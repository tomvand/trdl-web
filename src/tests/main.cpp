#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.hpp"

TEST_CASE("verify that doctest is working") {
  REQUIRE(1 == 1);
  REQUIRE_FALSE(1 == 0);
}
