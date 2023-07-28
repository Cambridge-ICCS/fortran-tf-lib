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
To achieve this we use the existing ML C interface.

This project provides a library enabling a user to directly couple their TensorFlow models to Fortran code.
We provide installation instructions for the library as well as instructions and examples for performing coupling.

Project status: This project is currently in pre-release with documentation and code being prepared for a first release.
As such breaking changes may be made.
If you are interested in using this library please get in touch.


## Installation

### Dependencies sjc306

To install the library requires the following to be installed on the system:

* cmake >= 3.1
* Keras or C distribution of [TensorFlow](https://www.tensorflow.org/)
* Fortran and C compilers

### Library installation sjc306

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
2. Navigate into the library source directory by running:  
    ```
    cd fortran-tf-lib/fortran-tf-lib/
    ```
3. Create a `build` directory and execute cmake from within it using the relevant flags:  
    ```
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    ```
    It is likely that you will need to provide at least the `CMAKE_PREFIX_PATH` flag.  
    The following CMake flags are available and can be passed as arguments through `-D<Option>=<Value>`:
    | Option                                                                                            | Value                        | Description                                                   |
    | ------------------------------------------------------------------------------------------------- | ---------------------------- | --------------------------------------------------------------|
    | [`CMAKE_Fortran_COMPILER`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html) | `ifort` / `gfortran`         | Specify a Fortran compiler to build the library with. This should match the Fortran compiler you're using to build the code you are calling this library from.        |
    | [`CMAKE_C_COMPILER`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html)       | `icc` / `gcc`                | Specify a C compiler to build the library with                |
    | [`CMAKE_CXX_COMPILER`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html)     | `icc` / `gcc`                | Specify a C++ compiler to build the library with              |
    | [`CMAKE_PREFIX_PATH`](https://cmake.org/cmake/help/latest/variable/CMAKE_PREFIX_PATH.html)        | `</path/to/keras/>`          | Location of Keras installation<sup>1</sup> |
    | [`CMAKE_INSTALL_PREFIX`](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html)  | `</path/to/install/lib/at/>` | Location at which the library files should be installed. By default this is `/usr/local` |
    | [`CMAKE_BUILD_TYPE`](https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html)          | `Release` / `Debug`          | Specifies build type. The default is `DEBUG`, use `RELEASE` for production code|

    <sup>1</sup> _The path to the Keras installation needs to allow cmake to locate the relevant Keras cmake files.  
          If Keras has been installed as C source or binaries
          then this should be the absolute path to the Keras distribution.
          If Keras has been installed as TensorFlow through Python in a [venv (virtual environment)](https://docs.python.org/3/library/venv.html),
          e.g. with `pip install tensorflow`, then this should be `</path/to/venv/>lib/python<3.xx>/site-packages/sjc306/`._
4. Make and install the code to the chosen location with:
    ```
    make
    make install
    ```
    This will place the following directories at the install location:  
    * `include/` - contains header and mod files
    * `lib64/` - contains cmake and `.so` files


## Usage sjc306

In order to use fortran-tf users will typically need to follow these steps:

1. Save a Keras model as something.
2. Something with processmodel?
3. Write Fortran using the fortran-tf-lib bindings to use the model from within Fortran.
4. Build and compile the code, linking against fortran-tf-lib


### 1. Saving the model

The trained Keras model needs to be exported.
This can be done from within your code using the [`relevant function`](RLHTTPS://PYTORCH.ORG/DOCS/STABLE/GENERATED/TORCH.JIT.SCRIPT.HTML#TORCH.JIT.SCRIPT) functionality from within python.

### 2. Using the model from Fortran

To use the trained Torch model from within Fortran we need to import the `library name` module and use the binding routines to load the model, convert the data, and run inference.

A very simple example is given below.
For more detailed documentation please consult the API documentation, source code, and examples.

This minimal snippet loads a saved Torch model, creates inputs consisting of two `10x10` matrices (one of ones, and one of zeros), and runs the model to infer output.

sjc306 re-write source below to reflect tf-lib
```fortran
! Import any C bindings as required for this code
use, intrinsic :: iso_c_binding, only: c_int, c_int64_t, c_null_char, c_loc
! Import library for interfacing with PyTorch
use ftorch

implicit none

! Generate an object to hold the Torch model
type(torch_module) :: model

! Set up types of input and output data and the interface with C
integer(c_int), parameter :: dims_input = 2
integer(c_int64_t) :: shape_input(dims_input)
integer(c_int), parameter :: n_inputs = 2
type(torch_tensor), dimension(n_inputs) :: model_input_arr
integer(c_int), parameter :: dims_output = 1
integer(c_int64_t) :: shape_output(dims_output)
type(torch_tensor) :: model_output

! Set up the model inputs as Fortran arrays
real, dimension(10,10), target  :: input_1, input_2
real, dimension(5), target   :: output

! Initialise the Torch model to be used
model = torch_module_load("/path/to/saved/model.pt"//c_null_char)

! Initialise the inputs as Fortran
input_1 = 0.0
input_2 = 1.0

! Wrap Fortran data as no-copy Torch Tensors
! There may well be some reshaping required depending on the 
! structure of the model which is not covered here (see examples)
shape_input = (/10, 10/)
shape_output = (/5/)
model_input_arr(1) = torch_tensor_from_blob(c_loc(input_1), dims_input, shape_input, torch_kFloat64, torch_kCPU)
model_input_arr(2) = torch_tensor_from_blob(c_loc(input_2), dims_input, shape_input, torch_kFloat64, torch_kCPU)
model_output = torch_tensor_from_blob(c_loc(output), dims_output, shape_output, torch_kFloat64, torch_kCPU)

! Run model and Infer
! Again, there may be some reshaping required depending on model design
call torch_module_forward(model, model_input_arr, n_inputs, model_output)

! Write out the result of running the model
write(*,*) output

! Clean up
call torch_module_delete(model)
call torch_tensor_delete(model_input_arr(1))
call torch_tensor_delete(model_input_arr(2))
call torch_tensor_delete(model_output)
```

### 3. Build the code

The code now needs to be compiled and linked against our installed library.
Here we describe how to do this for two build systems, cmake and make.

#### CMake
If our project were using cmake we would need the following in the `CMakeLists.txt` file to find the the tf-lib installation and link it to the executable.

This can be done by adding the following to the `CMakeLists.txt` file:
sjc306 re-write as appropriate
```
find_package(FTorch)
target_link_libraries( <executable> PRIVATE FTorch::ftorch )
message(STATUS "Building with Fortran PyTorch coupling")
```
and using the `-DFTorch_DIR=</path/to/install/location>` flag when running cmake.

#### Make
To build with make we need to include the library when compiling and link the executable
against it.

To compile with make we need add the following compiler flag when compiling files that
use ftorch:
sjc306 replace library name
```
FCFLAGS += -I<path/to/install/location>/include/ftorch
```

When compiling the final executable add the following link flag:
```
LDFLAGS += -L<path/to/install/location>/lib64 -lftorch
```

You may also need to add the location of the `.so` files to your `LD_LIBRARY_PATH`
unless installing in a default location:
```
export LD_LIBRARY_PATH = $LD_LIBRARY_PATH:<path/to/installation>/lib64
```


## Examples

Examples of how to use this library will be provided in the [examples directory](examples/).  
They demonstrate different functionalities and are provided with instructions to modify, build, and run as neccessary.

## License

Copyright &copy; ICCS

*Fortran-PyTorch-Lib* is distributed under the [MIT Licence](https://github.com/Cambridge-ICCS/fortran-pytorch-lib/blob/main/LICENSE).


## Contributions

Contributions and collaborations are welcome.

For bugs, feature requests, and clear suggestions for improvement please
[open an issue](https://github.com/Cambridge-ICCS/fortran-tf-lib/issues).

If you have built something upon _Fortran-PyTorch-Lib_ that would be useful to others, or can
address an [open issue](https://github.com/Cambridge-ICCS/fortran-tf-lib/issues), please
[fork the repository](https://github.com/Cambridge-ICCS/fortran-tf-lib/fork) and open a
pull request.


### Code of Conduct
Everyone participating in the _Fortran-TF-Lib_ project, and in particular in the
issue tracker, pull requests, and social media activity, is expected to treat other
people with respect and, more generally, to follow the guidelines articulated in the
[Python Community Code of Conduct](https://www.python.org/psf/codeofconduct/).


## Authors and Acknowledgment

*Fortran-PyTorch-Lib* is written and maintained by the [ICCS](https://github.com/Cambridge-ICCS)

Notable contributors to this project are:

* [**@SimonClifford**](https://github.com/SimonClifford)

See [Contributors](https://github.com/Cambridge-ICCS/fortran-pytorch-lib/graphs/contributors)
for a full list.


## Used by
The following projects make use of this code or derivatives in some way:

* [DataWave - MiMA ML](https://github.com/DataWaveProject/MiMA-machine-learning)

Are we missing anyone? Let us know.



