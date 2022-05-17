program load_wavenet
use TF_Types
use TF_Interface
use iso_c_binding
implicit none

type(TF_Session) :: session
type(TF_SessionOptions) :: sessionoptions
type(TF_Graph) :: graph
type(TF_Status) :: stat
type(TF_Buffer) :: buff
type(TF_Output), dimension(1)  :: input_tfoutput
type(TF_Output), dimension(33) :: output_tfoutput
type(TF_Output) :: output_temp
character(100) :: vers
character(100), dimension(1) :: tags
type(TF_Tensor), dimension(1) :: input_tensors
type(TF_Tensor), dimension(33) :: output_tensors
type(TF_Operation), dimension(1) :: target_opers

real, dimension(80,2), target :: raw_data
real, dimension(33,2) :: answers
real, dimension(:), pointer :: output_data_ptr
real, dimension(:,:), pointer :: input_data_ptr
integer(kind=c_int64_t), dimension(2) :: input_dims
!integer(kind=c_int64_t), dimension(2) :: output_dims
type(c_ptr) :: raw_data_ptr
type(c_ptr) :: output_c_data_ptr
integer :: i, j
integer, dimension(33) :: arses

arses = (/  0,  1, 12, 23, 27, 28, 29, 30, 31, 32, &
            2,  3,  4,  5,  6,  7,  8,  9, 10, 11, &
           13, 14, 15, 16, 17, 18, 19, 20, 21, 22, &
           24, 25, 26 /)

raw_data = reshape( [ &
-0.50056173, -0.43191799, -0.45814849, -0.42308065, -0.39608876, &
-0.42058786, -0.48943563, -0.55914003, -0.59548319, -0.59470056, &
-0.56057665, -0.49053039, -0.41273755, -0.36022401, -0.33099403, &
-0.32663929, -0.34909558, -0.38657446, -0.42591572, -0.45876062, &
-0.48707832, -0.51761326, -0.55789608, -0.61785765, -0.67222452, &
-0.70736123, -0.72341793, -0.71667408, -0.6970197 , -0.6718729 , &
-0.64062628, -0.59585244, -0.53097871, -0.45619551, -0.37970914, &
-0.29086245, -0.19137345, -0.15862776, -0.07856159, -0.0519871 , &
5.6096781 ,  0.51163358,  0.1616316 , -0.02448044,  0.05035503, &
0.2469078 ,  0.50501318,  0.81789669,  1.17244124,  1.57535735, &
1.97959384,  2.33531016,  2.61409588,  2.83465703,  3.07406614, &
3.34655064,  3.67657978,  4.04060131,  4.46902248,  4.89025021, &
5.25250829,  5.42881022,  5.29634559,  5.09095451,  5.22459565, &
6.09452842,  7.91161833,  8.96641697,  6.98748466,  4.96716228, &
3.60061822,  2.61833073,  1.83748635,  1.17997637,  0.58276169, &
0.07409358, -0.35991023, -0.73380562, -1.09849017, -1.39652227, & ! end of second
-0.50056173, -0.43191799, -0.45814849, -0.42308065, -0.39608876, &
-0.42058786, -0.48943563, -0.55914003, -0.59548319, -0.59470056, &
-0.56057665, -0.49053039, -0.41273755, -0.36022401, -0.33099403, &
-0.32663929, -0.34909558, -0.38657446, -0.42591572, -0.45876062, &
-0.48707832, -0.51761326, -0.55789608, -0.61785765, -0.67222452, &
-0.70736123, -0.72341793, -0.71667408, -0.6970197 , -0.6718729 , &
-0.64062628, -0.59585244, -0.53097871, -0.45619551, -0.37970914, &
-0.29086245, -0.19137345, -0.15286976, -0.07272775, -0.04584531, &
5.6096781 ,  0.51163358,  0.1616316 , -0.02448044,  0.05035503, &
0.2469078 ,  0.50501318,  0.81789669,  1.17244124,  1.57535735, &
1.97959384,  2.33531016,  2.61409588,  2.83465703,  3.07406614, &
3.34655064,  3.67657978,  4.04060131,  4.46902248,  4.89025021, &
5.25250829,  5.42881022,  5.29634559,  5.09095451,  5.22459565, &
6.09452842,  7.91161833,  8.96641697,  6.98748466,  4.96716228, &
3.60061822,  2.61833073,  1.83748635,  1.17997637,  0.58276169, &
0.07409358, -0.35991023, -0.73380562, -1.09849017, -1.39652227 & ! end of first
       ], shape(raw_data) )

