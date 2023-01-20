module TF_Types
    use iso_c_binding
    type TF_SessionOptions
        type(c_ptr) :: p = c_null_ptr
    end type TF_SessionOptions

    type TF_Graph
        type(c_ptr) :: p = c_null_ptr
    end type TF_Graph

    type TF_Status
        type(c_ptr) :: p = c_null_ptr
    end type TF_Status

    type TF_Session
        type(c_ptr) :: p = c_null_ptr
    end type TF_Session

    type TF_Buffer
        type(c_ptr) :: p = c_null_ptr
    end type TF_Buffer

!   From tensorflow/c/tf_status.h
    enum, bind(c)
        enumerator :: TF_OK = 0
        enumerator :: TF_CANCELLED = 1
        enumerator :: TF_UNKNOWN = 2
        enumerator :: TF_INVALID_ARGUMENT = 3
        enumerator :: TF_DEADLINE_EXCEEDED = 4
        enumerator :: TF_NOT_FOUND = 5
        enumerator :: TF_ALREADY_EXISTS = 6
        enumerator :: TF_PERMISSION_DENIED = 7
        enumerator :: TF_UNAUTHENTICATED = 16
        enumerator :: TF_RESOURCE_EXHAUSTED = 8
        enumerator :: TF_FAILED_PRECONDITION = 9
        enumerator :: TF_ABORTED = 10
        enumerator :: TF_OUT_OF_RANGE = 11
        enumerator :: TF_UNIMPLEMENTED = 12
        enumerator :: TF_INTERNAL = 13
        enumerator :: TF_UNAVAILABLE = 14
        enumerator :: TF_DATA_LOSS = 15
    end enum

    type TF_Operation
        type(c_ptr) :: p = c_null_ptr
    end type TF_Operation

    type TF_Output
        type(TF_Operation)  :: oper
        integer(kind=c_int) :: index
    end type TF_Output

    !private
    type, bind(c) :: TF_Output_Actual
        type(c_ptr) :: oper_ptr
        integer(kind=c_int) :: index
    end type TF_Output_Actual

    type TF_Tensor
        type(c_ptr) :: p = c_null_ptr
    end type TF_Tensor

!   From tensorflow/c/tf_datatype.h
    enum, bind(c)
        enumerator :: TF_FLOAT = 1
        enumerator :: TF_DOUBLE = 2
        enumerator :: TF_INT32 = 3  ! Int32 tensors are always in 'host' memory.
        enumerator :: TF_UINT8 = 4
        enumerator :: TF_INT16 = 5
        enumerator :: TF_INT8 = 6
        enumerator :: TF_STRING = 7
        enumerator :: TF_COMPLEX64 = 8  ! Single-precision complex
        enumerator :: TF_COMPLEX = 8    ! Old identifier kept for API backwards compatibility
        enumerator :: TF_INT64 = 9
        enumerator :: TF_BOOL = 10
        enumerator :: TF_QINT8 = 11     ! Quantized int8
        enumerator :: TF_QUINT8 = 12    ! Quantized uint8
        enumerator :: TF_QINT32 = 13    ! Quantized int32
        enumerator :: TF_BFLOAT16 = 14  ! Float32 truncated to 16 bits.  Only for cast ops.
        enumerator :: TF_QINT16 = 15    ! Quantized int16
        enumerator :: TF_QUINT16 = 16   ! Quantized uint16
        enumerator :: TF_UINT16 = 17
        enumerator :: TF_COMPLEX128 = 18  ! Double-precision complex
        enumerator :: TF_HALF = 19
        enumerator :: TF_RESOURCE = 20
        enumerator :: TF_VARIANT = 21
        enumerator :: TF_UINT32 = 22
        enumerator :: TF_UINT64 = 23
    end enum

end module TF_Types

module TF_Interface
    implicit none
    private :: fstring
    private :: cstring
    private :: null_dealloc

    interface TF_NewTensor
