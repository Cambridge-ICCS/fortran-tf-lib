import pytest
import subprocess
import os

@pytest.fixture
def tf_lib():
    return subprocess.run(["make", "-C", "../src"], check=True)

def test_f90_created():
	"""
	test if process_model generates the FORTRAN file
	""" 
	subprocess.run(["process_model", "../my_model/", "-o", "testf.f90"], check=True)
	assert os.path.isfile("testf.f90")
	os.remove("testf.f90")

def test_f90_compile(tf_lib):
	""" 
	test if the FORTRAN file generated from process_model compiles
	"""
	subprocess.run(["process_model", "../my_model/", "-o", "testf.f90"])
	ret = subprocess.run(["gfortran", "-c", "-I", "../src/", "testf.f90"], check=True)
	assert ret.returncode == 0
	os.remove("testf.f90")
	os.remove("testf.o")
	os.remove("ml_model.mod")
