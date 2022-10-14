# fortran-ml-bridge
Code and examples on directly calling Tensorflow ML models from Fortran.

## Problem Statement
We want to be able to run ML models directly in Fortran. Initially let's assume that the model has been trained in some other language (say Python) and saved (e.g. as a SavedModel). We want to run inference on this model without having to call the Python executable. This should be possible by using the existing ML C/C++ interfaces.

### PyTorch

This repository no longer houses the Fortran to PyTorch interface.  That has its own repository:
[fortran-pytorch-lib](https://github.com/Cambridge-ICCS/fortran-pytorch-lib)

### Repository rename
If you have previously checked out this repository you should run
```
git remote set-url origin git@github.com:Cambridge-ICCS/fortran-tf-lib.git
```
or
```
git remote set-url origin https://github.com/Cambridge-ICCS/fortran-tf-lib.git
```
if you are not using a Github account.
