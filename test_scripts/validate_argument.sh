function test_return_status() {
	local test_description=$1
	local expected=$2
	local argument=$3
	validate_argument "${argument}" > /dev/null
	local actual=$?
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_message() {
	local test_description="Should show an error for empty argument"
	local expected="task: argument can't be empty"
	local actual=$( validate_argument "" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_validate_argument() {
	test_heading "validate_argument"

	local test_description="Should pass for non empty argument"
	test_return_status "${test_description}" 0 "123"

	test_description="Should fail for empty argument"
	test_return_status "${test_description}" 1 ""

	test_message
}
