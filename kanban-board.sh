#!/bin/bash

readonly RED="$(tput setaf 1)" 
readonly GREEN="$(tput setaf 2)" 
readonly BLUE="$(tput setaf 4)" 
readonly BOLD="$(tput bold)" 
readonly BLINK="$(tput bold)" 
readonly RESET="$(tput sgr0)"
readonly uname=$(uname)

check_backlog() {
	if ! [[ -f backlog ]]; then
		echo "No backlog file. Create backlog with tasks."
		exit 0
	fi

	task_count=$(cat backlog | wc -l)
	if (($task_count == 0)); then
		echo "Backlog is empty. Add some tasks first."
		exit 0
	fi
}

prepare_sprint() {
	# remove empty lines	
	if [[ $uname == 'Darwin' ]]; then
		sed -i '' "/^$/d" backlog
	else
		sed -i "/^$/d" backlog
	fi	
	
	# truncate lines to mactch wall size and prevent overflow
	# does not alter the backlog file
	sed "s/^\(.\{40\}\).*/\1/" backlog > tmp

	# add state to tasks
	sed "s/$/##todo/" tmp > sprint.dat
	rm tmp
}

show_menu() {
  read -p "Enter task number to change status (or + to add task): " choice
  case $choice in
    [0-9]*)
      get_task $choice 
      get_status	
      ;;
    +)
      add_task
      ;;
    *)
      echo -e "${RED}Illegal choice.${RESET}"
      show_menu
      ;;
  esac
}

draw_sprint() {
	clear
	echo -e "\n"
	awk -F "##" -f board.awk sprint.dat

	echo -e "\n\n"
  show_menu
}

init_sprint() {
	check_backlog
	prepare_sprint
	draw_sprint
}

get_task() {
  task_num=$1
  #read -p "Enter task number to change status: " task_num
  number_of_tasks=$(cat sprint.dat | wc -l)
  # verify input is numerical
  if (! [[ $task_num =~ ^[1-9][0-9]*$ ]] ); then
    echo -e "${RED}Illegal task number.${RESET}"
    show_menu
  fi
  # verify input in range 
  if (($task_num > $number_of_tasks)); then
    echo -e "${RED}Illegal task number.${RESET}"
    show_menu
  fi
}

get_status() {
	read -p "New status (todo|doing|done): " status
	case $status in
		todo|doing|done)
			set_status "$task_num" "$status"
			;;
		*)
			echo -e "${RED}Illegal status.${RESET}"
			get_status
			;;
	esac
}

set_status() {
	if [[ $uname == 'Darwin' ]]; then
		sed -i ''	"$1s/##.*/##$2/" sprint.dat
	else
		sed -i "$1s/##.*/##$2/" sprint.dat
	fi	
	draw_sprint
}

add_task () {
  read -p "New task: " task
  echo $task >> backlog 
  echo "${task}##todo" >> sprint.dat
  draw_sprint
}


if ! [[ -f sprint.dat ]]; then
  init_sprint
else
  draw_sprint
fi

