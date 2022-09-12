#
# CMakeLists.txt -- zip module
#
# Copyright (c) 2013-2018 David Demelier <markand@malikania.fr>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

cmake_minimum_required(VERSION 3.5)
project(zip VERSION 1.0.0)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${zip_SOURCE_DIR}/cmake)

find_package(ZIP REQUIRED)
include(GNUInstallDirs)


set(header_files
        zip.hpp
        )


add_library(libzippp INTERFACE)
add_library(libzippp::libzippp ALIAS libzippp)

target_compile_features(libzippp INTERFACE cxx_std_14)

target_link_libraries(libzippp INTERFACE ${ZIP_LIBRARIES})


target_include_directories(libzippp INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
        )

set(version_config "${CMAKE_CURRENT_BINARY_DIR}/libzipppVersion.cmake")
include(CMakePackageConfigHelpers)
write_basic_package_version_file("${version_config}"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
        )

install(
        TARGETS libzippp
        EXPORT libzipppTargets
        LIBRARY COMPONENT bin
        ARCHIVE COMPONENT dev
        NAMELINK_COMPONENT
        COMPONENT bin
)

install(FILES ${header_files} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/libzippp COMPONENT dev)

install(EXPORT libzipppTargets NAMESPACE libzippp:: DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/libzippp" COMPONENT dev)

install(FILES
        "cmake/libzipppConfig.cmake"
        "cmake/FindZIP.cmake"
        "${version_config}"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/libzippp" COMPONENT dev)




if (BUILD_DOCS)
    find_package(Doxygen QUIET)
endif ()

if (BUILD_TESTING)
    find_package(GTest REQUIRED)

    enable_testing()
    add_executable(
            zip-unittests
            ${zip_SOURCE_DIR}/test/main.cpp
            ${zip_SOURCE_DIR}/INSTALL.md
            ${zip_SOURCE_DIR}/LICENSE.md
            ${zip_SOURCE_DIR}/README.md
    )
    target_link_libraries(zip-unittests PRIVATE GTest::GTest GTest::gtest_main libzippp::libzippp)
    target_include_directories(zip-unittests PRIVATE ${zip_SOURCE_DIR} ${ZIP_INCLUDE_DIRS})
    target_compile_definitions(zip-unittests PRIVATE DIRECTORY=\"${zip_SOURCE_DIR}/test/data/\")
    add_test(NAME zip COMMAND zip-unittests)

    target_compile_options(zip-unittests PRIVATE -Wall -Wextra -std=c++14)
    if (CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(CMAKE_CXX_FLAGS "-Wall -Wextra -std=c++14 ${CMAKE_CXX_FLAGS}")
    endif ()
endif ()

if (DOXYGEN_FOUND)
    if (NOT DOXYGEN_DOT_FOUND)
        set(DOXYGEN_HAVE_DOT "NO")
        set(DOXYGEN_DOT_PATH "")
    else ()
        set(DOXYGEN_HAVE_DOT "YES")
        set(DOXYGEN_DOT_PATH "\"${DOXYGEN_DOT_EXECUTABLE}\"")
    endif ()

    configure_file(${zip_SOURCE_DIR}/doc/Doxyfile.in ${zip_BINARY_DIR}/Doxyfile)

    add_custom_target(
            doxygen ALL
            COMMAND ${DOXYGEN_EXECUTABLE} ${zip_BINARY_DIR}/Doxyfile
            SOURCES
            ${zip_SOURCE_DIR}/doc/Doxyfile.in
            ${zip_SOURCE_DIR}/doc/mainpage.cpp
            WORKING_DIRECTORY ${zip_SOURCE_DIR}
    )
endif ()
