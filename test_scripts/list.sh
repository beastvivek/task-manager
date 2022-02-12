function test_list () {
	local task_data=($@)
	local data="id|description|tags\n\
--|-----------|----\n\
2.|Playing Games|[]\n\
3.|Shopping|[clothes shoes]"

	test_heading "list"

	local expected=$( echo -e  "${data}" | column -t -s"|" )
	local actual=$( list_pending_tasks ${task_data[@]} )
	assert_expectation "${expected}" "${actual}" "Should list pending tasks"
}
