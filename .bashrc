alias symfony="php bin/console"
alias composer="php /C/wamp64/www/composer.phar"
#
# revert to original git completion : execute this command
# complete -o bashdefault -o default -o nospace -F __git_wrap__git_main git

declare -a MY_GIT_EXTENDED_OPTIONS=("qlog" "subldiff" "sublshow")
declare -a QLOG_AVAILABLE_OPTIONS=("--all" "--graph")
declare -a SUBLDIFF_AVAILABLE_OPTIONS=("--cached" "HEAD" "ORIG_HEAD" "FETCH_HEAD")

_extended_git_completion(){
	local cur prev opts

	__git_wrap__git_main # Recupère la completion git

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="${MY_GIT_EXTENDED_OPTIONS[@]}"
  qlog_opts="${QLOG_AVAILABLE_OPTIONS[@]}"
  subldiff_opts="${SUBLDIFF_AVAILABLE_OPTIONS[@]}"

	for i in ${!COMPREPLY[@]}; do
    COMPREPLY[$i]=${COMPREPLY[$i]/% /} # Supprime l'espace en trop
  done
  if [[ "${COMP_WORDS[1]}" == "$cur" ]]; then # n'ajoute mes options que si on est en train de taper le 2eme mot
		# ajoute à la completion git les options personnellement ajoutées
		COMPREPLY=("${COMPREPLY[@]}" $(compgen -W "${opts}" -- ${cur}) ) 
	fi

	#QLOG context
	if [[ "${COMP_WORDS[1]}" == "${MY_GIT_EXTENDED_OPTIONS[0]}" ]] ; then 
		COMPREPLY=("${COMPREPLY[@]}" $(compgen -W "${qlog_opts}" -- ${cur}) ) 
	fi

	# SUBLDIFF context
	if [[ "${COMP_WORDS[1]}" == "${MY_GIT_EXTENDED_OPTIONS[1]}" ]] ; then 
		COMPREPLY=("${COMPREPLY[@]}" $(compgen -W "${subldiff_opts}" -- ${cur}) )
		branch_list=$(command git for-each-ref refs/ --format='%(refname:short)')
		COMPREPLY=("${COMPREPLY[@]}" $(compgen -W "${branch_list}" -- ${cur}) )

	fi
  return 0
}
complete -F _extended_git_completion git

foo(){
	echo "$@"
}

cdv(){
	cd $1
	ls
}

subl_diff(){
	git diff "$@" > diff_temp_file
	subl diff_temp_file
	sleep .3
	rm -f diff_temp_file
}

git(){
	#
	#
	# quick log
	if [ "$1" = "${MY_GIT_EXTENDED_OPTIONS[0]}" ]
	then
		# Default value for -n log option
		number_to_show=5
		remaing_parameters_start=${@:2}
		regex_number='^[0-9]+$'
		if [[ "$2" =~ $regex_number ]] ; then # check if second parameter is a number, to override default behavior
			number_to_show=$2
			remaing_parameters_start=${@:3}
		fi
		command git log -n $number_to_show --oneline $remaing_parameters_start
	#
	#
	# display diff in sublime text
	elif [ "$1" = "${MY_GIT_EXTENDED_OPTIONS[1]}" ]
	then
		command git diff "${@:2}" > diff_temp_file
		subl diff_temp_file
		sleep .3
		rm -f diff_temp_file
	#
	#
	# display show in sublime text
	elif [ "$1" = "${MY_GIT_EXTENDED_OPTIONS[2]}" ]
	then
		command git show "${@:2}" > show_temp_file
		subl show_temp_file
		sleep .3
		rm -f show_temp_file
	else
		command git "$@"
	fi
}