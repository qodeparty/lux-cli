#!/usr/bin/env bash

	status=()
	status_vals=()
	err_vals=()
	pass_vals=()

#-------------------------------------------------------------------------------
# STAT UTILS
#-------------------------------------------------------------------------------

function is_error(){
	res=$(fnmatch "$1" "${status[@]}");ret=$?
	return $ret
}

function unstat(){
	local val="-$1"; shift;
	local list=(${status[@]})
	val=$(upd_array "$val" "${list[@]}")
	status=($val)

	# opt_dump_col="$red2"
	# dump "${status[@]}"
}


#-------------------------------------------------------------------------------
# STATES
#-------------------------------------------------------------------------------

	function __env_repair(){
		trace "---env_repair"
		local arr=(${@})
		local len=${#arr[@]}
		if [ $len -gt 0 ]; then
			for i in ${!arr[@]}; do
				local this="${arr[$i]}"
				#check if function exists
				declare -F "${!this}" &> /dev/null
				ret=$?
				if [ $ret -eq 0 ]; then
					${!this};
					ret=$?
					sleep .02
					log "$(res $ret) Fixed ($this)?"
				else
				 log "$(res $ret) No FX for ($this)"
				fi
			done
		fi
		return 0
	}


#STATE_LUX_PRE_SETUP

function check_setup(){

	status=()
	status_vals=()
	err_vals=()
	pass_vals=()
	#check if this dir is in PATH
	#echo $BIN_DIR $THIS_DIR
	check_all

	opt_dump_col="$red2"
	dump "${status[@]}"

	opt_dump_col="$purple"
	dump "${err_vals[@]}"


	# opt_dump_col="$blue"
	# dump "${status_pass[@]}"

	# opt_dump_col="$cyan"
	# dump "${pass_vals[@]}"
}



function check_all(){

	#[ -z "$BIN_DIR" ] && status+=( ERR_DBIN_UNDEF )  || status_pass+=( DBIN_DEF )

	assert_defined  BIN_DIR        STATE_DBIN_DEF       ;
	assert_inpath   BIN_DIR			   STATE_DBIN_PATH			;
	assert_defined  LUX_CLI        STATE_LUX_CLI_DEF    ;

	assert_defined  BASH_PROFILE   STATE_BASH_PROF_DEF  ;
	assert_defined  BASH_RC        STATE_BASH_RC_DEF    ;

	# ERR_LUX_RCLINK_MISSING
	assert_defined  LUX_HOME  		 STATE_LUX_HOME_DEF   ;

	assert_defined  LUX_RC         STATE_LUX_RC_DEF     ;
	assert_file     LUX_RC         STATE_LUX_RC_FILE    ;

	assert_defined  LUX_BUILD      STATE_LUX_BUILD_DEF  ;
	assert_defined  LUX_DIST   	   STATE_LUX_DIST_DEF   ;

	assert_defined  LUX_SEARCH_PATH  STATE_LUX_SRC_DEF  ;


}

STATE_DBIN_UNDEF="lux_pre_config"

#-------------------------------------------------------------------------------
# ASSERTIONS
#-------------------------------------------------------------------------------

function record_assertion(){
	local ret val st this name
	res=$1;this=${!2}; st=$3; val="$4" name=$2;
	[ $res -eq 1 ] && status+=( "$st" ) && err_vals+=( "$name" )|| status_pass+=( "$st" ) && pass_vals+=( "$name:${4:-$this}" )
}

function assert_defined(){
	local ret this; this=${!1};
	[ -z "$this" ] && ret=1 || ret=0; record_assertion $ret "$1" "$2"
	info "$this $1 $2"
	return $ret
}


function assert_file(){
	local ret this; this=${!1};
	[ ! -f "$this" ] && ret=1 || ret=0; record_assertion $ret "$1" "$2" true
	return $ret
}


function assert_dir(){
	local ret this; this=${!1};
	[ ! -d "$this" ] && ret=1 || ret=0; record_assertion $ret "$1" "$2" true
	return $ret
}

function assert_inpath(){
	local ret this; this=${!1};
	[[ ! "$PATH" =~ "$this" ]] && ret=1 || ret=0; record_assertion $ret "$1" "$2" true
	return $ret
}


function assert_infile(){
	local this=$1
	:
}


#STATE_LUX_CONFIG_READY

#STATE_LUX_RC_CREATED

#STATE_LUX_RC_LINK

#STATE_LUX_USER_MODE

#STATE_LUX_USER_BUILD

#STATE_LUX_DEV_MODE

#STATE_LUX_DEV_DEPLOY

#STATE_LUX_UNINSTALL
