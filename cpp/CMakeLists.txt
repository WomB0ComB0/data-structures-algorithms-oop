cmake_minimum_required(VERSION 3.10)
project(DSA_CPP)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
FetchContent_MakeAvailable(googletest)

add_library(dsa_lib INTERFACE)
target_include_directories(dsa_lib INTERFACE include)

add_executable(dsa_main src/main.cpp)
target_link_libraries(dsa_main PRIVATE dsa_lib)

enable_testing()
add_subdirectory(tests)
