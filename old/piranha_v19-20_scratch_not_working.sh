	if [[ "$FUNCTION_TO_RUN" != "NULL" ]] && [[ ! -s "$FUNCTION_ARGUMENTS" ]] ; then

		echo "INFO      | $(date) |          Execution with no arguments..."
	#	source "$MY_EXECUTION_PATH" ;
		sh "$MY_EXECUTION_PATH" ;

	elif [[ "$FUNCTION_TO_RUN" != "NULL" ]] && [[ -s "$FUNCTION_ARGUMENTS" ]] && [[ "$FUNCTION_ARGUMENTS" != "NULL" ]] ; then

		echo "INFO      | $(date) |          Execution with -a flag arguments..."
	#	source "$MY_EXECUTION_PATH" '"$FUNCTION_ARGUMENTS"' ;
	#	sh "$MY_EXECUTION_PATH" '"$FUNCTION_ARGUMENTS"' ;
		sh "$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;
	fi


#sh "$MY_EXECUTION_PATH" '"$FUNCTION_ARGUMENTS"' ;



"$MY_EXECUTION_PATH" 









#	if [[ -s "$FUNCTION_ARGUMENTS" ]]; then echo "-s test found _no_ function arguments..."; fi
#	if [[ ! -s "$FUNCTION_ARGUMENTS" ]]; then echo "-s test found function arguments..."; fi
	
	echo "INFO      | $(date) |          Execution with -a flag arguments..."
	# source "$MY_EXECUTION_PATH" '"$FUNCTION_ARGUMENTS"' ;
	# sh "$MY_EXECUTION_PATH" '"$FUNCTION_ARGUMENTS"' ;
	# sh "$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;
	# source "$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;
	# bash "$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;
	"$MY_EXECUTION_PATH" "$FUNCTION_ARGUMENTS" ;








