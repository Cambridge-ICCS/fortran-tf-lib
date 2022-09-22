module ml_model
	use TF_Types
	use TF_Interface

	implicit none

	public ml_model_init, ml_model_calc, ml_model_finish

	! Each model needs a session and a graph variable.
        {% for m in model_dirs %}
	! Model: {{ m }}
	type(TF_Session) :: model_session_{{ loop.index }}
	type(TF_Graph) :: model_graph_{{ loop.index }}

	! Input and output details
	! Put input / output operations here.
        {% endfor %}
	! Filenames for directories containing models
	character({{ model_dirs | map('length') | max }}), dimension({{ model_dirs | length }}) :: model_dirs

	contains

	subroutine ml_model_init()
		character({{ tags | map('length') | max }}), dimension({{ tags | length }}) :: tags
		integer :: i

		! Load the tags
        {% for t in tags %}
		tags({{ loop.index }}) = '{{ t }}'
        {% endfor %}

		! Rather than hard-coding the filenames here, you probably
		! want to load them from a config file or similar.
        {% for m in model_dirs %}
		model_dirs({{ loop.index }}) = '{{ m }}'
        {% endfor %}

		! Load all the models.
		! If you have a model with different needs (tags, etc)
		! edit this to handle that model separately.

        {% for m in model_dirs %}
		! Model: {{ m }}
		model_graph_{{ loop.index }} = TF_NewGraph()
		call load_model(model_session_{{ loop.index }}, &
			model_graph_{{ loop.index }}, &
			tags, model_dirs(i))
        {% endfor %}

		! Populate the input / output operations.

	end subroutine ml_model_init

	subroutine load_model(session, graph, tags, model_dir)

		type(TF_Session) :: session
		type(TF_Graph) :: graph
		character(*), dimension({{ tags | length }}) :: tags
		character(*) :: model_dir

		type(TF_SessionOptions) :: sessionoptions
		type(TF_Status) :: stat
		character(100) :: message

		sessionoptions = TF_NewSessionOptions()
		stat = TF_NewStatus()

		session = TF_LoadSessionFromSavedModel(sessionoptions, &
			model_dir, &
			tags, size(tags, 1), graph, stat)

		if (TF_GetCode( stat ) .ne. TF_OK) then
			call TF_Message( stat, message )
			write(*,*) TF_GetCode( stat ), message
			stop
		endif

		call TF_DeleteSessionOptions(sessionoptions)
		call TF_DeleteStatus(stat)

	end subroutine load_model

	! Add parameters here for your inputs, outputs,
	! scalers, etc.
	subroutine ml_model_calc(session, inputs, outputs)

		type(TF_Session) :: session
		type(TF_Tensor), dimension(*) :: inputs
		type(TF_Tensor), dimension(*) :: outputs

		type(TF_Status) :: stat
		character(100) :: message

		stat = TF_NewStatus()

		call TF_DeleteStatus(stat)
	end subroutine ml_model_calc

	subroutine ml_model_finish
		
		type(TF_Status) :: stat
		character(100) :: message

		stat = TF_NewStatus()
        {% for m in model_dirs %}
		call TF_DeleteSession( model_session_{{ loop.index }}, stat )
		if (TF_GetCode( stat ) .ne. TF_OK) then
			call TF_Message( stat, message )
			write(*,*) TF_GetCode( stat ), message
			! we don't stop here so all resources can try to delete
		endif
		call TF_DeleteGraph( model_graph_{{ loop.index }} )
        {% endfor %}
		call TF_DeleteStatus( stat )

	end subroutine ml_model_finish
end module ml_model
