# The Fortran to TensorFlow library

A Fortran to tensorflow library implementing the bare minimum of the TensorFlow
C API.  There is enough to load and infer any TensorFlow model from Fortran.

## Building

You'll need the TensorFlow C API, download from
https://www.tensorflow.org/install/lang_c.  I've only tested the CPU one.
Newer versions may be available if you change the download URL.  Install this
somewhere (e.g. `/path/to/tf_c_api`) such that:

```
$ ls <path/to/tf_c_api>
include  lib  LICENSE  THIRD_PARTY_TF_C_LICENSES
```

The build system uses [CMake](https://cmake.org/).  Create a build directory, `cd` to it
and run `cmake <directory>`.  A common pattern is to create the build directory in the same directory
as the `CMakeLists.txt` file, `cd` to it, and run `cmake ..`.

```
$ ls
CMakeLists.txt  my_model  README.md  src  tests
$ mkdir build
$ cd build
$ cmake ..
```

CMake will attempt to find Fortran and C compilers, and the TensorFlow library.
You will probably need to help it find the latter by passing the
`-DTENSORFLOW_LOCATION` variable to cmake.  You can also override its choice of
compilers with `-DCMAKE_Fortran_COMPILER` and `-DCMAKE_C_COMPILER`.  It's best
to not mix compilers from different vendors, so if you plan on linking this
code to one built with a particular compiler set, use that.  You may also
specify where the library is to be installed with `-DCMAKE_INSTALL_PREFIX`.  So
a full invocation of `cmake` might look like this:

```
cmake .. -DTENSORFLOW_LOCATION=/path/to/tf_c_api -DCMAKE_Fortran_COMPILER=ifort -DCMAKE_C_COMPILER=icc -DCMAKE_INSTALL_PREFIX=/path/to/fortran-tf-lib
```

By default the build will be a Debug one.  You can set one of the other CMake
standard build types, such as Release or RelWithDebInfo (Release with Debug
info) with e.g. `-DCMAKE_BUILD_TYPE=Release`.

## Using the library

### Using `process_model`

There are some issues with the TensorFlow C API.  In particular, it is not
possible to load a model from disk without knowing certain parameters of the
model.  It is also necessary to know other parameters to infer.  The API seems
to expect the user to be using `protobuf` to query the saved model directly to
determine the parameters.  This would add a large level of complexity to a
Fortran library.  Alternatively the user can get the parameters from the model
using the TensorFlow `saved_model_cli` tool to query it for the tags and input
and output operation names and indices.  The user would then hard-code these
values into their calls into the library.

To ease this process we provide a utility `process_model` that examines a saved
TensorFlow model and outputs a Fortran module to interface to it.  The module
exports an `init` procedure, a `calc` procedure, a `finish` procedure, and
a set of routines to associate TensorFlow tensors with Fortran arrays.

### Using the library directly

Currently this is only documented in the test case.

## Add the library to a CMake build system
Make sure the `CMAKE_PREFIX_PATH` points to wherever you installed the
library.  Alternatively you can set pass an option to cmake
`-DFortranTensorFlow_DIR=<path>`, where path is the location where the
`FortranTensorFlowConfig.cmake` file is located.  This is usually in
`CMAKE_INSTALL_PREFIX/lib64/cmake`.

Then in the `CMakeLists.txt` file of the project you want to add the library to
add lines like:
```
find_package(FortranTensorFlow)
target_link_libraries(foo FortranTensorFlow::fortran-tf)
```
This should add the library to the target (`foo` here) and automatically add
the Fortran module directory to its compile steps.
