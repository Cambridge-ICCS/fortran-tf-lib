program test_program
use TF_Types
use TF_Interface
use iso_c_binding
implicit none

type(TF_Session) :: session
type(TF_SessionOptions) :: sessionoptions
type(TF_Graph) :: graph
type(TF_Status) :: stat
type(TF_Output), dimension(1) :: input_tfoutput, output_tfoutput
character(100) :: vers
character(100), dimension(1) :: tags
type(TF_Tensor), dimension(1) :: input_tensors, output_tensors, test_tensor
type(TF_Operation), dimension(1) :: target_opers

real, dimension(32), target :: raw_data
real, dimension(:), pointer :: output_data_ptr
integer(kind=c_int64_t), dimension(2) :: input_dims
integer(kind=c_int64_t), dimension(2) :: output_dims
type(c_ptr) :: raw_data_ptr
type(c_ptr) :: output_c_data_ptr

raw_data = (/ &
        0.71332126, 0.81275973, 0.66596436, 0.79570779, 0.83973302, 0.76604397, &
        0.84371391, 0.92582056, 0.32038017, 0.0732005, 0.80589203, 0.75226581, &
        0.81602784, 0.59698078, 0.32991729, 0.43125108, 0.4368422, 0.88550326, &
        0.7131253, 0.14951148, 0.22084413, 0.70801317, 0.69433906, 0.62496564, &
        0.50744999, 0.94047845, 0.18191579, 0.2599102, 0.53161889, 0.57402205, &
        0.50751284, 0.65207096 &
        /)


input_dims = (/ 1, 32 /)
output_dims = (/ 1, 1 /)
tags(1) = 'serve'

! Print TensorFlow library version
call TF_Version(vers)
write(*,*)'Tensorflow version', vers

sessionoptions = TF_NewSessionOptions()
graph = TF_NewGraph()
stat = TF_NewStatus()

! Load session (also populates graph)
session = TF_LoadSessionFromSavedModel(sessionoptions, '/path/to/model', tags, 1, &
    graph, stat)

if (TF_GetCode( stat ) .ne. TF_OK) then
    call TF_Message( stat, vers )
    write(*,*)'woops', TF_GetCode( stat ), vers
    call abort
endif

call TF_DeleteSessionOptions(sessionoptions)

input_tfoutput(1)%oper = TF_GraphOperationByName( graph, "serving_default_input_1" )
input_tfoutput(1)%index = 0
if (.not.c_associated(input_tfoutput(1)%oper%p)) then
    write(*,*)'input not associated'
    stop
endif

output_tfoutput(1)%oper = TF_GraphOperationByName( graph, "StatefulPartitionedCall" )
output_tfoutput(1)%index = 0
if (.not.c_associated(output_tfoutput(1)%oper%p)) then
    write(*,*)'output not associated'
    stop
endif

! Bind the input tensor
raw_data_ptr = c_loc(raw_data)
input_tensors(1) = TF_NewTensor( TF_FLOAT, input_dims, 2, raw_data_ptr, int(128, kind=c_size_t) )

! Run inference
call TF_SessionRun( session, input_tfoutput, input_tensors, 1, output_tfoutput, output_tensors, 1, &
    target_opers, 0, stat )
if (TF_GetCode( stat ) .ne. TF_OK) then
    call TF_Message( stat, vers )
    write(*,*) TF_GetCode( stat ), vers
    call abort
endif

! Bind output tensor
call c_f_pointer( TF_TensorData( output_tensors(1)), output_data_ptr, shape(output_data_ptr) )
write(*,*)'output data', output_data_ptr(1)

if ((output_data_ptr(1) - -0.479371) .gt. 1e-6) then
    write(*,*)'Output does not match, FAILED!'
else
    write(*,*)'Output is correct, SUCCESS!'
endif


! Clean up
call TF_DeleteTensor( input_tensors(1) )
call TF_DeleteTensor( output_tensors(1) )
call TF_DeleteGraph( graph )
call TF_DeleteSession( session, stat )
call TF_DeleteStatus( stat )

end program test_program
