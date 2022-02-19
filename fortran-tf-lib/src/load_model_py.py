import numpy as np
import tensorflow as tf
from tensorflow import keras

reconstructed_model = keras.models.load_model("../my_model")

test_raw = [[
    0.71332126, 0.81275973, 0.66596436, 0.79570779, 0.83973302, 0.76604397,
    0.84371391, 0.92582056, 0.32038017, 0.0732005, 0.80589203, 0.75226581,
    0.81602784, 0.59698078, 0.32991729, 0.43125108, 0.4368422, 0.88550326,
    0.7131253, 0.14951148, 0.22084413, 0.70801317, 0.69433906, 0.62496564,
    0.50744999, 0.94047845, 0.18191579, 0.2599102, 0.53161889, 0.57402205,
    0.50751284, 0.65207096]]

test_input = np.random.random((1, 32))
print( test_input )
output_value = reconstructed_model.predict(test_raw)
print( '\n\nFinished, output= {}\n'.format(output_value) )
if (output_value - -0.479371) > 1e-6:
    print( 'Output does not match, FAILURE!\n')
else:
    print( 'Output is correct, SUCCESS!\n')
