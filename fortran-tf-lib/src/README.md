# The Fortran to TensorFlow library

Here's some initial code for this library.  In `src/` you'll find:
* A Fortran to tensorflow library implementing the bare minimum of the TensorFlow C API
* A simple python program to load a saved model and infer from it
* A simple C program to load a saved model and infer from it
* A simple Fortran program to load a saved model and infer from it

## Building

You'll need the TensorFlow C API, download from https://www.tensorflow.org/install/lang\_c.  I've only
tested the CPU one.  Looks like the newer 2.8.0 is available if you change the download URL.  Untar this
somewhere and set `TF_C_API` in your environment to the location, such that:

```
$ ls $TF_C_API
include  lib  LICENSE  THIRD_PARTY_TF_C_LICENSES
```

Now run `make` in the `src` directory.  I've hard coded the Fortran compiler to `gfortran` in the Makefile
(because `make` doesn't know about Fortrans newer than 77)
but you can override.

You should get `load_model_c` and `load_model_f`.  You can run them and compare
to `load_model_py.py`.  The python code will require an environment with TensorFlow
in it.  All should produce the same result output from the saved model in `my_model`.

The model was created with `gen_model.py`.  Although I'm using `np.random.seed(0)`
the model still comes out non-deterministically, so if you run this code be aware it will
overwrite `../my_model`.  I've actually commented out the `save` call.

## Thoughts
### Pointers
Should I be using Fortran pointers rather than actual types in the procedure calls?  I.e.
instead of this:
```
    function TF_LoadSessionFromSavedModel( session_options, export_dir, tags, tags_len, &
            graph, stat, run_options_opt, meta_graph_def_opt )
        use TF_Types
        type(TF_Session)           :: TF_LoadSessionFromSavedModel
        type(TF_SessionOptions)    :: session_options
        ...
```
should we have this?:
```
    function TF_LoadSessionFromSavedModel( session_options, export_dir, tags, tags_len, &
            graph, stat, run_options_opt, meta_graph_def_opt )
        type(TF_Session), pointer           :: TF_LoadSessionFromSavedModel
        type(TF_SessionOptions), pointer    :: session_options
        ...
```

### Easy interface
How much should we attempt to *fully and solely implement the API* versus providing a
friendly and useful interface (more like the Python one)?  If you look at `load_model_py.py`
versus the other implementations you'll see the Python code doesn't seem to need to know about
`serving_default_input_1` and `StatefulPartitionedCall`.  Our API can also get this information
from the model, so should we provide "helper" functions that smooth a lot of the extra
work away?

So we could have an interface that replicates the C interface for power users and for internal
use but also present a friendly interface that does things like:

```fortran
model = LoadModel('model_path')
output_tensors = model.predict(input_tensors)
```
much like the python interface.  Will still need some `c_ptr` manipulation to get data out
but can hide a lot of the details.  I like this.
