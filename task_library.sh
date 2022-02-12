DATA_FILE="data_files/tasks_data.psv"
STATUS_PENDING="⌛️"
STATUS_DONE="✔ "

function validate_file() {
	local file=$1

	if [[ ! -e ${file} ]]
	then
		echo "0" > ${file}
		return 1
	fi
	return 0
}

function extract_data() {
	IFS=$'\n'
 	local task_data=( $( cat ${DATA_FILE} ) )

	for element in "${task_data[@]}"
	do
		echo "${element}"
	done
}

function write_data() {
	local task_data=($@)

	local data
	data=$( for element in ${task_data[@]}
	do echo "$element"
	done )

	echo "${data}" > ${DATA_FILE}
}

function validate_argument() {
	local argument=$1

	if [[ -z $argument ]]
	then
		echo "task: argument can't be empty"
		return 1
	fi
	return 0
}

function show_help() {
	echo "task add <description> <tags> for adding a task"
	echo "task list for listing all tasks"
	echo "task done <id> for marking a task as done"
	echo "task delete <id> for deleting a task"
	echo "task longlist for listing all tasks with status"
	echo "task help for showing this help"
}

function sort_tags() {
	local tags=$1
	local sorted_tags=$( echo -n "${tags}" | tr "," "\n" | sort )
	sorted_tags=$( echo -n "${sorted_tags}" |  tr "\n" "," )
	echo "${sorted_tags}"
}