#ifdef USE_F2018
        module procedure TF_NewTensor_2018
#endif
        module procedure TF_NewTensor_cptr
    end interface TF_NewTensor

contains

    subroutine fstring( s )
        use iso_c_binding
        character(*) :: s
        integer      :: ind

        ind = index(s, c_null_char)
        if (ind > 0) then
            s(ind:) = ' '
        endif
    end subroutine fstring

    subroutine cstring( s )
        use iso_c_binding
        character(*) :: s
        integer      :: ind

        ind = len_trim(s) + 1
        s(ind:ind) = c_null_char
    end subroutine cstring

!   Pass in vers_str large enough to accept the version string.
!   If it's too short the string will be truncated.
    subroutine TF_Version( vers_str )
        use iso_c_binding
        character(*)                          :: vers_str
        character(len=len(vers_str)), pointer :: p => null()
        type(c_ptr)                           :: output
        interface
            function TF_Version_c() bind(c, name="TF_Version")
                use iso_c_binding
                type(c_ptr) :: TF_Version_c
            end function TF_Version_c
        end interface

        output = TF_Version_c()
        call c_f_pointer(output, p)
        vers_str = p
        call fstring( vers_str )
    end subroutine TF_Version

    function TF_NewBuffer()
        use TF_Types
        type(TF_Buffer) :: TF_NewBuffer
        interface
            function TF_NewBuffer_c() bind(c, name="TF_NewBuffer")
                use iso_c_binding
                type(c_ptr)       :: TF_NewBuffer_c
            end function TF_NewBuffer_c
        end interface

        TF_NewBuffer%p = TF_NewBuffer_c()
    end function TF_NewBuffer

    subroutine TF_DeleteBuffer( buffer )
        use TF_Types
        type(TF_Buffer) :: buffer
        interface
            subroutine TF_DeleteBuffer_c( buffer ) bind(c, name="TF_DeleteBuffer")
                use iso_c_binding
                type(c_ptr), value       :: buffer
            end subroutine TF_DeleteBuffer_c
        end interface
    
        call TF_DeleteBuffer_c( buffer%p )
    end subroutine TF_DeleteBuffer

    function TF_NewSessionOptions()
        use TF_Types
        type(TF_SessionOptions) :: TF_NewSessionOptions
        interface
            function TF_NewSessionOptions_c() bind(c, name="TF_NewSessionOptions")
                use iso_c_binding
                type(c_ptr)       :: TF_NewSessionOptions_c
            end function TF_NewSessionOptions_c
        end interface

        TF_NewSessionOptions%p = TF_NewSessionOptions_c()
    end function TF_NewSessionOptions

    subroutine TF_DeleteSessionOptions( sessionoptions )
        use TF_Types
        type(TF_SessionOptions) :: sessionoptions
        interface
            subroutine TF_DeleteSessionOptions_c( sessionoptions ) bind(c, name="TF_DeleteSessionOptions")
                use iso_c_binding
                type(c_ptr), value       :: sessionoptions
            end subroutine TF_DeleteSessionOptions_c
        end interface

        call TF_DeleteSessionOptions_c( sessionoptions%p )
    end subroutine TF_DeleteSessionOptions

    function TF_NewGraph()
        use TF_Types
        type(TF_Graph) :: TF_NewGraph
        interface
            function TF_NewGraph_c() bind(c, name="TF_NewGraph")
                use iso_c_binding
                type(c_ptr)       :: TF_NewGraph_c
            end function TF_NewGraph_c
        end interface

        TF_NewGraph%p = TF_NewGraph_c()
    end function TF_NewGraph

    subroutine TF_DeleteGraph( graph )
        use TF_Types
        type(TF_Graph) :: graph
        interface
            subroutine TF_DeleteGraph_c( graph ) bind(c, name="TF_DeleteGraph")
                use iso_c_binding
                type(c_ptr), value       :: graph
            end subroutine TF_DeleteGraph_c
        end interface

        call TF_DeleteGraph_c( graph%p )
    end subroutine TF_DeleteGraph

    function TF_NewStatus()
        use TF_Types
        type(TF_Status) :: TF_NewStatus
        interface
            function TF_NewStatus_c() bind(c, name="TF_NewStatus")
                use iso_c_binding
                type(c_ptr)       :: TF_NewStatus_c
            end function TF_NewStatus_c
        end interface

        TF_NewStatus%p = TF_NewStatus_c()
    end function TF_NewStatus

    subroutine TF_DeleteStatus( stat )
        use TF_Types
        type(TF_Status) :: stat
        interface
            subroutine TF_DeleteStatus_c( stat ) bind(c, name="TF_DeleteStatus")
                use iso_c_binding
                type(c_ptr), value       :: stat
            end subroutine TF_DeleteStatus_c
        end interface

        call TF_DeleteStatus_c( stat%p )
    end subroutine TF_DeleteStatus

    function TF_LoadSessionFromSavedModel( session_options, export_dir, tags, tags_len, &
            graph, stat, run_options_opt, meta_graph_def_opt )
        use TF_Types
        type(TF_Session)           :: TF_LoadSessionFromSavedModel
        type(TF_SessionOptions)    :: session_options
        character(len=*)           :: export_dir
        character(*), dimension(:) :: tags
        integer                    :: tags_len
        type(TF_Graph)             :: graph
        type(TF_Status)            :: stat
        type(TF_Buffer), optional  :: run_options_opt
        type(TF_Buffer)            :: run_options
        type(TF_Buffer), optional  :: meta_graph_def_opt
        type(TF_Buffer)            :: meta_graph_def

        character(len=len(export_dir)+1), target :: export_dir_temp
        type(c_ptr)                              :: export_dir_ptr
        type(c_ptr), dimension(tags_len), target :: tag_ptrs
        integer                                  :: i
        character(len=len(tags)+1), dimension(tags_len), target :: tags_temp

        interface
            function TF_LoadSessionFromSavedModel_c( &
                session_options, run_options, export_dir, &
                tags, tags_len, graph, meta_graph_def, &
                stat &
            ) bind(c, name="TF_LoadSessionFromSavedModel")
                use iso_c_binding
                type(c_ptr)       :: TF_LoadSessionFromSavedModel_c
                type(c_ptr), value       :: session_options
                type(c_ptr), value       :: run_options
                type(c_ptr), value       :: export_dir
                type(c_ptr), value       :: tags
                integer(kind=c_int), value :: tags_len
                type(c_ptr), value       :: graph
                type(c_ptr), value       :: meta_graph_def
                type(c_ptr), value       :: stat
            end function TF_LoadSessionFromSavedModel_c
        end interface

        do i = 1, tags_len
            tags_temp(i) = tags(i)
            call cstring(tags_temp(i))
            tag_ptrs(i) = c_loc(tags_temp(i))
        end do
        export_dir_temp = export_dir
        call cstring(export_dir_temp)
        export_dir_ptr = c_loc(export_dir_temp)

        if (present(run_options_opt)) then
            run_options = run_options_opt
        else
            run_options%p = c_null_ptr
        endif
        if (present(meta_graph_def_opt)) then
            meta_graph_def = meta_graph_def_opt
        else
            meta_graph_def%p = c_null_ptr
        endif

        TF_LoadSessionFromSavedModel%p = &
            TF_LoadSessionFromSavedModel_c( &
                session_options%p, run_options%p, export_dir_ptr, &
                c_loc(tag_ptrs), tags_len, graph%p, meta_graph_def%p, &
                stat%p &
            )
    end function TF_LoadSessionFromSavedModel

    subroutine TF_DeleteSession( session, stat )
        use TF_Types
        type(TF_Session) :: session
        type(TF_Status)  :: stat
        interface
            subroutine TF_DeleteSession_c( session, stat ) bind(c, name="TF_DeleteSession")
                use iso_c_binding
                type(c_ptr), value       :: session
                type(c_ptr), value       :: stat
            end subroutine TF_DeleteSession_c
        end interface

        call TF_DeleteSession_c( session%p, stat%p )
    end subroutine TF_DeleteSession

    function TF_GetCode( stat )
        use TF_Types
        integer(kind(TF_OK)) :: TF_GetCode
        type(TF_Status)      :: stat
        interface
            function TF_GetCode_c( stat ) bind(c, name="TF_GetCode")
                use iso_c_binding
                integer(kind(TF_OK))     :: TF_GetCode_c
                type(c_ptr), value       :: stat
            end function TF_GetCode_c
        end interface

        TF_GetCode = TF_GetCode_c( stat%p )
    end function TF_GetCode

    subroutine TF_Message( stat, message )
        use TF_Types
        character(*)                         :: message
        type(TF_Status)                      :: stat
        character(len=len(message)), pointer :: p => null()
        type(c_ptr)                          :: output
        interface
            function TF_Message_c( stat ) bind(c, name="TF_Message")
                use iso_c_binding
                type(c_ptr)              :: TF_Message_c
                type(c_ptr), value       :: stat
            end function TF_Message_c
        end interface

        output = TF_Message_c( stat%p )
        call c_f_pointer(output, p)
        message = p
        call fstring( message )
    end subroutine TF_Message

