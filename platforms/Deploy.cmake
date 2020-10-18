MESSAGE(STATUS "Platform deploy to ${CMAKE_SYSTEM_NAME}")

set(ARTNETCONVERTER_PLATFORMS_DIR ${PROJECT_SOURCE_DIR}/platforms)

# Correctly link to static qt
get_target_property(QT_TARGET_TYPE Qt5::Core TYPE)
if(${QT_TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
  include(${PROJECT_SOURCE_DIR}/cmake/FetchQtStaticCMake.cmake)
  qt_generate_qml_plugin_import(${ARTNETCONVERTER_TARGET}
    QML_SRC ${PROJECT_SOURCE_DIR}/qml
    EXTRA_PLUGIN
      QtQuickVirtualKeyboardPlugin
      QtQuickVirtualKeyboardSettingsPlugin
      QtQuickVirtualKeyboardStylesPlugin
      QmlFolderListModelPlugin
      QQuickLayoutsPlugin
    VERBOSE
    )
  qt_generate_plugin_import(${ARTNETCONVERTER_TARGET} VERBOSE)
endif()

if(TARGET Qt5::QmlWorkerScript)
  target_link_libraries(${ARTNETCONVERTER_TARGET} PRIVATE Qt5::QmlWorkerScript)
endif()

# ──── WINDOWS ────

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")

  if(NOT ARTNETCONVERTER_BUILD_SHARED AND NOT ARTNETCONVERTER_BUILD_STATIC)

    # set output directories for all builds (Debug, Release, etc.)
    set_target_properties(${ARTNETCONVERTER_TARGET}
      PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>_Artifact"
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>_Artifact"
      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>"
      )

    include(${PROJECT_SOURCE_DIR}/cmake/FetchQtWindowsCMake.cmake)

    # Don't deploy when using static cmake since we are not using any qml file
    if(${QT_TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
      set(PLATFORM_NO_DEPLOY NO_DEPLOY)
    endif()

    add_qt_windows_exe(${ARTNETCONVERTER_TARGET}
      NAME "Artnet Converter"
      PUBLISHER "OlivierLDff"
      PRODUCT_URL "https://github.com/OlivierLDff/ArtnetConverter"
      PACKAGE "com.oliv.artnetconverter"
      ICON ${ARTNETCONVERTER_PLATFORMS_DIR}/windows/icon.ico
      ICON_RC ${ARTNETCONVERTER_PLATFORMS_DIR}/windows/icon.rc
      QML_DIR ${PROJECT_SOURCE_DIR}/qml
      NO_TRANSLATIONS
      VERBOSE_LEVEL_DEPLOY 1
      VERBOSE_INSTALLER
      ${PLATFORM_NO_DEPLOY}
    )

    if(MSVC)
      set_property(DIRECTORY ${PROJECT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${ARTNETCONVERTER_TARGET})
    endif()

  endif()
endif()

# ──── LINUX ────

if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")

  if(NOT ARTNETCONVERTER_BUILD_SHARED AND NOT ARTNETCONVERTER_BUILD_STATIC)

    # set output directories for all builds (Debug, Release, etc.)
    set_target_properties(${ARTNETCONVERTER_TARGET}
      PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>_Artifact"
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>_Artifact"
      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>"
      )

    include(${PROJECT_SOURCE_DIR}/cmake/FetchQtLinuxCMake.cmake)

    if(NOT ARTNETCONVERTER_IGNORE_ENV)
      set(ARTNETCONVERTER_ALLOW_ENVIRONMENT_VARIABLE "ALLOW_ENVIRONMENT_VARIABLE")
    endif()

    add_qt_linux_appimage(${ARTNETCONVERTER_TARGET}
      APP_DIR ${ARTNETCONVERTER_PLATFORMS_DIR}/linux/AppDir
      QML_DIR ${PROJECT_SOURCE_DIR}/qml
      NO_TRANSLATIONS
      ${ARTNETCONVERTER_ALLOW_ENVIRONMENT_VARIABLE}
      VERBOSE_LEVEL 1
    )

  endif()

endif()

# ──── MACOS ────

# ──── ANDROID ────

if(${CMAKE_SYSTEM_NAME} STREQUAL "Android")

  include(${PROJECT_SOURCE_DIR}/cmake/FetchQtAndroidCMake.cmake)

  # Set keystore variable
  # Should be set from cmake command line tool -DARTNETCONVERTER_ANDROID_KEYSTORE=...
  # -DARTNETCONVERTER_ANDROID_KEYSTORE_ALIAS=...
  # -DARTNETCONVERTER_ANDROID_KEYSTORE_PASSWORD=...
  if(ARTNETCONVERTER_ANDROID_KEYSTORE)
    SET(KEYSTORE_SIGNATURE
      KEYSTORE ${ARTNETCONVERTER_ANDROID_KEYSTORE} ${ARTNETCONVERTER_ANDROID_KEYSTORE_ALIAS}
      KEYSTORE_PASSWORD ${ARTNETCONVERTER_ANDROID_KEYSTORE_PASSWORD}
      KEY_PASSWORD ${ARTNETCONVERTER_ANDROID_KEY_PASSWORD}
      KEY_ALIAS ${ARTNETCONVERTER_ANDROID_ALIAS}
      )
  endif()

  add_qt_android_apk(${ARTNETCONVERTER_TARGET}Apk ${ARTNETCONVERTER_TARGET}
    NAME "Artnet Universe Converter"
    VERSION_NAME ${ARTNETCONVERTER_VERSION}
    VERSION_CODE 1
    PACKAGE_NAME "com.oliv.artnetconverter"
    PACKAGE_SOURCES  ${ARTNETCONVERTER_PLATFORMS_DIR}/android
    ${KEYSTORE_SIGNATURE}
    QML_DIR ${PROJECT_SOURCE_DIR}/qml
    )

endif()

# ──── WASM ────

if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
  include(${PROJECT_SOURCE_DIR}/cmake/FetchQtWasmCMake.cmake)
  add_qt_wasm_app(${ARTNETCONVERTER_TARGET} INITIAL_MEMORY 32MB)
endif()
