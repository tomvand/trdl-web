#ifndef COMMON_HPP
#define COMMON_HPP

#define NOEXCEPT noexcept
#define WARN_UNUSED __attribute__((warn_unused_result))

enum ResultValue {
  SUCCESS = 0,
  ERROR_NOT_IMPLEMENTED,
  ERROR_FULL,
  ERROR_DOMAIN,
  ERROR_INDEX,
  ERROR_STATE,
};

#define Result ResultValue WARN_UNUSED

#endif