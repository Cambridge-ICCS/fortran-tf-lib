import numpy as np
import tensorflow as tf
from tensorflow import keras

# Create a simple model.
#inputs = keras.Input(shape=(32,), name="the_input_xxyyz")
inputs = keras.Input(shape=(32,))
#outputs = keras.layers.Dense(1, name="the_output_blarg")(inputs)
outputs = keras.layers.Dense(1)(inputs)
model = keras.Model(inputs, outputs)
model.compile(optimizer="adam", loss="mean_squared_error")

# Train the model.
test_input = np.random.random((128, 32))
test_target = np.random.random((128, 1))
model.fit(test_input, test_target)

# Calling `save('my_model')` creates a SavedModel folder `my_model`.
model.save("../my_model")

print( model.predict(test_input) )
