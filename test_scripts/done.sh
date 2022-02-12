function test_valid_marking() {
	local task_data=($@)
	local test_description="Should show the message for marking task as done"
	local id=$(( ${task_data[0]} + 1 ))

	local expected="Marked task $id Meet friends as done."
	local actual=$( mark_done ${task_data[@]} "$id|1|Meet friends|" ${id} )
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_change_status() {
	local task_data=($@)
	local test_description="Should change the status to done"
	local id=$(( ${task_data[0]} + 1 ))

	local expected="$id|0|Go to party|"
	local modified_array=( $( change_status ${task_data[@]} "$id|1|Go to party|" ${id} ) )
	local actual=${modified_array[@]:(-1)}
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_invalid_marking() {
	local task_data=($@)
	local test_description="Should show an error for invalid id"
	local id=$(( ${task_data[0]} + 1 ))

	local expected="Invalid task id."
	local actual=$( mark_done ${task_data[@]} )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_done() {
	local task_data=($@)
	test_heading "done"

	test_valid_marking ${task_data[@]}
	test_change_status ${task_data[@]}
	test_invalid_marking ${task_data[@]}
}
