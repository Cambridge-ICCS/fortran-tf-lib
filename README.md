# Fortran-TF-lib

![GitHub](https://img.shields.io/github/license/Cambridge-ICCS/fortran-tf-lib)

Code and examples for directly calling Tensorflow ML models from Fortran.  
For calling *PyTorch* from Fortran see the [FTorch repository](https://github.com/Cambridge-ICCS/fortran-pytorch-lib).

## Contents
- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [License](#license)
- [Contributions](#contributions)
- [Authors and Acknowledgment](#authors-and-acknowledgment)
- [Users](#used-by)

## Description

It is desirable be able to run machine learning (ML) models directly in Fortran.
Such models are often trained in some other language (say Python) using popular frameworks (say TensorFlow) and saved.
We want to run inference on this model without having to call a Python executable.
To achieve this we use the existing TensorFlow C interface.

This project provides a library enabling a user to directly couple their TensorFlow models to Fortran code.
We provide installation instructions for the library as well as instructions and examples for performing coupling.
This library implements only enough of the TensorFlow C API to allow inference, no training.

Project status: This project is currently in pre-release with documentation and code being prepared for a first release.
As such breaking changes may be made.
If you are interested in using this library please get in touch.


## Installation

### Dependencies

To install the library requires the following to be installed on the system:

* cmake >= 3.1
* TensorFlow C API, download from <https://www.tensorflow.org/install/lang_c><sup>1</sup>
* Fortran and C compilers

<sup>1</sup> Note that this page sometimes does not list the latest version of
the library.  You can try altering the library download URLs on the page to
reflect the newest version.  E.g. if the URL ends `...-2.11.tar.gz` try
changing it to `...-2.13.tar.gz`.

### Library installation

To build and install the library:

1. Navigate to the location in which you wish to install the source and run:  
    ```
    git clone git@github.com:Cambridge-ICCS/fortran-tf-lib.git
    ```
    to clone via ssh, or  
    ```
    git clone https://github.com/Cambridge-ICCS/fortran-tf-lib.git
    ```
    to clone via https.  
2. Navigate into the library directory by running:  
    ```
    cd fortran-tf-lib/fortran-tf-lib/
    ```
3. Create a `build` directory and execute cmake from within it using the relevant flags:  
    ```
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    ```
    It is likely that you will need to provide at least the `TENSORFLOW_LOCATION` flag.  
    The Fortran compiler must be the same one that you are planning to compile your Fortran
    code with.  It is advisable to use C and Fortran compilers from the same provider.

    The following CMake flags are available and can be passed as arguments through `-D<Option>=<Value>`:
    | Option                                                                                            | Value                        | Description                                                   |
    | ------------------------------------------------------------------------------------------------- | ---------------------------- | --------------------------------------------------------------|
    | [`CMAKE_Fortran_COMPILER`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html) | `ifort` / `gfortran`         | Specify a Fortran compiler to build the library with. This should match the Fortran compiler you're using to build the code you are calling this library from.        |
    | [`CMAKE_C_COMPILER`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html)       | `icc` / `gcc`                | Specify a C compiler to build the library with.                |
    | `TENSORFLOW_LOCATION`<sup>2</sup>   | `</path/to/tensorflow/>`          | Location of TensorFlow C API installation<sup>1</sup>. |
    | [`CMAKE_INSTALL_PREFIX`](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html)  | `</path/to/install/lib/at/>` | Location at which the library files should be installed. By default this is `/usr/local`. |
    | [`CMAKE_BUILD_TYPE`](https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html)          | `Release` / `Debug`          | Specifies build type. The default is `Debug`, use `Release` for production code.|

    <sup>2</sup> This should be the absolute path to where the TensorFlow C API mentioned in step 1 has been installed. CMake will look in `TENSORFLOW_LOCATION` and `TENSORFLOW_LOCATION/lib` for the TensorFlow library `libtensorflow.so`.
4. Make and install the code to the chosen location with:
    ```
    make
    make install
    ```
    This will place the following directories at the install location:  
    * `CMAKE_INSTALL_PREFIX/include/` - contains mod files
    * `CMAKE_INSTALL_PREFIX/lib64/` - contains `cmake` directory and `.so` files


## Usage

In order to use fortran-tf users will typically need to follow these steps:

1. Save a TensorFlow model in the Keras SavedModel format.
2. Write Fortran using the fortran-tf-lib bindings to use the model from within Fortran.
3. Build and compile the code, linking against fortran-tf-lib.


### 1. Saving the model

The trained model needs to be exported.  This can be done from within your code
using the
[`model.save`](https://www.tensorflow.org/guide/keras/serialization_and_saving)
functionality from within python.  Note that the TensorFlow C API currently
(version 2.13) only supports the Keras "v2" format so you must specify `format='tf'`:
```
import tensorflow as tf
# construct model (e.g. model=tf.keras.Model(inputs, outputs))
# or load one (e.g. model=tf.keras.models.load_model('/path/to/model'))
model.save("my_model", format='tf')
```

### 2. Using the model from Fortran

To use the trained TensorFlow model from within Fortran we need to import the
`TF_Interface` module and use the binding routines to load the model, construct
the tensors, and run inference.

A very simple example is given below.  For more detailed documentation please
consult the API documentation, source code, and examples.

This minimal snippet loads a saved TensorFlow model, creates an input consisting of
a `1x32` matrix (with arbitrary values), and runs the model to infer the
output.  If you use the model provided in the test case this code will produce
the indicated output value.

```fortran
program test_program
use TF_Types
use TF_Interface
use iso_c_binding
implicit none

type(TF_Session) :: session
type(TF_SessionOptions) :: sessionoptions
type(TF_Graph) :: graph
type(TF_Status) :: stat
type(TF_Output), dimension(1) :: input_tfoutput, output_tfoutput
character(100) :: vers
character(100), dimension(1) :: tags
type(TF_Tensor), dimension(1) :: input_tensors, output_tensors, test_tensor
type(TF_Operation), dimension(1) :: target_opers

real, dimension(32), target :: raw_data
real, dimension(:), pointer :: output_data_ptr
integer(kind=c_int64_t), dimension(2) :: input_dims
integer(kind=c_int64_t), dimension(2) :: output_dims
type(c_ptr) :: raw_data_ptr
type(c_ptr) :: output_c_data_ptr

raw_data = (/ &
        0.71332126, 0.81275973, 0.66596436, 0.79570779, 0.83973302, 0.76604397, &
        0.84371391, 0.92582056, 0.32038017, 0.0732005, 0.80589203, 0.75226581, &
        0.81602784, 0.59698078, 0.32991729, 0.43125108, 0.4368422, 0.88550326, &
        0.7131253, 0.14951148, 0.22084413, 0.70801317, 0.69433906, 0.62496564, &
        0.50744999, 0.94047845, 0.18191579, 0.2599102, 0.53161889, 0.57402205, &
        0.50751284, 0.65207096 &
        /)


input_dims = (/ 1, 32 /)
output_dims = (/ 1, 1 /)
tags(1) = 'serve'

! Print TensorFlow library version
call TF_Version(vers)
write(*,*)'Tensorflow version', vers

sessionoptions = TF_NewSessionOptions()
graph = TF_NewGraph()
stat = TF_NewStatus()

! Load session (also populates graph)
session = TF_LoadSessionFromSavedModel(sessionoptions, '/path/to/model', tags, 1, &
    graph, stat)

if (TF_GetCode( stat ) .ne. TF_OK) then
    call TF_Message( stat, vers )
    write(*,*)'woops', TF_GetCode( stat ), vers
    call abort
endif

call TF_DeleteSessionOptions(sessionoptions)

input_tfoutput(1)%oper = TF_GraphOperationByName( graph, "serving_default_input_1" )
input_tfoutput(1)%index = 0
if (.not.c_associated(input_tfoutput(1)%oper%p)) then
    write(*,*)'input not associated'
    stop
endif

output_tfoutput(1)%oper = TF_GraphOperationByName( graph, "StatefulPartitionedCall" )
output_tfoutput(1)%index = 0
if (.not.c_associated(output_tfoutput(1)%oper%p)) then
    write(*,*)'output not associated'
    stop
endif

! Bind the input tensor
raw_data_ptr = c_loc(raw_data)
input_tensors(1) = TF_NewTensor( TF_FLOAT, input_dims, 2, raw_data_ptr, int(128, kind=c_size_t) )

! Run inference
call TF_SessionRun( session, input_tfoutput, input_tensors, 1, output_tfoutput, output_tensors, 1, &
    target_opers, 0, stat )
if (TF_GetCode( stat ) .ne. TF_OK) then
    call TF_Message( stat, vers )
    write(*,*) TF_GetCode( stat ), vers
    call abort
endif

! Bind output tensor
call c_f_pointer( TF_TensorData( output_tensors(1)), output_data_ptr, shape(output_data_ptr) )
write(*,*)'output data', output_data_ptr(1)

if ((output_data_ptr(1) - -0.479371) .gt. 1e-6) then
    write(*,*)'Output does not match, FAILED!'
else
    write(*,*)'Output is correct, SUCCESS!'
endif


! Clean up
call TF_DeleteTensor( input_tensors(1) )
call TF_DeleteTensor( output_tensors(1) )
call TF_DeleteGraph( graph )
call TF_DeleteSession( session, stat )
call TF_DeleteStatus( stat )

end program test_program
```
#### Generating code with `process_model`
The example code above illustrates a problem with the TensorFlow C API
that our Fortran wrapper cannot fix.  To load a model, the library requires
that the caller knows certain rather opaque model parameters beforehand.
Often, the values in the example above will work for the `tags` parameter
to `TF_LoadSessionFromSavedModel`.  However, the values needed for
`TF_GraphOperationByName` (in this case `serving_default_input_1`, etc)
are more likely to be different.

To address this, we provide a Python script, `process_model` that will
read a Keras SavedModel and output a simple Fortran module intended to
provide a base for the user to start from.  The appropriate values will
be read from the model and hard-coded into the Fortran code.

E.g.
```
process_model -o fortran_code.f90  my_model
```

### 3. Build the code

The code now needs to be compiled and linked against our installed library.

#### CMake
If our project were using cmake we would need the following in the
`CMakeLists.txt` file to find the the tf-lib installation and link it to the
executable.

This can be done by adding the following to the `CMakeLists.txt` file:
```
find_package(FortranTensorFlow)
target_link_libraries( <executable> PRIVATE FortranTensorFlow::fortran-tf )
message(STATUS "Building with Fortran TensorFlow coupling")
```
and using the `-DCMAKE_PREFIX=</path/to/fortran-tf-libs/lib64/cmake>` flag when running cmake.

When running the generated code you may also need to add the location of the
`.so` files to your `LD_LIBRARY_PATH` unless installing in a default location:
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path/to/fortran-tf-libs>/lib64
```

## Examples

Examples of how to use this library will be provided in the [examples directory](examples/).  
They demonstrate different functionalities and are provided with instructions to modify, build, and run as necessary.

## License

Copyright &copy; ICCS

*Fortran-TF-Lib* is distributed under the [MIT Licence](https://github.com/Cambridge-ICCS/fortran-tf-lib/blob/main/LICENSE).


## Contributions

Contributions and collaborations are welcome.

For bugs, feature requests, and clear suggestions for improvement please
[open an issue](https://github.com/Cambridge-ICCS/fortran-tf-lib/issues).

If you have built something upon _Fortran-TF-Lib_ that would be useful to others, or can
address an [open issue](https://github.com/Cambridge-ICCS/fortran-tf-lib/issues), please
[fork the repository](https://github.com/Cambridge-ICCS/fortran-tf-lib/fork) and open a
pull request.


### Code of Conduct
Everyone participating in the _Fortran-TF-Lib_ project, and in particular in the
issue tracker, pull requests, and social media activity, is expected to treat other
people with respect and, more generally, to follow the guidelines articulated in the
[Python Community Code of Conduct](https://www.python.org/psf/codeofconduct/).


## Authors and Acknowledgment

*Fortran-TF-Lib* is written and maintained by the [ICCS](https://github.com/Cambridge-ICCS)

Notable contributors to this project are:

* [**@SimonClifford**](https://github.com/SimonClifford)

See [Contributors](https://github.com/Cambridge-ICCS/fortran-tf-lib/graphs/contributors)
for a full list.


## Used by
The following projects make use of this code or derivatives in some way:

* [DataWave - MiMA ML](https://github.com/DataWaveProject/MiMA-machine-learning)

Are we missing anyone? Let us know.



