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
np.random.seed(0)
test_input = np.random.random((128, 32))
test_target = np.random.random((128, 1))
model.fit(test_input, test_target)

# Calling `save('my_model')` creates a SavedModel folder `my_model`.
# this overwrites any existing model.  The random.seed(0) still doesn't
# create deterministic models, presumably there's enough variation in
# the initial weights to make each one unique.  Bless.
#model.save("../my_model")

print( model.predict(test_input) )
