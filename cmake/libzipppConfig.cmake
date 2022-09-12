include(CMakeFindDependencyMacro)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})

find_dependency(ZIP REQUIRED)

include("${CMAKE_CURRENT_LIST_DIR}/libzipppTargets.cmake")