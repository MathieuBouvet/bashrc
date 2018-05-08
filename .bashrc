alias symfony="php bin/console"
alias composer="php /C/wamp64/www/composer.phar"
#
# revert to original git completion : execute this command
# complete -o bashdefault -o default -o nospace -F __git_wrap__git_main git

declare -a MY_GIT_EXTENDED_OPTIONS=("qlog" "subldiff" "sublshow")

_extended_git_completion(){
	local cur prev opts
	__git_wrap__git_main # Recupère la completion git
  	
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  #opts="qlog subldiff sublshow"
  opts="${MY_GIT_EXTENDED_OPTIONS[@]}"
  #echo -e "\n 2nd word :MMM"${COMP_WORDS[1]}"MMM"
  if [[ ${cur} == * ]] ; then
  	for i in ${!COMPREPLY[@]}; do
      COMPREPLY[$i]=${COMPREPLY[$i]/% /} # Supprime l'espace en trop
    done
    if [[ -z "${COMP_WORDS[2]}" ]]; then # n'ajoute mes options que si le troisième mot est vide (pas l'idéal)
  		COMPREPLY=("${COMPREPLY[@]}" $(compgen -W "${opts}" -- ${cur}) ) # ajoute à la completion git les options personnellement ajoutées
  	fi
    return 0
  fi
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
		command git log -n $2 --oneline "${@:3}"
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