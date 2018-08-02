#!/usr/bin/env bash

function lux_make_cli(){
	if [[ "$script_entry" =~ "luxbin" ]]; then
		opt_debug=0;
		make_cli_dist "$1" "nocomments"
	else
		error "Cant compile lux from compiled lux! hehe nice try though ($script_entry)"
	fi
}




function lux_search_files(){
	#TODO:PWD should be LUX_HOME
	IFS=
	flags="-HiREl"
	case $1 in
		files) shift; res=$(grep -HiREl --color=always "$1" .);;
		html) shift; res=$(grep -HiRE --include=\*.html --color=always "$1" .);;
		styl) shift; res=$(grep -HiRE --include=\*.styl --color=always "$1" .);;
		*) res=$(grep -HiREn --color=always "$1" .);;
	esac
	#query=`find $LUX_HOME/src -type f \( -name "*.styl" -o -name "*.css*" -o -name "*.js*" \) \;`
	#res=$(grep ${flags} --include= --color=always "$1" .)
	echo "$res"
}



function lux_publish_dist(){
	#need some checks here
	if [ -n "$LUX_DEV_BIN" ]; then

		LUX_INSTALL_BIN="$LUX_INSTALL_DIR/lux"

		this_exec="$LUX_DEV_BIN/luxbin"
		this_dist="$ROOT_DIR/dist/lux"

		[ -f "$LUX_INSTALL_BIN" ] && cp "$LUX_INSTALL_BIN" "${LUX_INSTALL_BIN}.bak" || :
		cp "$this_dist" "$LUX_INSTALL_BIN"
		info "dist:$this_dist bin:$LUX_INSTALL_BIN"

	else
		: #error
	fi
}