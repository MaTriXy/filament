# Toolchain config for iOS.
#
# Usage:
# mkdir build; cd build
# cmake ..; make
# mkdir ios; cd ios
# cmake -DLLVM_IOS_TOOLCHAIN_DIR=/path/to/ios/ndk \
#   -DCMAKE_TOOLCHAIN_FILE=../../cmake/platforms/iOS.cmake ../..
# make <target>

set(CMAKE_OSX_ARCHITECTURES ${IOS_ARCH} CACHE STRING "Build architecture for iOS")

# Necessary for correct install location
set(DIST_ARCH ${IOS_ARCH})

add_definitions(-DFILAMENT_IOS)

set(IOS_MIN_TARGET "11.0")

if(PLATFORM_NAME STREQUAL "iphonesimulator")
    add_definitions(-DFILAMENT_IOS_SIMULATOR)
    # The simulator only supports iOS >= 13.0
    set(IOS_MIN_TARGET "13.0")
endif()

SET(CMAKE_SYSTEM_NAME Darwin)
SET(CMAKE_SYSTEM_VERSION 13)
SET(CMAKE_CXX_COMPILER_WORKS True)
SET(CMAKE_C_COMPILER_WORKS True)
SET(DARWIN_TARGET_OS_NAME ios)

SET(PLATFORM_NAME "iphoneos" CACHE STRING "iOS platform to build for")
SET(PLATFORM_FLAG_NAME ios)

IF("$ENV{RC_APPLETV}" STREQUAL "YES")
  MESSAGE(STATUS "Building for tvos")
  STRING(TOLOWER $ENV{RC_APPLETV_PLATFORM_NAME} PLATFORM_NAME)
  SET(PLATFORM_FLAG_NAME tvos)
ENDIF()

IF("$ENV{RC_WATCH}" STREQUAL "YES")
  MESSAGE(STATUS "Building for watchos")
  STRING(TOLOWER $ENV{RC_WATCH_PLATFORM_NAME} PLATFORM_NAME)
  STRING(TOLOWER $ENV{RC_WATCH_PLATFORM_NAME} PLATFORM_FLAG_NAME)
ENDIF()

IF(NOT DEFINED ENV{SDKROOT})
 execute_process(COMMAND xcodebuild -version -sdk ${PLATFORM_NAME} Path
   OUTPUT_VARIABLE SDKROOT
   ERROR_QUIET
   OUTPUT_STRIP_TRAILING_WHITESPACE)
ELSE()
  execute_process(COMMAND xcodebuild -version -sdk $ENV{SDKROOT} Path
   OUTPUT_VARIABLE SDKROOT
   ERROR_QUIET
   OUTPUT_STRIP_TRAILING_WHITESPACE)
ENDIF()

IF(NOT EXISTS ${SDKROOT})
  MESSAGE(FATAL_ERROR "SDKROOT could not be detected!")
ENDIF()

set(CMAKE_OSX_SYSROOT ${SDKROOT})

IF(NOT CMAKE_C_COMPILER)
  execute_process(COMMAND xcrun -sdk ${SDKROOT} -find clang
   OUTPUT_VARIABLE CMAKE_C_COMPILER
   ERROR_QUIET
   OUTPUT_STRIP_TRAILING_WHITESPACE)
  message(STATUS "Using c compiler ${CMAKE_C_COMPILER}")
ENDIF()

IF(NOT CMAKE_CXX_COMPILER)
  execute_process(COMMAND xcrun -sdk ${SDKROOT} -find clang++
   OUTPUT_VARIABLE CMAKE_CXX_COMPILER
   ERROR_QUIET
   OUTPUT_STRIP_TRAILING_WHITESPACE)
  message(STATUS "Using c compiler ${CMAKE_CXX_COMPILER}")
ENDIF()

IF(NOT CMAKE_AR)
  execute_process(COMMAND xcrun -sdk ${SDKROOT} -find ar
   OUTPUT_VARIABLE CMAKE_AR_val
   ERROR_QUIET
   OUTPUT_STRIP_TRAILING_WHITESPACE)
  SET(CMAKE_AR ${CMAKE_AR_val} CACHE FILEPATH "Archiver")
  message(STATUS "Using ar ${CMAKE_AR}")
ENDIF()

IF(NOT CMAKE_RANLIB)
  execute_process(COMMAND xcrun -sdk ${SDKROOT} -find ranlib
   OUTPUT_VARIABLE CMAKE_RANLIB_val
   ERROR_QUIET
   OUTPUT_STRIP_TRAILING_WHITESPACE)
  SET(CMAKE_RANLIB ${CMAKE_RANLIB_val} CACHE FILEPATH "Ranlib")
  message(STATUS "Using ranlib ${CMAKE_RANLIB}")
ENDIF()

IF (NOT DEFINED IOS_MIN_TARGET)
  execute_process(COMMAND xcodebuild -sdk ${SDKROOT} -version SDKVersion
   OUTPUT_VARIABLE IOS_MIN_TARGET
   ERROR_QUIET
   OUTPUT_STRIP_TRAILING_WHITESPACE)
ENDIF()

SET(IOS_COMMON_FLAGS "-m${PLATFORM_FLAG_NAME}-version-min=${IOS_MIN_TARGET}")

SET(CMAKE_C_FLAGS_INIT "${IOS_COMMON_FLAGS}")
SET(CMAKE_CXX_FLAGS_INIT "${IOS_COMMON_FLAGS}")
SET(CMAKE_ASM_FLAGS_INIT "${IOS_COMMON_FLAGS}")
