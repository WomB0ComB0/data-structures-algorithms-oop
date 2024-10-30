add_executable(dsa_tests
    test_main.cpp
)

target_link_libraries(dsa_tests
    PRIVATE
    dsa_lib
    GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(dsa_tests)
