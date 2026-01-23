#ifndef DOCTEST_HPP
#define DOCTEST_HPP

#include <doctest/doctest.h>

#include "common.hpp"

#define REQUIRE_SUCCESS(s) \
  REQUIRE_MESSAGE((s) == SUCCESS, "Statement did not return SUCCESS.")

#endif  // DOCTEST_HPP
