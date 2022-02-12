function test_main_help() {
	local test_description="Should display help"
	local expected=$( echo -e "task add <description> <tags> for adding a task\n\
task list for listing all tasks\n\
task done <id> for marking a task as done\n\
task delete <id> for deleting a task\n\
task longlist for listing all tasks with status\n\
task help for showing this help" )

	local actual=$( main help )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_main_list() {
	local test_description="Should list pending tasks"
	local data="id|description|tags\n\
--|-----------|----\n\
2.|Playing Games|[]\n\
3.|Shopping|[clothes shoes]"

	local expected=$( echo -e "$data" | column -t -s"|" )
	local actual=$( main list )

	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_main_longlist_no_tags() {
	local test_description="Should list all tasks"
	local data="id|status|description|tags\n\
--|------|-----------|----\n\
1.|  ${STATUS_DONE}|Reading|[]\n\
2.|  ${STATUS_PENDING}|Playing Games|[]\n\
3.|  ${STATUS_PENDING}|Shopping|[clothes shoes]\n\
4.|  ${STATUS_DONE}|Washing|[clothes]"

	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( main longlist )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_main_longlist_tags() {
	local test_description="Should list tasks for matching tags"
	local data="id|status|description|tags\n\
--|------|-----------|----\n\
3.|  ${STATUS_PENDING}|Shopping|[clothes shoes]\n\
4.|  ${STATUS_DONE}|Washing|[clothes]"

	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( main longlist "tags:clothes" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_main_add() {
	local task_data=( $@ )
	local id=$(( ${task_data[0]} + 1 ))
	local test_description=${task_data[@]:(-1)}
	local tags=""

	if echo "${task_data[@]:(-1)}" | grep -q "tags:"
	then
		test_description=${task_data[@]:(-2):1}
		tags=${test_data[@]:(-1)}
	fi

	local expected="Created task ${id}."
	local actual=$( main add "Reading" "${tags}")
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_main_delete() {
	local task_data=($@)
	local test_description="Should show the message for deleted task"
	local id=$(( ${task_data[0]} + 1 ))

	echo "${id}|1|Go to market|" >> ${DATA_FILE}

	local expected="Deleted task ${id} Go to market"
	local actual=$( main delete $id )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_main_done() {
	local task_data=($@)
	local test_description="Should show the message for marking task as done"
	local id=$(( ${task_data[0]} + 1 ))

	echo "$id|1|Meet grandma|" >> ${DATA_FILE}

	local expected="Marked task $id Meet grandma as done."
	local actual=$( main done ${id} )
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_main_view() {
	local task_data=($@)
	local test_description="Should show details of the task"
	local id=$(( ${task_data[0]} + 1 ))

	echo "$id|1|cooking|paneer,rice" >> ${DATA_FILE}

	local data="id:|${id}\nstatus:|${STATUS_PENDING}\ndescription:|cooking\ntags:|[paneer rice]"
	local expected=$( echo -e "${data}" | column -t -s"|" )
	local actual=$( main view $id )
	assert_expectation "${expected}" "${actual}" "${test_description}"
	delete_added_data "$id"
}

function test_main_unknown() {
	local expected="usage: task subcommand [argument]"
	local test_description="Should show usage for unknown"
	local actual=$( main doing )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_subcommand_without_argument() {
	local subcommand=$1
	local test_description="Should show error when no argument is passed to $subcommand"
	local expected="task: argument can't be empty"
	local actual=$( main $subcommand "" )
	assert_expectation "${expected}" "${actual}" "${test_description}"
}

function test_main() {
	local task_data=($@)

	test_heading "main"

	test_main_help
	test_main_list
	test_main_longlist_no_tags
	test_main_longlist_tags

	local test_description="Should show the message for added task when no tags given"
	test_main_add ${task_data[@]} "${test_description}"
	test_description="Should show the message for added task when tags are given"
	test_main_add ${task_data[@]} "${test_description}" "tags:books,magzine"

 	test_main_delete ${task_data[@]}
 	test_main_done ${task_data[@]}
 	test_main_view ${task_data[@]}
	test_main_unknown

	test_subcommand_without_argument "add"
	test_subcommand_without_argument "delete"
	test_subcommand_without_argument "done"
	test_subcommand_without_argument "view"
}