!TF_CAPI_EXPORT extern TF_Operation* TF_GraphOperationByName(TF_Graph* graph, const char* oper_name); 
    function TF_GraphOperationByName( graph, name )
        use TF_Types
        type(TF_Operation) :: TF_GraphOperationByName
        type(TF_Graph)     :: graph
        character(*)       :: name

        character(len=len(name)+1), target :: name_temp
        type(c_ptr)                        :: name_temp_ptr
        interface
            function TF_GraphOperationByName_c( graph, name ) bind(c, name="TF_GraphOperationByName")
                use iso_c_binding
                type(c_ptr)              :: TF_GraphOperationByName_c
                type(c_ptr), value       :: graph
                type(c_ptr), value       :: name
            end function TF_GraphOperationByName_c
        end interface

        name_temp = name
        call cstring(name_temp)
        name_temp_ptr = c_loc(name_temp)
        TF_GraphOperationByName%p = TF_GraphOperationByName_c( graph%p, name_temp_ptr )
    end function TF_GraphOperationByName

! private
    subroutine null_dealloc( data, len, arg )
        use iso_c_binding
        type(c_ptr)            :: data
        integer(kind=c_size_t) :: len
        type(c_ptr)            :: arg

        ! do nothing

    end subroutine null_dealloc
 
