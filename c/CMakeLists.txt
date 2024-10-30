cmake_minimum_required(VERSION 3.10)
project(DSA_C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

include(FetchContent)
FetchContent_Declare(
    unity
    GIT_REPOSITORY https://github.com/ThrowTheSwitch/Unity.git
    GIT_TAG v2.5.2
)
FetchContent_MakeAvailable(unity)

add_library(dsa_lib INTERFACE)
target_include_directories(dsa_lib INTERFACE include)

add_executable(dsa_main src/main.c)
target_link_libraries(dsa_main PRIVATE dsa_lib)

enable_testing()
add_subdirectory(tests)
