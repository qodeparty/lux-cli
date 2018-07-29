#!/usr/bin/env bash
	function add_var(){
		LUX_CLI_VARS+=($@)
	}

  function fnmatch(){ case "$2" in $1) return 0 ;; *) return 1 ;; esac ; }
	function in_string(){ [ -z "${2##*$1*}" ]; }

  function escape_sed_regex(){
  	sed -e 's/[]\/$*.^[]/\\&/g' <<< "$1"
	}
  function quoteRe() { sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n' <<<"$1" | tr -d '\n'; }

	function insert_where(){ insert="$1" ; into="$2" ; where="$3" ; sed -e "/\s*${where}/r ${insert}" "$into" ; }
	function insert_wh_replace () {
		tmp=$(mktemp) ;
		insert_where "$@" > "$tmp" ;
		mv "$tmp" "$2" ;
	}

	function insert_at(){ insert="$1" ; into="$2" ; at="$3" ; sed -e "${at}r ${insert}" "$into" ; }
	function insert_at_replace(){ tmp=$(mktemp) ; insert_at "$@" > "$tmp" ; mv "$tmp" "$2" ; }

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

	function join_by(){
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

	function upd_array(){
		local val="$1"; shift;
		local list=($@)
		local id="${val:1}"

		local list2="$(join_by \| ${list[@]})"
		local xfound=

		#og "List2 $list2"

		case "|$list2|" in
			*"|$id|"*) xfound=0;;
			*) xfound=1;;
		esac

		#__print "Val is ($val) Id is ($id)"

		#in_array $id "${list[@]}"
		#local found=$?
		#log "Found ($id)? with x($xfound) vs f($found)"

		#then look for +val -val ?val -- using xfound instead of found
		#[ $xfound -eq 0 ] && log "Found ($id) in array."
		#
		if [[ "$val" =~ ^-.*  ]]; then
			[ $xfound -eq 0 ] && list=($(pop_array "$id" "${list[@]}"))
		elif [[ "$val" =~ ^\+.* ]]; then
			[ $xfound -eq 1 ] && list+=($id)
		elif [[ "$val" =~ ^\?.* ]]; then
			[ $xfound -eq 1 ] && list+=($id) || list=($(pop_array "$id" "${list[@]}"))
		else
			__print "Invalid ($val) missing (+ add - rem ? toggle )"
			return 1
		fi

		val="${list[*]}"
		#log "new val => $val"
		echo "$val"
		return 0
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

#these sed functions need some love but they work

	function search_replace_bash(){
		target="$1"
		res=($(grep 'source' $target -n | awk '{print $1 $3}'))
		lines=()
		files=()

		tmp_target="${target}.copy"

		cp "$target" "$tmp_target"

		for i in ${!res[@]}; do
			this=${res[$i]}
			file_ref=${this##*:}
			line_no=${this%%:*}
			lines+=($line_no)
			files+=($file_ref)
		done

		for i in ${!lines[@]}; do
			this=${lines[$i]}
			ref=${files[$i]}
			info "Trying to replace line $ref at $this"
			qref=$(quoteRe "source $ref")

			info "$ref $qref"
			insert_wh_replace "$ref" "$tmp_target" "$qref"

			#sed -i.bak -e "/${qref}/d" "$target" #delete line number
			name=$(basename $ref)
			data="$bline\n## import file:${name%%\.sh*} ##\n$bline"
			#qdata=$(quoteRe "$data")

			sed -i.bak -e "s|.*${qref}.*|${data}|i" $tmp_target
			qref=$(quoteRe "#!")

			#remore leading shebang after line 15
			sed -i.bak -e "15,\${ /^${qref}.*/d }" "$tmp_target"

		done
		echo "$tmp_target"
	}

	function makebin(){
		target="$1"
		dest="$2"
		tmp_file=$(search_replace_bash "$@")
		silly "$THIS_ROOT"
		mv "$tmp_file" "./luxbin"
	}
