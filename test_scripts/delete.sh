function test_valid_deletion() {
	local task_data=($@)
	local test_description="Should show the message for deleted task"
	local id=$(( ${task_data[0]} + 1 ))

	local expected="Deleted task ${id} Go to market"
	local actual=$( delete_task ${task_data[@]} "${id}|1|Go to market|" "$id" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_delete_data() {
	local task_data=($@)
	local test_description="Should delete the task from data file"
	local id=$(( ${task_data[0]} + 1 ))
	local expected=${task_data[@]}

	local actual=$( delete_data ${task_data[@]} "${id}|1|Go to market|" "$id" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_invalid_deletion() {
	local task_data=($@)
	local test_description="Should show an error for invalid id"
	local id=$(( ${task_data[0]} + 1 ))

	local expected="Invalid task id"
	local actual=$( delete_task ${task_data[@]} "$id" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_delete() {
	local task_data=($@)

	test_heading "delete"

	test_valid_deletion ${task_data[@]}
	test_delete_data ${task_data[@]}
	test_invalid_deletion ${task_data[@]}
}
