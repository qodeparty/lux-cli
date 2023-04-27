#!/usr/bin/env bash


function lux_make_www(){
	opt_debug=0;
	case $1 in
		push) shift; lux_copy_www; lux_push_www "$1";;
		*)    lux_copy_www "$1";;
	esac
}


function lux_make_cli(){
	require_entry "Cant compile lux from compiled lux! hehe nice try though ($script_entry)"
	opt_debug=0;
	make_cli_dist "$1" "nocomments"
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
	require_entry "Cant publish lux from compiled lux! the universe will collapse! ($script_entry)"

	#need some checks here
	if [ -n "$LUX_DEV_BIN" ] && [ -n "$LUX_INSTALL_DIR" ]; then

		LUX_INSTALL_BIN="$LUX_INSTALL_DIR/lux"

		this_exec="$LUX_DEV_BIN/luxbin"
		this_dist="$ROOT_DIR/dist/lux"

		[ -f "$LUX_INSTALL_BIN" ] && cp "$LUX_INSTALL_BIN" "${LUX_INSTALL_BIN}.bak" || :
		cp "$this_dist" "$LUX_INSTALL_BIN"
		info "Publishing dist to $LUX_INSTALL_BIN"
		echo "$this_dist || $LUX_INSTALL_DIR || $LUX_INSTALL_BIN"

	else
		: #error
		error "Failed publishing! Lux not installed yet ($LUX_INST)"
	fi
}

function lux_publish_lux(){
	deploy_dist_home
}
