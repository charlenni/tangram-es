include(${CMAKE_SOURCE_DIR}/toolchains/iOS.toolchain.cmake)

add_definitions(-DPLATFORM_IOS)

set(FRAMEWORK_NAME TangramMap)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}
    -fobjc-abi-version=2
    -fobjc-arc
    -std=c++1y
    -stdlib=libc++
    -isysroot ${CMAKE_IOS_SDK_ROOT}")
set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}
    -fobjc-abi-version=2
    -fobjc-arc
    -isysroot ${CMAKE_IOS_SDK_ROOT}")

if(${IOS_PLATFORM} STREQUAL "SIMULATOR")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mios-simulator-version-min=6.0")
    set(ARCH "i386")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    set(ARCH "armv7 armv7s arm64")
endif()

set(FRAMEWORKS CoreGraphics CoreFoundation QuartzCore UIKit OpenGLES Security CFNetwork GLKit)

# load core library
add_subdirectory(${PROJECT_SOURCE_DIR}/external)
add_subdirectory(${PROJECT_SOURCE_DIR}/core)

set(SOURCES
    ${PROJECT_SOURCE_DIR}/core/common/platform_gl.cpp
    ${PROJECT_SOURCE_DIR}/ios/src/platform_ios.mm
    ${PROJECT_SOURCE_DIR}/ios/src/TGMapViewController.mm)

set(HEADERS
    ${PROJECT_SOURCE_DIR}/ios/src/platform_ios.h
    ${PROJECT_SOURCE_DIR}/ios/framework/TangramMap.h
    ${PROJECT_SOURCE_DIR}/ios/src/TGMapViewController.h)

set(FRAMEWORK_HEADERS
    ${PROJECT_SOURCE_DIR}/ios/framework/TangramMap.h
    ${PROJECT_SOURCE_DIR}/ios/src/TGMapViewController.h)

add_library(${FRAMEWORK_NAME} SHARED ${SOURCES} ${HEADERS})
target_link_libraries(${FRAMEWORK_NAME} "-all_load" ${CORE_LIBRARY})

#file(GLOB_RECURSE TANGRAM_BUNDLED_FONTS ${PROJECT_SOURCE_DIR}/scenes/fonts/**)
#message(STATUS "Bundled fonts " ${TANGRAM_BUNDLED_FONTS})
set(IOS_FRAMEWORK_RESOURCES ${PROJECT_SOURCE_DIR}/ios/framework/Info.plist)

set_target_properties(${FRAMEWORK_NAME} PROPERTIES
    CLEAN_DIRECT_OUTPUT 1
    FRAMEWORK TRUE
    FRAMEWORK_VERSION 1.0
    MACOSX_FRAMEWORK_IDENTIFIER com.Mapzen.TangramMap
    MACOSX_FRAMEWORK_INFO_PLIST ${PROJECT_SOURCE_DIR}/ios/framework/Info.plist
    VERSION 1.0.0
    SOVERSION 1.0.0
    PUBLIC_HEADER "${FRAMEWORK_HEADERS}"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    RESOURCE "${IOS_FRAMEWORK_RESOURCES}"
    )

macro(add_framework FWNAME APPNAME LIBPATH)
    find_library(FRAMEWORK_${FWNAME} NAMES ${FWNAME} PATHS ${LIBPATH} PATH_SUFFIXES Frameworks NO_DEFAULT_PATH)
    if(${FRAMEWORK_${FWNAME}} STREQUAL FRAMEWORK_${FWNAME}-NOTFOUND)
        message(ERROR ": Framework ${FWNAME} not found")
    else()
        target_link_libraries(${APPNAME} ${FRAMEWORK_${FWNAME}})
        message(STATUS "Framework ${FWNAME} found")
    endif()
endmacro(add_framework)

foreach(_framework ${FRAMEWORKS})
    add_framework(${_framework} ${FRAMEWORK_NAME} ${CMAKE_SYSTEM_FRAMEWORK_PATH})
endforeach()

