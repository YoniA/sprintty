
BEGIN {
	format =  "%-3s|%-40s|%-40s|%-40s|\n"
	border_bottom = "----------------------------------------"

	printf format, "", "TODO", "IN PROGRESS", "DONE"
	printf format, "", border_bottom, border_bottom, border_bottom
}

{
	if ($2 == "todo")
			printf format, NR, $1, "", ""
	else if ($2 == "doing")
			printf format, NR, "", $1, ""
	else if ($2 == "done")
			printf format, NR, "", "", $1


#	switch ($2) {
#		case "todo":
#			printf format, NR, $1, "", ""
#			break
#		case "in-progress"
#			printf format, NR, "", $1, ""
#			break
#		case "done"
#			printf format, NR, "", "", $1
#			break
#		}
}

END {
	printf format, "", border_bottom, border_bottom, border_bottom
}
