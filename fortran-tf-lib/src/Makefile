FCFLAGS+=-Wall -g -DUSE_F2018

FC=gfortran

all: load_model_c load_model_f

clean:
	$(RM) load_model_c load_model_f libfortran_tensorflow.a fortran_tensorflow_lib.o load_model_[cf].o tf_types.mod tf_interface.mod

load_model_c: load_model_c.c
	$(CC) $(CFLAGS) -o $@ -I $(TF_C_API)/include $^ -L $(TF_C_API)/lib -ltensorflow

load_model_f: load_model_f.F90 libfortran_tensorflow.a
	$(FC) $(FCFLAGS) -o $@ $^ -L $(TF_C_API)/lib -ltensorflow

libfortran_tensorflow.a: fortran_tensorflow_lib.o
	ar r $@ $^

%.o %.mod: %.F90
	$(FC) $(FCFLAGS) -c -o $*.o $<

test: all
	python3 ./load_model_py.py
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(TF_C_API)/lib ./load_model_c
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(TF_C_API)/lib ./load_model_f
