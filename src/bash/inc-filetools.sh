#!/usr/bin/env bash
dtrace "loading ${BASH_SOURCE[0]}"

	function find_dirs(){
		info "Finding repo folders..."
		warn "This may take a few seconds..."
		this="$cmd_find ${2:-.} -mindepth 1"
		[[ $1 =~ "1" ]] && this+=" -maxdepth 2" || :
		[[ $1 =~ git ]] && this+=" -name .git"  || :
		this+=" -type d ! -path ."
		awk_cmd="awk -F'.git' '{ sub (\"^./\", \"\", \$1); print \$1 }'"
		cmd="$this | $awk_cmd"
		__print "$cmd"
		eval "$cmd" #TODO:check if theres a better way to do this
	}


	function file_marker(){
		local delim dst dend mode lbl
		mode="$1"
		lbl="$2"
		delim="$3"
		dst='#'; dend='#';
		[ "$delim" = "js" ] && dst='\/\*'; dend='\*\/' || :
		if [ "$mode" = "str" ]; then
			str="${dst}----${block_lbl}:str----${dend}"
		else
			str="${dst}----${block_lbl}:end----${dend}"
		fi
		# __print "$str"
		echo "$str"
	}


	function file_add_block(){
		local newval src block_lbl match_st match_end data res ret
		newval="$1"; src="$2"; block_lbl="$3"; delim="$4"; ret=1;
		match_st=$(file_marker "str" "${block_lbl}" "${delim}" )
		match_end=$(file_marker "end" "${block_lbl}" "${delim}" )

		#check if block already exists...
		res=$(file_find_block "$src" "$block_lbl" "${delim}" )
		ret=$?

		if [ $ret -gt 0 ]; then #nomatch
			data="$(cat <<-EOF
				${match_st}
				#added:$(date +%d-%m-%Y" "%H:%M:%S)
				${newval}
				${match_end}
			EOF
			)";
			echo "$data" >> $src
			ret=$?
		fi
		return $ret
	}



	function file_del_block(){
		local src block_lbl match_st match_end data res ret dst dend
		src="$1"
		block_lbl="$2"
		delim="$3";

		match_st=$(file_marker "str" "${block_lbl}" "${delim}" )
		match_end=$(file_marker "end" "${block_lbl}" "${delim}" )

		$cmd_sed -i.bak "/${match_st}/,/${match_end}/d" "$src" #this works on ubuntu
		ret=$?
		#make sure it was removed

		if [ -f "$src" ]; then
			res=$(file_find_block "$src" "$block_lbl" "${delim}" )
			ret=$?

			#flip ret, if notfound then success
			[ $ret -gt 0 ] && ret=0 || ret=1

			#log "$(res $ret) Cannot Find? (Delete Complete)"
			rm -f "${src}.bak"
		else
			error "File (${src}) wasn't found. Cannot delete block $block_lbl"
			ret=1;
		fi

		return $ret
	}


	function file_find_block(){
		local src block_lbl match_st match_end data res ret
		trace "${FUNCNAME[0]}"
		src="$1"; block_lbl="$2"; delim="$3"; ret=1
		match_st=$(file_marker "str" "${block_lbl}" "${delim}")
		match_end=$(file_marker "end" "${block_lbl}" "${delim}")
		res=$($cmd_sed -n "/${match_st}/,/${match_end}/p" "$src")
		[ -z "$res" ] && ret=1 || ret=0;
		echo "$res"
		return $ret;
	}


	function profile_link(){
		local ret res data
		trace "${FUNCNAME[0]}"
		[ ! -f "$LUX_RC" ] && lux_make_rc || :
		if [ -f "$LUX_RC" ]; then
			src="$BASH_PROFILE" #link to bashrc so vars are available to subshells?
			[ ! -f "$src" ] && touch "$src"
			lbl="$script_id"
			res=$(file_find_block "$src" "$lbl" ); ret=$?
			if [ $ret -eq 1 ]; then
				data="$(cat <<-EOF
					${tab} if [ -f "$LUX_RC" ] ; then
					${tab}   source "$LUX_RC"
					${tab} else
					${tab}   [ -t 1 ] && echo "\$(tput setaf 214).luxrc is missing, lux link or unlink to fix ${x}" ||:
					${tab} fi
				EOF
				)";
				res=$(file_add_block "$data" "$src" "$lbl" )
				ret=$?
			fi
		else
			error "Profile doesnt exist @ $BASH_PROFILE"
		fi

	}


	function profile_unlink(){
		local ret res data src lbl
		trace "${FUNCNAME[0]}"
		src="$BASH_RC"
		lbl="$LUX_ID"
		if [ -f "$LUX_RC" ]; then
			trace "supposedly removing $LUX_RC"
			rm "$LUX_RC"
		else
			warn "$LUX_RC was not found"
		fi
		res=$(file_del_block "$src" "$lbl" )
		ret=$?
		[ $ret -eq 0 ] && __print ".luxrc removed from $BASH_RC" "red" ||:
	}

