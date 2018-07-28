#!/usr/bin/env bash
	function add_var(){ LUX_CLI_VARS+=($@) }

	function in_string(){ [ -z "${2##*$1*}" ]; }

	function in_array(){
		local e
		for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
		return 1
	}

  function indexof(){
    local elem args i j list; elem=$1; shift; list=("${@}")
    i=-1;
    for ((j=0;j<${#list[@]};j++)); do
      [ "${list[$j]}" = "$elem" ] && { i=$j; break; }
    done;
    echo $i;
    [[ "$i" == "-1" ]] && return 1 || return 0
  }

	function waitkey(){
		local n l;n=0
		while test $n -lt 3; do
			read l
			sleep 0.2
			echo -n " "
			n=$[n+1]
		done
		printf "$x"
		printf "\r$green$pass Done. $x$eol\n"
		clear
	}

	function joinby(){
		local IFS="$1"; shift;
		echo "$*";
	}


	function pop_array(){
		local match="$1"; shift
		local temp=()
		local array=($@)
		for val in "${array[@]}"; do
		    [[ ! "$val" =~ "$match" ]] && temp+=($val)
		done
		array=("${temp[@]}")
		unset temp
		echo "${array[*]}"
	}

	function sub_dirs(){
		local path=$1
		res=($(find "$path" -type d -printf '%P\n' ))
		echo "${res[*]}"
	}

	function json_maker(){
		vars=( ${LUX_CLI_VARS[@]} ${@})
		str=""
		len=$((${#vars[@]}-1));
		for i in ${!vars[@]}; do
			this="${vars[$i]}"
			this_var="${this#*:}"
			this=${this%%:*}
			printf -v "this" '%s:\"%s\"' "lux_$this" $this_var
			[ $i -lt $len ] && this="${this},"
			str="$str$this"
		done
		printf -v "str" "{%s}" $str #stylus is picky about json format
		echo "$str"

	}