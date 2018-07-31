#!/usr/bin/env bash



	function lux_need_align_repos(){
		[ -z "$LUX_WWW"  ] && missing+=( "$LUX_WWW" ) || :
		[ -z "$LUX_CLI"  ] && missing+=( "$LUX_CLI" ) || :
		[ -z "$LUX_DEV"  ] && missing+=( "$LUX_DEV" ) || :
		[ -z "$LUX_CSS"  ] && missing+=( "$LUX_CSS" ) || :
		[ -z "$LUX_HOME" ] && missing+=( "$LUX_HOME" ) || :
		len=${#missing[@]}

		#dump "${missing[@]}"
		[ $len -gt 0 ] && return 0
		#silly "dont need any repos! $len"
		return 1
	}



	function lux_align_repos(){
		local this len buf arr want repo need
		#this="$1"
		buf=(${__alias_list[*]}); ret=$?
		len=${#buf[@]}
		want=(lux lux-cli lux-dev lux-www)
		missing=()


		if [ $len -gt 0 ]; then
			for i in ${!buf[@]}; do
				this="${buf[$i]}"
				repo="${__repo_list[$i]}"
				res=$(in_array "$this" "${want[@]}");ret=$?
				#info "$this $res $ret"
				if [ $ret -eq 0 ]; then
					#silly "found $this"
					case "$this" in
						lux-cli) LUX_CLI="$repo";;
						lux-www) LUX_WWW="$repo";;
						lux-dev) LUX_DEV="$repo";;
						lux) LUX_CSS="$repo"; LUX_HOME="$repo";;
						*) silly "found ?? ($this)";;
					esac
				else
					missing+=("Missing:$this")
				fi
			done


			dump "${missing[@]}"

		else
			dump "${want[@]}"
		fi

	}


	function lux_find_repos(){
		local this len buf arr ndir
		this="$1"
		buf=($(find_dirs "git" "${this}/")); ret=$?
		len=${#buf[@]}

		if [ $len -gt 0 ]; then
			for this in ${buf[@]}; do
				arr=(${this//\// })
				len=${#arr[@]}
				ndir=${arr[((len-1))]}
				if [[ $ndir = *"lux"*  ]]; then
					__repo_list+=( $this )
					__alias_list+=( "$ndir" )
				fi
			done
		fi

		dump "${__repo_list[@]}"
		#dump "${__alias_list[@]}"
	}

	#list excludes files starting with _*
	function lux_listfile(){
		var=$1
		path=$2
		ftype=$3
		jsfile="$LUX_HOME/www/res/js/${var}.js"
		list=($(find "$LUX_HOME/www/${path}" -type f -name "*.${ftype}" ! -name '_*.*' -printf '%P\n' ))
		len=$((${#list[@]}-1));

		printf "%s\\n" "////found $(($len+1)) $ftype files" > $jsfile
		printf "%s\\n" "var ${var} = [" >> $jsfile
		for i in ${!list[@]}; do
			this="'${list[$i]}'"
			[ $i -lt $len ] && this="${this},"
			printf "%s\\n" "$this" >> $jsfile
		done
		printf "%s\\n" "];" >> $jsfile

		#info $LUX_HOME
	}

	#deletes subfiles after compiling
	function lux_genlist(){
		info "Compiling file lists..."
		#touch "$LUX_RES/js/js_list.js"
		lux_listfile "js_list" "res/js" "js"
		lux_listfile "css_list" "res/css" "css"
		lux_listfile "html_list" "test" "html"
		lux_make_js
	}

	function lux_js_str(){
		data+=""
		data="$(cat <<-EOF
			//// lux generated javascript file $(date)
			const LUX_VERSION="$script_vers"
			const LUX_BUILD="$script_build"
			const LUX_BASIS="$opt_basis"
			const LUX_THEME="archxray"
			const LUX_TIMESTAMP="$(date +%s)"

			////\n
		EOF
		)";
		echo "$data"
	}


	function lux_make_js(){
		info "Generating lux-meta.js file!"
		path="$LUX_RES/js"
		src="${1:-$LUX_META_JS}"
		js_str="$(lux_js_str)"
		echo -e "$js_str" > ${src}
		cat ${path}/js_list.js ${path}/css_list.js ${path}/html_list.js  >> ${src}
		rm ${path}/*list.js
	}


	function lux_rc_str(){
		data+=""
		data="$(cat <<-EOF
			#!/usr/bin/bash
			${line}
			### lux generated config file $(date)

			export LUX_HOME="$LUX_HOME"
			export LUX_DEV_BIN="$LUX_DEV_BIN"
			export LUX_BIN="$LUX_BIN"
			export LUX_RC="$LUX_RC"
			export LUX_INST=0
			export LUX_USER_CONF="$LUX_USER_CONF"
			export LUX_SEARCH_PATH="$LUX_SEARCH_PATH"
			export LUX_CLI="$LUX_CLI"
			export LUX_DEV="$LUX_DEV"
			export LUX_CSS="$LUX_CSS"
			export LUX_WWW="$LUX_WWW"
			__repo_list=(${__repo_list[*]})
			__alias_list=(${__alias_list[*]})

			if [ -n "\$BASH_USR_BIN" ]; then
				[[ ! "\$PATH" =~ "\$BASH_USR_BIN" ]]  && export PATH=\$PATH:\$BASH_USR_BIN;
			fi

			if [ -n "\$LUX_BIN" ]; then
				[[ ! "\$PATH" =~ "\$LUX_BIN" ]] && export PATH=\$PATH:\$LUX_BIN;
			else
				if [ -n "\$LUX_DEV_BIN" ]; then
					[[ ! "\$PATH" =~ "\$LUX_DEV_BIN" ]] && export PATH=\$PATH:\$LUX_DEV_BIN;
				fi
			fi

			alias luxcd="cd \$LUX_HOME; ls -la; [ -t 1 ] && printf \"\n${blue}${lambda}Lux directory.${x}\n\"||:"
			${line}
		EOF
		)";
		echo "$data"
	}



	function lux_make_rc(){
		local show src rc_str
		info "Saving .luxrc file..."
		src="${LUX_RC}"
		rc_str="$(lux_rc_str)"
		echo "$rc_str" > ${src}
		[ -n "$1" ] && lux_dump_rc || :
		#clear any error related to this missing
		unstat STATE_LUX_RC_FILE #kind of wantt his in the inc-checkup. not sure
		[ -f "${src}" ] && return 0 || return 1;
	}

	function lux_dump_rc(){
		if [ -f "$LUX_RC" ]; then
			echo $line${nl}
			cat "$LUX_RC"
		else
			__warn "Lux RC doesnt exist."
		fi
	}

	function lux_load_rc(){
		[ -f "$LUX_RC" ] && info "Loading .luxrc file..." && source $LUX_RC && unstat STATE_LUX_RC_FILE || wtrace "Cant load Lux RC. Missing ($LUX_RC). "
	}


	function lux_reset_rc(){
		[ -f "$LUX_RC" ] && rm "$LUX_RC"
	}