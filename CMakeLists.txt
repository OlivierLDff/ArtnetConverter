#
#   ArtnetConverter CMake script by Olivier Le Doeuff
#

# ┌──────────────────────────────────────────────────────────────────┐
# │                       CMAKE PROPERTIES                           │
# └──────────────────────────────────────────────────────────────────┘

cmake_minimum_required(VERSION 3.14.0 FATAL_ERROR)

# ┌──────────────────────────────────────────────────────────────────┐
# │                       PROJECT SETTINGS                           │
# └──────────────────────────────────────────────────────────────────┘

set(ARTNETCONVERTER_PROJECT "ArtnetConverter" CACHE STRING "Qaterial Gallery Project Name")

# ┌──────────────────────────────────────────────────────────────────┐
# │                       VERSION                                    │
# └──────────────────────────────────────────────────────────────────┘

# Project version must be set here
set(ARTNETCONVERTER_VERSION_MAJOR 1)
set(ARTNETCONVERTER_VERSION_MINOR 0)
set(ARTNETCONVERTER_VERSION_PATCH 0)
set(ARTNETCONVERTER_VERSION ${ARTNETCONVERTER_VERSION_MAJOR}.${ARTNETCONVERTER_VERSION_MINOR}.${ARTNETCONVERTER_VERSION_PATCH})

project(${ARTNETCONVERTER_PROJECT} VERSION ${ARTNETCONVERTER_VERSION} LANGUAGES CXX)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(ARTNETCONVERTER_TARGET ${ARTNETCONVERTER_PROJECT} CACHE STRING "Qaterial Gallery Target Name")
if(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
  set(ARTNETCONVERTER_BUILD_SHARED ON CACHE BOOL "Build as a shared library (Default for Android build)" FORCE)
else()
  set(ARTNETCONVERTER_BUILD_SHARED OFF CACHE BOOL "Build as a shared library")
endif()
set(ARTNETCONVERTER_BUILD_STATIC OFF CACHE BOOL "Build as a static library")

set(ARTNETCONVERTER_IGNORE_ENV OFF CACHE BOOL "The executable will discard system qt, and will try to use qt binary deploy along the target. Should be ON when deploying installer")

# ┌──────────────────────────────────────────────────────────────────┐
# │                       DEPENDENCIES                               │
# └──────────────────────────────────────────────────────────────────┘

find_package(Qt5 REQUIRED COMPONENTS
  Core
  Qml
  Gui
  Quick
  QuickControls2
  Svg
  Xml
  QuickCompiler
)
find_package(Qt5 QUIET COMPONENTS QmlWorkerScript)

include(cmake/Dependencies.cmake)
include(cmake/FetchSpdlog.cmake)
include(cmake/FetchQaterial.cmake)

# ┌──────────────────────────────────────────────────────────────────┐
# │                       STATUS                                     │
# └──────────────────────────────────────────────────────────────────┘

# ─── GLOBAL ────

message(STATUS "------ ${ARTNETCONVERTER_TARGET} v${ARTNETCONVERTER_VERSION} Configuration ------")
message(STATUS "ARTNETCONVERTER_BUILD_SHARED           : ${ARTNETCONVERTER_BUILD_SHARED}")
message(STATUS "ARTNETCONVERTER_BUILD_STATIC           : ${ARTNETCONVERTER_BUILD_STATIC}")
message(STATUS "ARTNETCONVERTER_IGNORE_ENV             : ${ARTNETCONVERTER_IGNORE_ENV}")
message(STATUS "------ ${ARTNETCONVERTER_TARGET} End Configuration ------")

# ──── CHECK CONFLICT ────

if(ARTNETCONVERTER_BUILD_SHARED AND ARTNETCONVERTER_BUILD_STATIC)
    message(FATAL_ERROR "ArtnetConverter can't compile shared and static library at the same time")
endif()

# ┌──────────────────────────────────────────────────────────────────┐
# │                       SOURCES                                    │
# └──────────────────────────────────────────────────────────────────┘

qt_generate_qmldir(ARTNETCONVERTER_QMLDIR_FILE
 SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qml/ArtnetConverter
 MODULE "ArtnetConverter")

qt_generate_qrc(ARTNETCONVERTER_QML_QRC
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qml/ArtnetConverter
  DEST_DIR ${CMAKE_CURRENT_BINARY_DIR}/ArtnetConverterGenerated
  NAME ArtnetConverter.qrc
  PREFIX "ArtnetConverter"
  GLOB_EXPRESSION "*.qml;qmldir"
  ALWAYS_OVERWRITE
  RECURSE)

qt_generate_qrc(ARTNETCONVERTER_RES_QML_QRC
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/qml/ArtnetConverter
  DEST_DIR ${CMAKE_CURRENT_BINARY_DIR}/ArtnetConverterGenerated
  NAME ArtnetConverterRes.qrc
  PREFIX "ArtnetConverter"
  GLOB_EXPRESSION "*.png;*svg"
  ALWAYS_OVERWRITE
  RECURSE)

qtquick_compiler_add_resources(ARTNETCONVERTER_QML_RES ${ARTNETCONVERTER_QML_QRC})
file(GLOB_RECURSE ARTNETCONVERTER_QML_SRCS qml/ArtnetConverter/*.qml)
source_group("Qml" FILES "${ARTNETCONVERTER_QML_SRCS}")

set(ARTNETCONVERTER_SRCS
  ${CMAKE_CURRENT_SOURCE_DIR}/src/Main.cpp
  ${ARTNETCONVERTER_QML_RES}
  ${ARTNETCONVERTER_RES_QML_QRC}
)

# Dont Run Moc on cpp file generated from qml
foreach(GENERATED_RES ${ARTNETCONVERTER_QML_RES})
  set_property(SOURCE ${GENERATED_RES} PROPERTY SKIP_AUTOMOC ON)
  source_group("QtQuickCompiler Files" FILES ${GENERATED_RES})
endforeach()

# ──── TARGET ────

if(ARTNETCONVERTER_BUILD_SHARED)
  add_library(${ARTNETCONVERTER_TARGET} SHARED ${ARTNETCONVERTER_SRCS})
  target_compile_definitions(${ARTNETCONVERTER_TARGET} PRIVATE -DARTNETCONVERTER_SHARED)
else()
  if(ARTNETCONVERTER_BUILD_STATIC)
    add_library(${ARTNETCONVERTER_TARGET} STATIC ${ARTNETCONVERTER_SRCS})
  else()
    add_executable(${ARTNETCONVERTER_TARGET} ${ARTNETCONVERTER_SRCS})
  endif()
  target_compile_definitions(${ARTNETCONVERTER_TARGET} PUBLIC -DARTNETCONVERTER_STATIC)
endif()

# ──── SETTINGS ────

target_compile_features(${ARTNETCONVERTER_TARGET} PUBLIC cxx_std_11)

if(ARTNETCONVERTER_IGNORE_ENV)
  target_compile_definitions(${ARTNETCONVERTER_TARGET} PRIVATE -DARTNETCONVERTER_IGNORE_ENV)
endif()

# ──── DEPENDENCIES ────

set_target_properties(${ARTNETCONVERTER_TARGET} PROPERTIES
  AUTOMOC TRUE
  AUTORCC TRUE)
target_link_libraries(${ARTNETCONVERTER_TARGET} PRIVATE
  Qaterial
  spdlog
)

# ────────── POST BUILD PLATFORM DEPENDANCIES ─────────────

include(platforms/Deploy.cmake)