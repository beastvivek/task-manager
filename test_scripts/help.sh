function test_help() {
	local help_data_file=$1
	local expected=$( echo -e "task add <description> <tags> for adding a task\n\
task list for listing all tasks\n\
task done <id> for marking a task as done\n\
task delete <id> for deleting a task\n\
task longlist for listing all tasks with status\n\
task help for showing this help" )

	test_heading "help"
	local actual=$( show_help )
	assert_expectation "${expected}" "${actual}" "Should display help"
}
