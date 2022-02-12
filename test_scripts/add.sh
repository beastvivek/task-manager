function test_add_task() {
	local task_data=( $@ )
	local test_description="Should show the message for added task"
	local id=$(( ${task_data[0]} + 1 ))
	local expected="Created task ${id}."

	local actual=$( add_task ${task_data[@]} "Reading" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_add_data() {
	local task_data=($@)
	local test_description="Should add the task with no tags"
	local id=$(( ${task_data[0]} + 1 ))
	local expected="${id}|1|Playing Games|"

	local modified_array=( $( add_data ${task_data[@]} "Playing Games" ) )
	local actual=${modified_array[@]:(-1)}
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_add_data_tags() {
	local task_data=($@)
	local test_description="Should add the task with given tags"
	local id=$(( ${task_data[0]} + 1 ))
	local expected="${id}|1|Playing Games|cricket,football"

	local modified_array=( $( add_data ${task_data[@]} "Playing Games" "tags:football,cricket" ) )
	local actual=${modified_array[@]:(-1)}
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function verify_id() {
	local task_data=($@)
	local test_description="Should store the id"
	local expected=$(( ${task_data[0]} + 1 ))

	local modified_array=( $( add_data ${task_data[@]} "Cooking" ) )
	local actual=${modified_array[0]}
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_add() {
	local task_data=( $@ )

	test_heading "add"

	test_add_task ${task_data[@]}
	test_add_data ${task_data[@]}
	test_add_data_tags ${task_data[@]}
	verify_id ${task_data[@]}
}