#ifdef USE_F2018
!   This function relies on Fortran 2018 features: assumed type and assumed rank.
    function TF_NewTensor_2018( datatype, dims, num_dims, data, len )
        use TF_Types
        type(TF_Tensor)                       :: TF_NewTensor_2018
        integer(kind(TF_FLOAT))               :: datatype
        integer(kind=c_int64_t), dimension(:) :: dims
        integer                               :: num_dims
        type(*), dimension(..), target, contiguous        :: data
        integer(kind=c_size_t)                :: len

        type(c_ptr)                           :: data_ptr

        data_ptr = c_loc(data)
        TF_NewTensor_2018 = TF_NewTensor_cptr( datatype, dims, num_dims, data_ptr, len )
    end function TF_NewTensor_2018
#endif
!   This function does not use F2018 features but requires caller to create a c_ptr for data
!   and to check that the array pointed to is contiguous.
    function TF_NewTensor_cptr( datatype, dims, num_dims, data, len )
        use TF_Types
        type(TF_Tensor)                               :: TF_NewTensor_cptr
        integer(kind(TF_FLOAT))                       :: datatype
        integer(kind=c_int64_t), dimension(num_dims), target :: dims
        integer                                       :: num_dims
        type(c_ptr)                                   :: data
        integer(kind=c_size_t)                        :: len

        type(c_funptr)                                :: dealloc_ptr

        interface
