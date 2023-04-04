# Compile and test the generated code from process_model
# that links against fortran-tf-lib
cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
set(PROJECT_NAME GeneratedCodeTest)
project(${PROJECT_NAME} LANGUAGES Fortran)
enable_testing()

set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

#find_library(FORTRAN_TF_LIB
#    NAMES ${FORTRAN_TF_LIB_NAME}
#    HINTS ${FORTRAN_TF_LIB_DIR}
#    DOC "Location of fortran-tf-lib"
#    REQUIRED
#)

add_executable(test_fortran_tf_lib test_stub.F90)
target_link_libraries(test_fortran_tf_lib PRIVATE ${FORTRAN_TF_LIB})
target_include_directories(test_fortran_tf_lib PRIVATE ${FORTRAN_TF_LIB_DIR}/modules)
target_sources(test_fortran_tf_lib PRIVATE ${GENERATED_CODE_FILE})

add_test(
    NAME generated_code_1
    COMMAND test_fortran_tf_lib
)
set_tests_properties(generated_code_1 PROPERTIES
    PASS_REGULAR_EXPRESSION "SUCCESS")

