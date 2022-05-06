#include <stdio.h>
#include <stdlib.h>
#include <tensorflow/c/c_api.h>

/*
TF_CAPI_EXPORT extern TF_Session* TF_LoadSessionFromSavedModel(
    const TF_SessionOptions* session_options, const TF_Buffer* run_options,
    const char* export_dir, const char* const* tags, int tags_len,
    TF_Graph* graph, TF_Buffer* meta_graph_def, TF_Status* status);

TF_CAPI_EXPORT extern void TF_SessionRun(
    TF_Session* session,
    // RunOptions
    const TF_Buffer* run_options,
    // Input tensors
    const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs,
    // Output tensors
    const TF_Output* outputs, TF_Tensor** output_values, int noutputs,
    // Target operations
    const TF_Operation* const* target_opers, int ntargets,
    // RunMetadata
    TF_Buffer* run_metadata,
    // Output status
    TF_Status*);

[[0.71332126 0.81275973 0.66596436 0.79570779 0.83973302 0.76604397
  0.84371391 0.92582056 0.32038017 0.0732005  0.80589203 0.75226581
  0.81602784 0.59698078 0.32991729 0.43125108 0.4368422  0.88550326
  0.7131253  0.14951148 0.22084413 0.70801317 0.69433906 0.62496564
  0.50744999 0.94047845 0.18191579 0.2599102  0.53161889 0.57402205
  0.50751284 0.65207096]]

[[-0.7109489]]
*/

void null_dealloc(void* data, size_t len, void* arg) {
    /*do nothing */
}

int main() {

	TF_SessionOptions* session_options;
	TF_Session* session;
    TF_Status* status;
    TF_Graph* graph;
    TF_Output input_tfoutput, output_tfoutput;
    TF_Tensor* input;
    TF_Tensor* input_values[1];
    TF_Tensor* output_values[1];
    void* input_data_ptr;
    void* output_data_ptr;

    const char* const tags[] = {"serve"};
    float raw_inp[] = {0.71332126, 0.81275973, 0.66596436, 0.79570779, 0.83973302, 0.76604397,
    0.84371391, 0.92582056, 0.32038017, 0.0732005, 0.80589203, 0.75226581,
    0.81602784, 0.59698078, 0.32991729, 0.43125108, 0.4368422, 0.88550326,
    0.7131253, 0.14951148, 0.22084413, 0.70801317, 0.69433906, 0.62496564,
    0.50744999, 0.94047845, 0.18191579, 0.2599102, 0.53161889, 0.57402205,
    0.50751284, 0.65207096};
    const int64_t input_dims[] = {1, 32};
    const int64_t output_dims[] = {1};
    float output_value;


    printf("Hello from TensorFlow C library version %s\n", TF_Version());

	session_options = TF_NewSessionOptions();
    graph = TF_NewGraph();
    status = TF_NewStatus();

    session = TF_LoadSessionFromSavedModel(
        session_options, // TF_SessionOptions* session_options
        NULL,            // TF_Buffer* run_options
        "../my_model",      // const char* export_dir
        tags,            // const char* const* tags
        1,               // int tags_len
        graph,           // TF_Graph* graph
        NULL,            // TF_Buffer* meta_graph_def
        status           // TF_Status* status
    );
    if (TF_OK != TF_GetCode(status)) {
        printf("load error %s\n", TF_Message(status));
    }

    // Get these names from e.g.:
    // `saved_model_cli show --dir my_model/ --tag serve --signature_def serving_default`
    // It will return something like:
/*
The given SavedModel SignatureDef contains the following input(s):
  inputs['input_1'] tensor_info:
      dtype: DT_FLOAT
      shape: (-1, 32)
      name: serving_default_input_1:0
The given SavedModel SignatureDef contains the following output(s):
  outputs['dense'] tensor_info:
      dtype: DT_FLOAT
      shape: (-1, 1)
      name: StatefulPartitionedCall:0
Method name is: tensorflow/serving/predict
*/
	// The names you want are under "name:", so "name: serving_default_input_1:0"
	// means the TF_Operation is named "serving_default_input_1" and the
    // index in the TF_Output is 0 for this input.

    input_tfoutput.oper = TF_GraphOperationByName(graph, "serving_default_input_1");
    input_tfoutput.index = 0;
    if (input_tfoutput.oper == NULL) {
        printf("input_oper null\n");
        exit(1);
    }
    output_tfoutput.oper = TF_GraphOperationByName(graph, "StatefulPartitionedCall"), 0;
    output_tfoutput.index = 0;

    if (output_tfoutput.oper == NULL) {
        printf("output_oper null\n");
        exit(1);
    }

/*
    input = TF_AllocateTensor( TF_FLOAT, input_dims, 2, 32*sizeof(TF_FLOAT) );
    if (input == NULL) {
        printf("allocate error\n");
    }
    input_data_ptr = TF_TensorData(input);
    memcpy(input_data_ptr, raw_inp, 32*sizeof(TF_FLOAT));
*/
/* TF_CAPI_EXPORT extern TF_Tensor* TF_NewTensor(
    TF_DataType, const int64_t* dims, int num_dims, void* data, size_t len,
    void (*deallocator)(void* data, size_t len, void* arg),
    void* deallocator_arg);
*/
    input = TF_NewTensor(
        TF_FLOAT, input_dims, 2, raw_inp, 32*sizeof(TF_FLOAT),
        &null_dealloc, NULL
    );

    input_values[0] = input;
    output_values[0] = NULL;


    TF_SessionRun(
        session,          // TF_Session* session,
        // RunOptions
        NULL,             // const TF_Buffer* run_options,
        // Input tensors
        &input_tfoutput,   // const TF_Output* inputs
        input_values,     // TF_Tensor* const* input_values
        1,          // int ninputs
        // Output tensors
        &output_tfoutput,  // const TF_Output* outputs
        output_values,    // TF_Tensor** output_values
        1,         // int noutputs
        // Target operations
        NULL,     // const TF_Operation* const* target_opers
        0,         // int ntargets
        // RunMetadata
        NULL,     // TF_Buffer* run_metadata
        // Output status
        status            // TF_Status* status
    );
    if (TF_OK != TF_GetCode(status)) {
        printf("run error %s\n", TF_Message(status));
    }

    output_data_ptr = TF_TensorData(output_values[0]);
    output_value = *((float*)output_data_ptr);

    printf("\n\nFinished, output= %f\n", output_value);
    if ((output_value - -0.479371) > 1e-6) {
        printf("Output does not match, FAILED!\n");
    } else {
        printf("Output is correct, SUCCESS!\n");
    }


    /* Do stuff */
    
    return 0;
}
