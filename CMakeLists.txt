cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# ---- Project ----

get_filename_component(PROJ_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" PROJ_NAME ${PROJ_NAME})

# Note: update this to your new project's name and version
project(
  ${PROJ_NAME}
  VERSION 1.0
  LANGUAGES C CXX
)

# ---- Include guards ----

if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(
    FATAL_ERROR
      "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there."
  )
endif()

# ---- TODO(akalsi87) Documentation fixes ----

# ---- Add dependencies via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info

include(cmake/CPM.cmake)

# PackageProject.cmake will be used to make our target installable
CPMAddPackage("gh:TheLartians/PackageProject.cmake@1.8.0")

CPMAddPackage(
  NAME fmt
  GIT_TAG 7.1.3
  GITHUB_REPOSITORY fmtlib/fmt
  OPTIONS "FMT_INSTALL YES" # create an installable target
)

# cxxopts
CPMAddPackage(
  GITHUB_REPOSITORY jarro2783/cxxopts
  VERSION 2.2.1
  OPTIONS "CXXOPTS_BUILD_EXAMPLES NO" "CXXOPTS_BUILD_TESTS NO" "CXXOPTS_ENABLE_INSTALL YES"
)

# Dev dependencies
CPMAddPackage("gh:onqtam/doctest#2.4.5")
CPMAddPackage("gh:TheLartians/Format.cmake@1.7.0")

# ---- Enable testing ----

# Testing enablement

enable_testing()

# ---- Include target definition funcs ----
include(cmake/define-targets.cmake)

# ---- Create targets ----

define_lib(greeter "PRIVATE;fmt::fmt" "fmt 7.1.3")
define_exe(standalone "PUBLIC;greeter;cxxopts" "cxxopts 2.2.1")