!TF_CAPI_EXPORT extern TF_Tensor* TF_NewTensor(
!TF_DataType, const int64_t* dims, int num_dims, void* data, size_t len,
!void (*deallocator)(void* data, size_t len, void* arg),
!void* deallocator_arg);
            function TF_NewTensor_c( datatype, dims, num_dims, data, len, deallocator, deallocator_arg ) &
                    bind(c, name="TF_NewTensor")
                use iso_c_binding
                type(c_ptr) :: TF_NewTensor_c
                integer(kind(TF_FLOAT)), value :: datatype
                type(c_ptr), value:: dims
                integer(kind=c_int), value :: num_dims
                type(c_ptr), value :: data
                integer(kind=c_size_t), value :: len
                type(c_funptr), value :: deallocator
                type(c_ptr), value :: deallocator_arg

            end function TF_NewTensor_c
        end interface

        dealloc_ptr = c_funloc(null_dealloc)
        TF_NewTensor_cptr%p = TF_NewTensor_c( datatype, c_loc(dims), num_dims, data, len, dealloc_ptr, c_null_ptr )
    end function TF_NewTensor_cptr

    subroutine TF_SessionRun( session, inputs, input_values, ninputs, outputs, output_values, noutputs, &
            target_opers, ntargets, stat, run_options_opt, run_metadata_opt )
        use TF_Types
        type(TF_Session)                       :: session
        type(TF_Output), dimension(ninputs)    :: inputs
        type(TF_Tensor), dimension(ninputs)    :: input_values
        integer(kind=c_int)                    :: ninputs
        type(TF_Output), dimension(noutputs)   :: outputs
        type(TF_Tensor), dimension(noutputs)   :: output_values
        integer(kind=c_int)                    :: noutputs
        type(TF_Operation), dimension(ntargets):: target_opers
        integer(kind=c_int)                    :: ntargets
        type(TF_Status)                        :: stat
        type(TF_Buffer), optional              :: run_options_opt
        type(TF_Buffer)                        :: run_options
        type(TF_Buffer), optional              :: run_metadata_opt
        type(TF_Buffer)                        :: run_metadata

        type(c_ptr), dimension(ninputs), target  :: input_value_ptrs
        type(c_ptr), dimension(noutputs), target :: output_value_ptrs
        type(c_ptr), dimension(ntargets), target :: target_oper_ptrs
        integer                                  :: i
        type(TF_Output_Actual), dimension(ninputs), target           :: input_act
        type(TF_Output_Actual), dimension(noutputs), target          :: output_act
        type(c_ptr)                              :: input_act_ptr, output_act_ptr
        interface
