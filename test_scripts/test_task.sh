source task_library.sh
source test_scripts/add.sh
source test_scripts/help.sh
source test_scripts/list.sh
source test_scripts/longlist.sh
source test_scripts/delete.sh
source test_scripts/main.sh
source test_scripts/display_tasks.sh
source test_scripts/extract_and_write_data.sh
source test_scripts/done.sh
source test_scripts/validate_argument.sh
source test_scripts/sort_tags.sh
source test_scripts/view.sh
source test_scripts/validate_file.sh

DATA_FILE="test_scripts/tasks_data.psv"
TEST_RESULTS=()
TEST_DESCRIPTIONS=()
EXPECTED_RESULTS=()
ACTUAL_RESULTS=()
PASS_SIGN="\033[0;32m✔\033[0m"
FAIL_SIGN="\033[0;31m✗\033[0m"

function test_heading() {
	local function_name=$1
	local bold="\033[1m"
	local normal="\033[0m"
	echo
	echo -e "${bold}${function_name}${normal}"
}

function assert_expectation() {
	local expected=$1
	local actual=$2
	local test_description=$3
	local test_result=$FAIL_SIGN
	local index

	if [[ "$actual" == "$expected" ]]
	then
		test_result=$PASS_SIGN
	fi

	index=${#TEST_RESULTS[@]}
	TEST_RESULTS[$index]="$test_result"
	TEST_DESCRIPTIONS[$index]="$test_description"
	EXPECTED_RESULTS[$index]="$expected"
	ACTUAL_RESULTS[$index]="$actual"

	echo -e "\t$test_result ${test_description}"
}

function delete_added_data(){
	local id=$1
	local last_id=$(( $id - 1 ))
	sed -I "" "1 s/.*/$last_id/ ; /$id|.*|/ d" ${DATA_FILE}
}

function display_test_report() {
	local total_tests=${#TEST_RESULTS[@]}
	local failed_tests=0
	for result in ${TEST_RESULTS[@]}
	do
		if [[ "$result" == "$FAIL_SIGN" ]]
		then
			failed_tests=$(( $failed_tests + 1 ))
		fi
	done
	echo -e "\nFailed tests: ${failed_tests}/${total_tests}"
}

function display_failed_tests() {
	local index=0

	while [[ $index -le ${#TEST_RESULTS[@]} ]]
	do
		if [[ "${TEST_RESULTS[$index]}" == "$FAIL_SIGN" ]]
		then
			echo -e "\n"
			echo -e "${TEST_RESULTS[$index]} ${TEST_DESCRIPTIONS[$index]}"
			echo -e "Expected : \n${EXPECTED_RESULTS[$index]}"
			echo -e "Actual : \n${ACTUAL_RESULTS[$index]}"
		fi
		index=$(( $index + 1 ))
	done
}

function all_test_cases() {
	echo -e "4\n1|0|Reading|\n2|1|Playing Games|\n3|1|Shopping|clothes,shoes\n4|0|Washing|clothes" > ${DATA_FILE}

	IFS=$'\n'
	local task_data=( $( cat ${DATA_FILE} ) )

	test_help
	test_add ${task_data[@]}
	test_list ${task_data[@]}
	test_longlist ${task_data[@]}
	test_delete ${task_data[@]}
	test_done ${task_data[@]}
	test_view ${task_data[@]}
	test_main ${task_data[@]}
	test_display_tasks
	test_extract_and_write_data
	test_validate_argument
	test_sort_tags
	test_validate_file

	display_failed_tests
	display_test_report

	rm ${DATA_FILE}
}

all_test_cases