answers = reshape( [ &
    0.28690988, 0.3936974 , 0.42413083, -0.36170343, 0.05769337, &
    -0.49545187, 0.09840355, 0.05283355, 0.35415295, 0.46001926, &
    -1.7458353 , -0.33428577, 0.7925055 , 0.09023142, -0.2546197 , &
    0.78985447, 0.4075164 , 0.4059543 , 0.30803442, -0.49953395, &
    -0.21440051, -0.00722447, 0.34737316, 0.10773647, 0.670053, &
    0.30601332, 0.02975837, 0.00956418, 0.62304896, -1.0564077, &
    0.11049131, 0.53186846, -0.5389675, &
    0.28733265, 0.39368165, 0.42472696, -0.3621848, 0.05769337, -0.49498397, &
    0.09840355, 0.05352264, 0.35404724, 0.46033886, -1.7465684, -0.33426875, &
    0.7924648, 0.09228674, -0.25490162, 0.7896581, 0.4081997, 0.40644962, &
    0.30809644, -0.49818873, -0.2132362, -0.00673803, 0.35211396, 0.10806128, &
    0.6702236, 0.3061434, 0.03039804, 0.01004943, 0.6235992, -1.0581621, &
    0.11002517, 0.5317495, -0.5416618 &
    ], shape(answers) )

input_dims = (/ 2, 80 /)
!output_dims = (/ 33, 1 /)
tags(1) = 'serve'

call TF_Version(vers)
write(*,*)'hello from Tensorflow version', vers

sessionoptions = TF_NewSessionOptions()
graph = TF_NewGraph()
!buff = TF_NewBuffer()
stat = TF_NewStatus()

session = TF_LoadSessionFromSavedModel(sessionoptions, &
    '../wavenet/wavenet_gwfu.savedmodel', &
    tags, 1, graph, stat)

if (TF_GetCode( stat ) .ne. TF_OK) then
    call TF_Message( stat, vers )
    write(*,*) TF_GetCode( stat ), vers
    stop
endif

call TF_DeleteSessionOptions(sessionoptions)
call TF_DeleteBuffer(buff)

! now can use session
input_tfoutput%oper = TF_GraphOperationByName( graph, "serving_default_input_1" )
input_tfoutput%index = 0
if (.not.c_associated(input_tfoutput(1)%oper%p)) then
    write(*,*)'input not associated'
    stop
endif

do i = 1, 33
    output_tfoutput(i)%oper = TF_GraphOperationByName( graph, "StatefulPartitionedCall" )
    output_tfoutput(i)%index = arses(i)
    if (.not.c_associated(output_tfoutput(i)%oper%p)) then
        write(*,*)'output ', i, ' not associated'
        stop
    endif
end do

raw_data_ptr = c_loc(raw_data)
input_tensors(1) = TF_NewTensor( TF_FLOAT, input_dims, 2, raw_data_ptr, int(2*80*4, kind=c_size_t) )
call c_f_pointer( TF_TensorData( input_tensors(1)), input_data_ptr, shape(raw_data) )
do j = 1, 2
do i = 1, 80
    write(*,*)'input data', i, j, input_data_ptr(i,j), input_data_ptr(i,j) - raw_data(i,j)
end do
end do

call TF_SessionRun( session, input_tfoutput, input_tensors, 1, output_tfoutput, output_tensors, 33, &
    target_opers, 0, stat )
if (TF_GetCode( stat ) .ne. TF_OK) then
    call TF_Message( stat, vers )
    write(*,*) TF_GetCode( stat ), vers
    stop
endif

!call c_f_pointer( output_c_data_ptr, output_data_ptr, shape(output_data_ptr) )
do j = 1, 2
do i = 1, 33
    call c_f_pointer( TF_TensorData( output_tensors(i)), output_data_ptr, shape(output_data_ptr) )
    write(*,*)'output data', output_data_ptr(j), output_data_ptr(j) - answers(i,j)
end do
end do
call TF_DeleteTensor( input_tensors(1) )
call TF_DeleteTensor( output_tensors(1) )
call TF_DeleteGraph( graph )
call TF_DeleteSession( session, stat )
call TF_DeleteStatus( stat )

end program load_wavenet
