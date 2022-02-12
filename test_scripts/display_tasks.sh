function test_display_tasks() {
	local test_description="Should display tasks with the header"
	local data="id|description\n\
--|-----------\n\
1.|Reading\n\
2.|Playing"

	test_heading "display_tasks"

	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( display_tasks "${heading}" "${data}" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}
