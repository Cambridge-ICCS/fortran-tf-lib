# Test fixtures require CMake >= 3.7
cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
set(PROJECT_NAME FortranTensorFlow)
set(LIB_NAME fortran-tf)
set(PACKAGE_VERSION 0.1)

# The C is needed here so the FortranCInterface check can occur.  It's worth
# checking because we are linking to the Tensorflow C library
project(${PROJECT_NAME} VERSION ${PACKAGE_VERSION} LANGUAGES Fortran C)
enable_testing()

# Set default build type to Debug.
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
endif()

message(STATUS "Compiler is ${CMAKE_Fortran_COMPILER_ID}")
message(STATUS "Compiler is ${CMAKE_Fortran_COMPILER_VERSION}")
# require at least gfortran 9.0
# the library seems to *crash* gfortran 8.5.0 during compilation
# no known failures with Intel (tested down to 2016)
if("${CMAKE_Fortran_COMPILER_ID}" STREQUAL "GNU")
    if (CMAKE_Fortran_COMPILER_VERSION VERSION_LESS 9.0)
        message(FATAL_ERROR "gfortran version must be at least 9.0!")
    endif()
endif()

include(FortranCInterface)
FortranCInterface_VERIFY(QUIET)

# Set RPATH behaviour
set(CMAKE_SKIP_RPATH FALSE)
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
# Embed absolute paths to external libraries that are not part of
# the project, (they are expected to be at the same location on all
# machines the project will be deployed to
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Follow GNU conventions for installing directories
include(GNUInstallDirs)

# Define RPATH for executables via a relative expression to enable a
# fully relocatable package
file(RELATIVE_PATH relDir
 ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
 ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_INSTALL_RPATH $ORIGIN/${relDir})

# Tensorflow libraries
find_library(TF_LIB
    NAMES tensorflow
    HINTS ${TENSORFLOW_LOCATION} ${TENSORFLOW_LOCATION}/lib
    DOC "Location of tensorflow library"
)
if(NOT TF_LIB)
    message(FATAL_ERROR "Could not find libtensorflow.so")
endif()
list(APPEND TENSORFLOW_LIBRARIES ${TF_LIB})

find_library(TF_FRAMEWORK
    NAMES tensorflow_framework
    HINTS ${TENSORFLOW_LOCATION} ${TENSORFLOW_LOCATION}/lib
    DOC "Location of tensorflow framework library"
)
if(NOT TF_FRAMEWORK)
    message(FATAL_ERROR "Could not find libtensorflow_framework.so")
endif()
list(APPEND TENSORFLOW_LIBRARIES ${TF_FRAMEWORK})

# The source file(s).
add_library(${LIB_NAME} SHARED src/fortran_tensorflow_lib.F90)

add_library(${PROJECT_NAME}::${LIB_NAME} ALIAS ${LIB_NAME})
set_target_properties(${LIB_NAME} PROPERTIES
  VERSION ${PACKAGE_VERSION}
  Fortran_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/modules"
  )

target_link_libraries(${LIB_NAME} PRIVATE ${TENSORFLOW_LIBRARIES})
target_include_directories(${LIB_NAME}
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
#    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )
#
# Install library, create target file
install(TARGETS "${LIB_NAME}"
  EXPORT ${PROJECT_NAME}
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  PRIVATE_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${LIB_NAME}
  )

# Install target file
install(EXPORT ${PROJECT_NAME}
  FILE ${PROJECT_NAME}Config.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
  )

# Install Fortran module files
install(FILES "${CMAKE_BINARY_DIR}/modules/tf_interface.mod"
              "${CMAKE_BINARY_DIR}/modules/tf_types.mod"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${LIB_NAME}"
  )

# Fixture for tests
add_test(
    NAME process_model_exists
    COMMAND process_model --help
)
set_tests_properties(
    process_model_exists
    PROPERTIES FIXTURES_SETUP process_model
)

add_test(
    NAME process_model_output
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMAND process_model -o ${CMAKE_BINARY_DIR}/test_fortran_gen.F90 ${CMAKE_CURRENT_LIST_DIR}/my_model
)
set_tests_properties(
    process_model_output
    PROPERTIES FIXTURES_REQUIRED process_model
)
set_tests_properties(
    process_model_output
    PROPERTIES FIXTURES_SETUP process_model_output
)

# Executables for tests
add_executable(test_load_model_f tests/load_model_f.F90)
    target_link_libraries(test_load_model_f PRIVATE ${PROJECT_NAME}::${LIB_NAME})

add_test(
    NAME load_model_f
    COMMAND test_load_model_f
)
set_tests_properties(load_model_f PROPERTIES
    PASS_REGULAR_EXPRESSION "SUCCESS")

# Tests that require process_model_output
add_test(
    NAME process_model_1
    COMMAND ${CMAKE_CTEST_COMMAND}
        --build-and-test ${CMAKE_CURRENT_LIST_DIR}/tests/generated_code_test
                         ${CMAKE_CURRENT_BINARY_DIR}/tests/generated_code_test/build
        --build-generator ${CMAKE_GENERATOR}
        --test-command ${CMAKE_CTEST_COMMAND}
        --output-on-failure
        --build-options -DFORTRAN_TF_LIB=$<TARGET_FILE:${PROJECT_NAME}::${LIB_NAME}>
          -DFORTRAN_TF_LIB_DIR=${CMAKE_BINARY_DIR}
          -DGENERATED_CODE_FILE=${CMAKE_BINARY_DIR}/test_fortran_gen.F90
          -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
          -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
)
set_tests_properties(
    process_model_1
    PROPERTIES FIXTURES_REQUIRED process_model_output
)
