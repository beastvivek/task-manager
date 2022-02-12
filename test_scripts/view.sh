function test_view_valid_id() {
	local task_data=($@)
	local test_description="Should show details of the task"
	local id=$(( ${task_data[0]} + 1 ))

	local data="id:|${id}\nstatus:|${STATUS_PENDING}\ndescription:|cooking\ntags:|[paneer rice]"
	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( view_details ${task_data[@]} "${id}|1|cooking|paneer,rice" $id )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_view_invalid_id () {
	local task_data=($@)
	local test_description="Should show an error for invalid id"
	local id=$(( ${task_data[0]} + 1 ))

	local expected="Invalid id"
	local actual=$( view_details ${task_data[@]} $id )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_view() {
	local task_data=($@)
	test_heading "view"

	test_view_valid_id ${task_data[@]}
	test_view_invalid_id ${task_data[@]}
}
