#!/usr/bin/env bash

	status_err=()
	err_vals=()
	status_pass=()
	pass_vals=()

#-------------------------------------------------------------------------------
# STAT UTILS
#-------------------------------------------------------------------------------

function is_error(){
	res=$(fnmatch "$1" "${status_err[@]}");ret=$?
	return $ret
}

function unstat(){
	local val="-$1"; shift;
	local list=(${status_err[@]})
	val=$(upd_array "$val" "${list[@]}")
	status_err=($val)

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

	silly "Check Setup!"

	unset status_err
	unset err_vals

	unset status_pass
	unset pass_vals

	#check if this dir is in PATH
	#echo $BIN_DIR $THIS_DIR
	check_all

	if [ $opt_silly -eq 0 ]; then
		opt_dump_col="$red2"
		dump "${status_err[@]}"

		opt_dump_col="$purple"
		dump "${err_vals[@]}"


		opt_dump_col="$blue"
		dump "${status_pass[@]}"

		opt_dump_col="$cyan"
		dump "${pass_vals[@]}"
	fi
}



function check_all(){

	#[ -z "$BIN_DIR" ] && status+=( ERR_DBIN_UNDEF )  || status_pass+=( DBIN_DEF )
	status_err=()
	err_vals=()

	status_pass=()
	pass_vals=()


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

	#LUX_CLI_INSALL_PATH


}

STATE_DBIN_UNDEF="lux_pre_config"

#-------------------------------------------------------------------------------
# ASSERTIONS
#-------------------------------------------------------------------------------

function record_assertion(){
	local ret val st this name
	res=$1;this=${!2}; st=$3; val="$4" name=$2;
	[ $res -eq 1 ] && status_err+=( "$st" ) && err_vals+=( "$name" )|| status_pass+=( "$st" ) && pass_vals+=( "$name:${4:-$this}" )
}

function assert_defined(){
	local ret this; this=${!1};
	[ -z "$this" ] && ret=1 || ret=0; record_assertion $ret "$1" "$2"
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

#-------------------------------------------------------------------------------
# REPAIR
#-------------------------------------------------------------------------------


	function lux_pre_config(){
		trace "Resolve STATE_DBIN_PATH"
		if is_error STATE_DBIN_PATH; then
			warn "Please run config again!"
			#fatal requires user step
		else
			ptrace "found DEV_BIN"
		fi
	}


	function lux_pre_config_cli(){
		trace "Resolve STATE_LUX_CLI_DEF"
		if is_error STATE_LUX_CLI_DEF; then

			if [ -n "$LUX_CONFIG_HOME" ]; then
				LUX_CLI="$LUX_CONFIG_HOME"
				unstat STATE_LUX_CLI_DEF
			fi

		else
			ptrace "found CLI_DEF"
			#fatal requires user step
		fi
	}

	function lux_pre_config_bash_prof(){
		trace "Resolve STATE_BASH_PROF_DEF"
		if is_error STATE_BASH_PROF_DEF; then
			warn "Prompt User for PROFILE or RC"
			#fatal requires user step
		else
			ptrace "found BASH_PROFILE"
		fi
	}

	function lux_pre_config_lux_home(){
		trace "Resolve STATE_LUX_HOME_DEF"
		if is_error STATE_LUX_HOME_DEF; then

			if [ -n "$LUX_CSS" ]; then
				LUX_HOME="$LUX_CSS"
				lux_pre_config_set_home "$LUX_HOME"
			else
				check_rc_repos "$LUX_HOME"
			fi
			#fatal requires user step
		else
			ptrace "found LUX Home"
		fi
	}

	function lux_pre_config_rc_file(){
		trace "Resolve STATE_LUX_RC_FILE"
		if is_error STATE_LUX_RC_FILE; then
			warn "RC Files requires PROFILE"
			#Do you want to make RC FIle?
			lux_make_rc 1
			#fatal requires user step
		else
			ptrace "found LUX_RC"
		fi
	}


	function lux_pre_config_set_home(){
		LUX_HOME="$1"
		lux_pre_config_set_homevars
		lux_make_rc #need to update it
		unstat STATE_LUX_HOME_DEF
		success "Generated LUX Home $LUX_HOME"
	}


	function lux_pre_config_set_homevars(){
		trace "Resolve STATE_LUX_BUILD_DEF"
		trace "Resolve STATE_LUX_DIST_DEF"
		if [ -n "$LUX_HOME" ]; then

			THIS_ROOT="$(dirname $LUX_HOME)"

			LUX_BUILD="$LUX_HOME/build"
			LUX_DIST="$LUX_HOME/dist"
			LUX_RES="$LUX_HOME/www/res"
			LUX_RBUILD="$LUX_RES/build"
			LUX_INST=1

			LUX_LIB="$LUX_HOME/src/lib"
			LUX_EXT="$LUX_LIB/ext"
			LUX_DEFS="$LUX_LIB/defs"

			LUX_CORE="$LUX_HOME/src/styl/lux"
			LUX_VARS="$LUX_HOME/src/styl/vars"
			LUX_UTIL="$LUX_HOME/src/styl/util"

			OPT_INCLUDE="--include $LUX_EXT --include $LUX_UTIL --include $LUX_VARS --include $LUX_CORE"
			OPT_IMPORT="--import $LUX_UTIL --import $LUX_VARS " #order matters
			OPT_USE="" #update with lux_var_refresh
			OPT_ALL="" #update with lux_var_refresh

			#------
			unstat STATE_LUX_BUILD_DEF
			unstat STATE_LUX_DIST_DEF
		else
			: #printf "Lux home not defined $LUX_HOME \n"
		fi

	}