function test_longlist_no_tags() {
	local task_data=($@)
	local test_description="Should list all tasks"
	local data="id|status|description|tags\n\
--|------|-----------|----\n\
1.|  ${STATUS_DONE}|Reading|[]\n\
2.|  ${STATUS_PENDING}|Playing Games|[]\n\
3.|  ${STATUS_PENDING}|Shopping|[clothes shoes]\n\
4.|  ${STATUS_DONE}|Washing|[clothes]"

	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( list_all_tasks ${task_data[@]} )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_longlist_valid_tags() {
	local task_data=($@)
	local test_description="Should list tasks for matching tags"
	local data="id|status|description|tags\n\
--|------|-----------|----\n\
3.|  ${STATUS_PENDING}|Shopping|[clothes shoes]\n\
4.|  ${STATUS_DONE}|Washing|[clothes]"

	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( list_all_tasks ${task_data[@]} "tags:clothes" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_longlist_invalid_tags() {
	local task_data=($@)
	local test_description="Should list no tasks when tags don't match"
	local data="id|status|description|tags\n\
--|------|-----------|----"

	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( list_all_tasks ${task_data[@]} "tags:clot" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_longlist() {
	local task_data=($@)

	test_heading "longlist"

	test_longlist_no_tags ${task_data[@]}
	test_longlist_valid_tags ${task_data[@]}
	test_longlist_invalid_tags ${task_data[@]}
}
