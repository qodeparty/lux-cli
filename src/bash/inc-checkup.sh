#!/usr/bin/env bash

	status_err=()
	err_vals=()
	status_pass=()
	pass_vals=()

#-------------------------------------------------------------------------------
# STAT UTILS
#-------------------------------------------------------------------------------

function is_error(){
	res=$(in_array "$1" "${status_err[@]}");ret=$?
	return $ret
}

function unstat(){
	local val="-$1"; shift;
	local list=(${status_err[@]})
	wtrace "Unsetting status [$val]"
	val=$(upd_array "$val" "${list[@]}")
	status_err=($val)

	# opt_dump_col="$red2"
	# dump "${status_err[@]}"
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

	# if [ $opt_silly -eq 0 ]; then
	# 	opt_dump_col="$red2"
	# 	dump "${status_err[@]}"

	# 	opt_dump_col="$purple"
	# 	dump "${err_vals[@]}"


	# 	opt_dump_col="$blue"
	# 	dump "${status_pass[@]}"

	# 	opt_dump_col="$cyan"
	# 	dump "${pass_vals[@]}"
	# fi
}



function check_all(){

	#[ -z "$BIN_DIR" ] && status+=( ERR_DBIN_UNDEF )  || status_pass+=( DBIN_DEF )
	status_err=()
	err_vals=()

	status_pass=()
	pass_vals=()


	assert_defined  BIN_DIR        STATE_DBIN_DEF       ;
	assert_inpath   BIN_DIR			   STATE_DBIN_PATH			;


	assert_defined  BASH_PROFILE   STATE_BASH_PROF_DEF  ;
	assert_defined  BASH_RC        STATE_BASH_RC_DEF    ;



	assert_defined  LUX_RC         STATE_LUX_RC_DEF     ;
	assert_file     LUX_RC         STATE_LUX_RC_FILE    ;

	assert_defined  LUX_BUILD      STATE_LUX_BUILD_DEF  ;
	assert_defined  LUX_DIST   	   STATE_LUX_DIST_DEF   ;

	assert_defined  LUX_SEARCH_PATH  STATE_LUX_SRC_DEF  ;
	# ERR_LUX_RCLINK_MISSING
	assert_defined  LUX_HOME  		 STATE_LUX_HOME_DEF   ;
	assert_defined  LUX_CLI        STATE_LUX_CLI_DEF    ;

	assert_defined  BASH_USR_BIN    STATE_BASH_UBIN_DEF ;
	assert_inpath   BASH_USR_BIN    STATE_BASH_UBIN_PATH;
	assert_dir      BASH_USR_BIN    STATE_BASH_UBIN_DIR ;

	assert_defined  LUX_INSTALL_DIR  STATE_LUX_INST_DEF ;
	assert_inpath   LUX_INSTALL_DIR  STATE_LUX_INST_PATH;

	assert_writable LUX_INSTALL_DIR STATE_LUX_INST_WRITE;
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
	[ $res -eq 0 ] && ptrace "$st - Assetion Passed - [$w$this$x]" ||:
	[ $res -eq 1 ] && ftrace "$st - Assetion Failed " ||:
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
	if [ -n "$this" ]; then
	 [ ! -d "$this" ] && ret=1 || ret=0;
	else
		ret=1
	fi
	record_assertion $ret "$1" "$2" true
	#silly "DIR check ($1)=> $this [$ret]"
	return $ret
}

function assert_inpath(){
	local ret this; this=${!1};
	if [ -n "$this" ]; then
	 [[ ! "$PATH" =~ "$this" ]] && ret=1 || ret=0;
	else
		ret=1
	fi
	record_assertion $ret "$1" "$2" true
	#silly "PATH check ($1)=> $this [$ret]"
	return $ret
}

function assert_writable(){
	local ret this; this=${!1};
	if [ -n "$this" ]; then
	 [ -w "$this" ] && ret=1 || ret=0;
	else
		ret=1
	fi
	record_assertion $ret "$1" "$2" true
	#silly "WRITE check ($1)=> $this [$ret]"
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
				check_rc_repos "$LUX_HOME";ret=$?
				[ $ret -eq 0 ] && unstat STATE_LUX_SRC_DEF || :
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
		[ -d "$LUX_HOME" ] && unstat STATE_LUX_HOME_DEF || :
		pass "Generated LUX Home $LUX_HOME"
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

	function lux_pre_config_set_binvars(){
		trace "Resolve STATE_BASH_UBIN_DEF-(Sub Dirs)"
		BASH_USR_BIN="$1"
		if [ -n "$BASH_USR_BIN" ]; then
			QODEPARTY_INSTALL_DIR="$BASH_USR_BIN/qodeparty"
			LUX_INSTALL_DIR="$QODEPARTY_INSTALL_DIR/lux"
		else
			: #printf "Lux home not defined $LUX_HOME \n"
		fi
		pass "Generated Bin User Vars $BASH_USR_BIN"
	}


	function lux_pre_config_bin_dir(){
		trace "Resolve STATE_BASH_UBIN_DEF"

		if is_error STATE_BASH_UBIN_DEF; then

			vars=( BASH_USR_BIN MY_BIN HOME_BIN USR_BIN QODE_BIN BIN)
			for this in ${vars[@]}; do
				info "TRY $this => ${!this}"
				if [ -n "${!this}" ]; then
				  BASH_USR_BIN="${!this}"
				  break;
				fi
			done

			#prompt or create bin
			if [ -z "$BASH_USR_BIN" ]; then
				res=$(prompt_path "Cant find a default BIN directory var. What home path to use (ex:\$HOME/bin) " "Set your home bin to")
				BASH_USR_BIN="$res"
				lux_pre_config_set_binvars "$BASH_USR_BIN"
			fi

			unstat STATE_BASH_UBIN_DEF

		else
			ptrace "found BASH_USR_BIN ($BASH_USR_BIN)"
		fi


		trace "Resolve STATE_BASH_UBIN_PATH"
		if is_error STATE_BASH_UBIN_PATH; then
			ptrace "PATH missing home bin, create rc file or set env var"
		else
			ptrace "# Not implemented (STATE_BASH_UBIN_PATH)"
		fi

		trace "Resolve STATE_BASH_UBIN_DIR"
		if is_error STATE_BASH_UBIN_DIR; then
			[ ! -d "$BASH_USR_BIN" ] && mkdir -P "$BASH_USR_BIN" || :
			[ -d "$BASH_USR_BIN" ] && unstat STATE_BASH_UBIN_DIR || :
		else
			ptrace "# Not implemented (STATE_BASH_UBIN_DIR)"
		fi

	}




	function lux_pre_install(){
		trace "Resolve STATE_LUX_INST_DEF"
		if is_error STATE_LUX_INST_DEF; then
			ftrace "#repair (STATE_LUX_INST_DEF) not implemented"
		else
			ptrace "#"
		fi

		trace "Resolve STATE_LUX_INST_PATH"
		if is_error STATE_LUX_INST_PATH; then
			ftrace "#repair (STATE_LUX_INST_PATH) not implemented"
		else
			ptrace "#"
		fi

		trace "Resolve STATE_LUX_INST_WRITE"
		if is_error STATE_LUX_INST_WRITE; then
			ftrace "#repair (STATE_LUX_INST_WRITE) not implemented"
		else
			ptrace "#"
		fi

	}