function test_existing_file() {
	local test_description="Should pass when file exists"
	local file="${DATA_FILE}"

	local expected=0
	validate_file ${file}
	local actual=$?
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_non_existing_file() {
	local test_description="Should fail when file doesn't exist"
	local file="test_scripts/created_file.txt"

	local expected=1
	validate_file ${file}
	local actual=$?
	rm ${file}
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_validate_file() {
	test_heading "validate_file"

	test_existing_file
	test_non_existing_file
}