!TF_CAPI_EXPORT extern void TF_SessionRun(
!    TF_Session* session,
!    // RunOptions
!    const TF_Buffer* run_options,
!    // Input tensors
!    const TF_Output* inputs, TF_Tensor* const* input_values, int ninputs,
!    // Output tensors
!    const TF_Output* outputs, TF_Tensor** output_values, int noutputs,
!    // Target operations
!    const TF_Operation* const* target_opers, int ntargets,
!    // RunMetadata
!    TF_Buffer* run_metadata,
!    // Output status
!    TF_Status*);
            subroutine TF_SessionRun_c( session, run_options, inputs, input_values, ninputs, outputs, &
                    output_values, noutputs, target_opers, ntargets, run_metadata, stat) &
                    bind(c, name="TF_SessionRun")
                use iso_c_binding
                type(c_ptr), value :: session
                type(c_ptr), value :: run_options
                type(c_ptr), value :: inputs
                type(c_ptr), value :: input_values
                integer(kind=c_int), value :: ninputs
                type(c_ptr), value :: outputs
                type(c_ptr), value :: output_values
                integer(kind=c_int), value :: noutputs
                type(c_ptr), value :: target_opers
                integer(kind=c_int), value :: ntargets
                type(c_ptr), value :: run_metadata
                type(c_ptr), value :: stat
            end subroutine TF_SessionRun_c
        end interface

        if (present(run_options_opt)) then
           run_options = run_options_opt
        else
            run_options%p = c_null_ptr
        endif
        if (present(run_metadata_opt)) then
           run_metadata = run_metadata_opt
        else
            run_metadata%p = c_null_ptr
        endif

        do i = 1, ninputs
            input_value_ptrs(i) = input_values(i)%p
            input_act(i)%oper_ptr = inputs(i)%oper%p
            input_act(i)%index = inputs(i)%index
        end do
        input_act_ptr = c_loc(input_act)

        do i = 1, noutputs
            output_value_ptrs(i) = output_values(i)%p
            output_act(i)%oper_ptr = outputs(i)%oper%p
            output_act(i)%index = outputs(i)%index
        end do
        output_act_ptr = c_loc(output_act)

        do i = 1, ntargets
            target_oper_ptrs(i) = target_opers(i)%p
        end do


        call TF_SessionRun_c( session%p, run_options%p, input_act_ptr, c_loc(input_value_ptrs), ninputs, &
            output_act_ptr, c_loc(output_value_ptrs), noutputs, c_loc(target_oper_ptrs), ntargets, run_metadata%p, &
            stat%p )
            
        ! is there a potential memory leak here?  Only inasmuch as there's already one in the API.
        ! On entry, TF_SessionRun_c will set all output_value Tensors to nullptr, without calling
        ! DeleteTensor or anything on them.  So only call this function with unassigned Tensors
        ! in output_values
        do i = 1, noutputs
            output_values(i)%p = output_value_ptrs(i)
        end do
    end subroutine TF_SessionRun

    subroutine TF_DeleteTensor( tensor )
        use TF_Types
        type(TF_Tensor) :: tensor
        interface
            subroutine TF_DeleteTensor_c( tensor ) bind(c, name="TF_DeleteTensor")
                use iso_c_binding
                type(c_ptr), value :: tensor
            end subroutine TF_DeleteTensor_c
        end interface
        if (.not.c_associated(tensor%p)) then
            return
        endif
        call TF_DeleteTensor_c( tensor%p )
    end subroutine TF_DeleteTensor

    function TF_TensorData( tensor )
        use TF_Types
        type(c_ptr)     :: TF_TensorData
        type(TF_Tensor) :: tensor

        type(c_ptr)     :: temp_c_ptr
        interface
            function TF_TensorData_c( tensor ) bind(c, name="TF_TensorData")
                use iso_c_binding
                type(c_ptr) :: TF_TensorData_c
                type(c_ptr), value :: tensor
            end function TF_TensorData_c
        end interface

        TF_TensorData = TF_TensorData_c( tensor%p )
    end function TF_TensorData

    function TF_NumDims( tensor )
        use TF_Types
        integer(kind=c_int) :: TF_NumDims
        type(TF_Tensor) :: tensor

        interface
            function TF_NumDims_c( tensor ) bind(c, name="TF_NumDims")
                use iso_c_binding
                integer(kind=c_int) :: TF_TensorData_c
                type(c_ptr), value :: tensor
            end function TF_NumDims_c
        end interface

        TF_NumDims = TF_NumDims_c( tensor%p )
    end function TF_NumDims

    function TF_Dim( tensor, indx )
        use TF_Types
        integer(kind=c_int64_t) :: TF_Dim
        type(TF_Tensor) :: tensor
        integer(kind=c_int) :: indx

        interface
            function TF_Dim_c( tensor, indx ) bind(c, name="TF_Dim")
                use iso_c_binding
                integer(kind=c_int64_t) :: TF_TensorData_c
                type(c_ptr), value :: tensor
                integer(kind=c_int) :: indx
            end function TF_Dim_c
        end interface

        TF_Dim = TF_Dim_c( tensor%p, indx )
    end function TF_Dim

end module TF_Interface
