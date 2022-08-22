FC=ifort
#FC=gfortran
CC=icc
#CC=gcc

ifeq "$(FC)" 'ifort'
FCFLAGS+=-g
else
FCFLAGS+=-Wall -g -DUSE_F2018
endif

libfortran_tensorflow.a: fortran_tensorflow_lib.o
	$(AR) r $@ $^

clean:
	$(RM) libfortran_tensorflow.a fortran_tensorflow_lib.o tf_types.mod tf_interface.mod

%.o: %.F90
	$(FC) $(FCFLAGS) -c -o $*.o $<
