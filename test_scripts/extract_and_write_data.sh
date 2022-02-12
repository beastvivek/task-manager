function test_extract_data() {
	local test_description="Should extract the data from file"

	test_heading "extract_data"

	local expected=$( cat ${DATA_FILE} )
	local actual=$( extract_data )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_write_data() {
	local test_description="Should write data to the file"

	test_heading "write_data"

	local task_data=( "2" "1|1|Watch News|" "2|0|Write Notes|" )
	local expected=${task_data[@]}
	write_data ${task_data[@]}
	local actual=$( cat ${DATA_FILE})
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_extract_and_write_data() {
	test_extract_data
	test_write_data
}
