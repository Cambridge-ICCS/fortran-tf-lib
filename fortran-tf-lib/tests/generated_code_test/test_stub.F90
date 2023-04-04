program test_program
use ml_module
use TF_Types
use iso_c_binding
implicit none

type(TF_Tensor), dimension(1) :: input_tensors, output_tensors

real, dimension(32,1), target :: raw_data
real, dimension(1), target :: answers
real, dimension(:,:), pointer :: input_data_ptr
real, dimension(:), pointer :: output_data_ptr
integer i
type(c_ptr) :: raw_data_ptr
type(c_ptr) :: output_c_data_ptr

raw_data = reshape ([ &
        0.71332126, 0.81275973, 0.66596436, 0.79570779, 0.83973302, 0.76604397, &
        0.84371391, 0.92582056, 0.32038017, 0.0732005, 0.80589203, 0.75226581, &
        0.81602784, 0.59698078, 0.32991729, 0.43125108, 0.4368422, 0.88550326, &
        0.7131253,  0.14951148, 0.22084413, 0.70801317, 0.69433906, 0.62496564, &
        0.50744999, 0.94047845, 0.18191579, 0.2599102, 0.53161889, 0.57402205, &
        0.50751284, 0.65207096 &
    ], shape(raw_data))
answers = [-0.479371]

input_tensors(1) = associate_tensor(raw_data)
! Check tensor contents
call c_f_pointer(TF_TensorData(input_tensors(1)), input_data_ptr, shape(raw_data))
write(*,*)'input_tensors(1)'
do i = 1, 32
    write(*,*) input_data_ptr(i,1)
enddo

call ml_module_init()

call ml_module_calc(model_session_1, inputs_1, input_tensors, outputs_1, output_tensors)


call c_f_pointer(TF_TensorData(output_tensors(1)), output_data_ptr, shape(answers))
if ((output_data_ptr(1) - answers(1)) .gt. 1e-6) then
    write(*,*)'Output does not match, FAILED!'
else
    write(*,*)'Output is correct, SUCCESS!'
endif


call TF_DeleteTensor( input_tensors(1) )
call TF_DeleteTensor( output_tensors(1) )

end program test_program