function add_data() {
	local task_data=($@)
	local id=$(( ${task_data[0]}  + 1 ))
	local length=${#task_data[@]}
	local task_description="${task_data[@]:(-1)}"
	local tags=""
	local number=1

	if echo "${task_data[@]:(-1)}" | grep -q "tags:"
	then
		task_description="${task_data[@]:(-2):1}"
		tags=$( echo "${task_data[@]:(-1)}" | cut -d":" -f2 )
		unset task_data[$(( $length - 1 ))]
		tags=$( sort_tags ${tags} )
		number=2
	fi

	task_data[$(( $length - $number ))]="${id}|1|${task_description}|${tags}"
	task_data[0]=$id

	for element in ${task_data[@]}
	do
		echo "$element"
	done
}

function add_task() {
	local task_data=($@)
	local next_id=$(( ${task_data[0]} + 1 ))

	task_data=( $( add_data ${task_data[@]} ) )
	local status=$?
	if [[ $status -eq 0 ]]
	then
		write_data ${task_data[@]}
		echo "Created task ${next_id}."
	fi
}

function display_tasks() {
	local list_heading=$1
	local tasks=$2
	local separator="$( echo "$list_heading" | tr "[:alpha:]" "-" )"

	echo -e "${list_heading}\n${separator}\n${tasks}" | column -t -s"|"
}

function list_pending_tasks (){
	local task_data=($@)
	local list_heading="id|description|tags"
	local tasks=$( for element in ${task_data[@]}
	do
		local tags=$( echo $element | cut -d "|" -f4 | tr "," " " )
		echo $element | sed -n "s/|1|/.|/ ; s/\(.*\)|\(.*\)/\1|[${tags}]/ ; /\.|/ p"
	done )

	display_tasks "$list_heading" "$tasks"
}

function list_all_tasks () {
	local task_data=($@)
	local tags=".*"
	local list_heading="id|status|description|tags"

	if echo ${task_data[@]:(-1)} | grep -q "tags:.*"
	then
		tags=$( echo ${task_data[@]:(-1)} | cut -d ":" -f2 )
		tags=$( sort_tags ${tags} )
	fi

	local tasks=$( for element in ${task_data[@]}
	do
		if echo $element | egrep -q "(\|.*\|.*\|.*,${tags},)|(\|.*\|.*\|.*,${tags}$)|(\|.*\|.*\|${tags},)|(\|.*\|.*\|${tags}$)"
		then
			local task_tags=$( echo $element | cut -d "|" -f4 | tr "," " " )
			echo $element | sed "s/|1|/.|  ${STATUS_PENDING}|/ ; s/|0|/.|  ${STATUS_DONE}|/; s/\(.*\)|\(.*\)/\1|[${task_tags}]/"
		fi
	done )

	display_tasks "$list_heading" "$tasks"
}

function delete_data() {
	local task_data=($@)
	local id=${task_data[@]:(-1)}
	local last_index=$(( ${#task_data[@]} - 1 ))
	unset task_data[$last_index]
	local index=1

	while [[ $index -lt ${#task_data[@]} ]]
	do
		if echo "${task_data[$index]}" | grep -q "^$id|"
		then
			unset task_data[$index]
			break
		fi
		index=$(( $index + 1 ))
	done

	for element in ${task_data[@]}
	do
		echo "$element"
	done
}

function delete_task() {
	local task_data=($@)
	local message="Invalid task id"
	local id=${task_data[@]:(-1)}
	local last_index=$(( ${#task_data[@]} - 2 ))

	for element in ${task_data[@]}
	do
		if echo "${element}" | grep -q "^$id|"
		then
			local task_description=$( echo ${element} | cut -d"|" -f3 )
			task_data=( $( delete_data ${task_data[@]} ) )
			local status=$?
			if [[ $status -eq 0 ]]
			then
				write_data ${task_data[@]}
				message="Deleted task $id $task_description"
			fi
		fi
	done
	echo "$message"
}

function change_status() {
	local task_data=($@)
	local id=${task_data[@]:(-1)}
	local last_index=$(( ${#task_data[@]} - 1 ))
	unset task_data[$last_index]
	local index=1

	while [[ $index -lt ${#task_data[@]} ]]
	do
		if echo "${task_data[$index]}" | grep -q "^$id|"
		then
			task_data[$index]=$( echo "${task_data[$index]}" | sed "s/|1|/|0|/" )
			break
		fi
		index=$(( $index + 1 ))
	done

	for element in ${task_data[@]}
	do
		echo "$element"
	done
}

function mark_done() {
	local task_data=($@)
	local id=${task_data[@]:(-1)}
	local last_index=$(( ${#task_data[@]} - 2 ))
	local message="Invalid task id."

	for element in ${task_data[@]}
	do
		if echo "${element}" | grep -q "^$id|"
		then
			local task_description=$( echo ${element} | cut -d"|" -f3 )
		 	task_data=( $( change_status ${task_data[@]} ) )
		 	local status=$?
		 	if [[ $status -eq 0 ]]
		 	then
				write_data ${task_data[@]}
				message="Marked task ${id} ${task_description} as done."
			fi
		fi
	done

	echo "$message"
}

function view_details() {
	local task_data=($@)
	local id=${task_data[@]:(-1)}
	local last_index=$(( ${#task_data[@]} - 1 ))
	unset task_data[$last_index]
	local message="Invalid id"

	for element in ${task_data[@]}
	do
		if echo "${element}" | grep -q "^${id}|"
		then
			IFS=$'\n'
			local details=( $( echo "${element}" | sed "s/|1|/|${STATUS_PENDING}|/ ; s/|0|/|${STATUS_DONE}|/" | tr "|" "\n" ) )
			details[3]=$( echo "${details[3]}" | tr "," " " )
			local data="id:|${details[0]}\nstatus:|${details[1]}\ndescription:|${details[2]}\ntags:|[${details[3]}]"
			message=$( echo -e "${data}" | column -t -s"|" )
		fi
	done
	echo "${message}"
}

function main() {
	local subcommand=$1
	local first_argument=$2
	local second_argument=$3
	local available_subcommands="help|list|longlist|add|delete|done|view"

	if ! echo "${available_subcommands}" | grep -q "${subcommand}"
	then
		echo "usage: task subcommand [argument]"
		return 1
	fi

	validate_file ${DATA_FILE}

	IFS=$'\n'
	local task_data=( $( extract_data ) )

	if [[ $subcommand == "help" ]]; then show_help; fi;
	if [[ $subcommand == "list" ]]; then list_pending_tasks ${task_data[@]}; fi;
	if [[ $subcommand == "longlist" ]]; then list_all_tasks ${task_data[@]} ${first_argument}; fi;

	if [[ $subcommand == "add" ]]
	then
		if validate_argument $first_argument; then add_task ${task_data[@]} "${first_argument}" "${second_argument}" ; fi
	fi

	if [[ $subcommand == "delete" ]]
	then
		if validate_argument $first_argument; then delete_task ${task_data[@]} "${first_argument}"; fi
	fi

	if [[ $subcommand == "done" ]]
	then
		if validate_argument $first_argument; then mark_done ${task_data[@]} "${first_argument}"; fi
	fi

	if [[ $subcommand == "view" ]]
	then
		if validate_argument $first_argument; then  view_details ${task_data[@]} "${first_argument}"; fi
	fi

}
