#!/usr/bin/env bash


	status_err=()
	err_vals=()
	status_pass=()
	pass_vals=()

	state_config=()  #STATE_CONFIG_READY
	state_install=() #STATE_INSTALL_READY
	state_build=()   #STATE_BUILD_READY
	state_publish=() #STATE_PUBLISH_READY

#-------------------------------------------------------------------------------
# STAT UTILS
#-------------------------------------------------------------------------------

	function is_error(){
		[ -z "$1" ] && return 1 || :
		res=$(in_array "$1" "${status_err[@]}");ret=$?
		#dtrace "iserror ($1) ($ret) [${status_err[*]}]?"
		return $ret
	}

	function unstat(){
		local val="-$1"; shift;
		local list=(${status_err[@]})
		wtrace "Unsetting status [$val]"
		val=$(upd_array "$val" "${list[@]}")
		status_err=($val)
	}

	function dump_results(){

		trace "$bline"

		opt_dump_col="$orange"
		dump "${status_err[@]}"

		#TODO:this is buggy (only works in first pass) cuz we dont have a way to remove the value too... yet
		#opt_dump_col="$purple"
		#dump "${err_vals[@]}"

		#trace "$bline"

		opt_dump_col="$blue"
		dump "${status_pass[@]}"

		#opt_dump_col="$cyan"
		#dump "${pass_vals[@]}"
	}


#-------------------------------------------------------------------------------
# STATE UTILS
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

#-------------------------------------------------------------------------------
# CHECKUPS
#-------------------------------------------------------------------------------



	function lux_checkup(){

		silly "Check Setup!"

		unset status_err
		unset err_vals

		unset status_pass
		unset pass_vals

		#opt_skip_input=0
		check_each_state 0

		lux_auto_repair

		#opt_skip_input=1
		check_each_state 1

	}

	function lux_repair(){

		#lux_auto_repair
		lux_checkup

		silly "Lux Repairing..."
		lux_pre_config

		lux_pre_config_cli
		lux_pre_config_bash_prof
		#lux_pre_config_search_path
		lux_pre_config_lux_home
		lux_pre_config_set_homevars
		#repair_home "$LUX_HOME" #only set with rc
		lux_pre_config_rc_file
		lux_pre_config_bin_dir
		lux_pre_install
		lux_want_install

		lux_make_rc

		#lux_repair_install_link

		#check_each_state 1
		len=${#status_err[@]}

		if [ $len -gt 0 ]; then
			error "Completed with errors"
			dump_results
		else
			info "WELP! ($len)s"
		fi

	}


	function lux_auto_repair(){
		lux_pre_config_cli
		lux_pre_config_bash_prof
		#lux_pre_config_search_path

		lux_pre_config_lux_home
		lux_pre_config_set_homevars
		#repair_home "$LUX_HOME" #only set with rc
		lux_pre_config_rc_file
		lux_pre_config_bin_dir
		lux_pre_install
		lux_want_install
	}



	function check_each_state(){

		test_only="${1:-1}"

		[ $test_only -eq 0 ] && dtrace "TEST ONLY"

		#[ -z "$BIN_DIR" ] && status+=( ERR_DBIN_UNDEF )  || status_pass+=( DBIN_DEF )
		status_err=()
		err_vals=()

		status_pass=()
		pass_vals=()

		assert_defined  LUX_DEV_BIN    STATE_LUX_DBIN_DEF   ;
		assert_inpath   LUX_DEV_BIN		 STATE_LUX_DBIN_PATH	;

		assert_defined  BASH_PROFILE   STATE_BASH_PROF_DEF  ;
		assert_defined  BASH_RC        STATE_BASH_RC_DEF    ;


		assert_defined  LUX_RC         STATE_LUX_RC_DEF     ;
		assert_file     LUX_RC         STATE_LUX_RC_FILE    ;

		assert_defined  LUX_HOME  		 STATE_LUX_HOME_DEF   ;
		assert_dir      LUX_HOME  		 STATE_LUX_HOME_DIR   ;

		assert_defined  LUX_BUILD      STATE_LUX_BUILD_DEF  ;
		assert_defined  LUX_DIST   	   STATE_LUX_DIST_DEF   ;

		assert_defined  LUX_SEARCH_PATH  STATE_LUX_SRC_DEF  ;

		assert_defined  LUX_CLI         STATE_LUX_CLI_DEF    ;
		assert_dir      LUX_CLI         STATE_LUX_CLI_DIR    ;

		assert_defined  BASH_USR_BIN    STATE_BASH_UBIN_DEF ;
		assert_inpath   BASH_USR_BIN    STATE_BASH_UBIN_PATH;
		assert_dir      BASH_USR_BIN    STATE_BASH_UBIN_DIR ;

		assert_defined  LUX_INSTALL_DIR  STATE_LUX_INST_DEF ;
		assert_writable LUX_INSTALL_DIR  STATE_LUX_INST_WRITE;

		assert_defined  LUX_INSTALL_BIN  STATE_LUX_IBIN_DEF;
		assert_file 		LUX_INSTALL_BIN  STATE_LUX_IBIN_FILE;

		#needs LUX_DEV_BIN
		#note dist var isnt necessary because its derived from ubin
		#assert_file 		LUX_INSTALL_DIST STATE_LUX_DIST_FILE; #LUX_CLI LUX_DEV_BIN

		assert_link      BASH_PROFILE STATE_BASH_PROF_LINK;

	}


#-------------------------------------------------------------------------------
# ASSERTIONS
#-------------------------------------------------------------------------------

	function assertion_type(){
		local code ret
		code="$1"
		ret="$2"
		case "$1" in
			*DEF*) this_atype="var"
				[ $ret -eq 0 ] && this_res="${blue}def$x";
				[ $ret -eq 1 ] && this_res="undef";
				;;
			*PATH*) this_atype='path'
				[ $ret -eq 0 ] && this_res="${blue}inpath$x";
				[ $ret -eq 1 ] && this_res="ninpath";
				;;
			*FILE*) this_atype='file'
				[ $ret -eq 0 ] && this_res="${blue}exists$x";
				[ $ret -eq 1 ] && this_res="dne";
				;;
			*LINK*) this_atype='link'
				[ $ret -eq 0 ] && this_res="${blue}linked$x";
				[ $ret -eq 1 ] && this_res="nlk";
				;;
			*DIR*) this_atype='dir'
				[ $ret -eq 0 ] && this_res="${blue}exists$x";
				[ $ret -eq 1 ] && this_res="dne";
				;;
			*WRITE*) this_atype='write'
				[ $ret -eq 0 ] && this_res="${blue}writable$x";
				[ $ret -eq 1 ] && this_res="nwa";
				;;
			*) this_atype='unk';;
		esac

	}

	function record_assertion(){
		local ret val st val name
		ret=$1;param=${!2}; st=$3; val="$4" name=$2;

		[ $ret -eq 1 ] && { status_err+=( "$st" ); err_vals+=( "$name" ); } ||
											{ status_pass+=( "$st" ); pass_vals+=( "$name:${val:-$param}" ); }


		# if [ $test_only -eq 1 ]; then
		# 	[ $res -eq 0 ] && __print "${pass}Passed$x | $name ${tab} | ${tab} $ltype | $grey$this$x "    ||:
		# 	[ $res -eq 1 ] && __print "${fail}Failed$x | $name ${tab} | ${tab} $ltype | $grey2${name}$x " ||:
		# fi
		assertion_type $st $ret

		if [ $test_only -eq 1 ]; then

			[[ ! "$this_atype" =~ "var" ]]  && param="$this_res";
			[ $ret -eq 1 ] && param="$grey2--$x" || :
			[ $ret -eq 1 ] && this_stat="${fail} Fail$x" || this_stat="${pass} Pass$x"
			#| %-20s  "$st"
			printf -v "out" "| %-5s | %-5s | \$%-20s | %-60s $x$eol" "${this_stat}" "$this_atype" "$name" "$param"
			__print "$out"
		fi

	}

	function assert_defined(){
		local ret this; this=${!1};
		[ -z "$this" ] && ret=1 || ret=0; record_assertion $ret "$1" "$2"
		#dtrace "VAR check ($1)=> $this [$ret]"
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
			[ ! -w "$this" ] && ret=1 || ret=0;
		else
			ret=1
		fi
		record_assertion $ret "$1" "$2" truealias
		#dtrace "WRITE check ($1)=> $this [$ret]"
		return $ret
	}

	function assert_link(){
		local this=$1
		:
	}

	function assert_infile(){
		local this=$1
		:
	}

	function assert_ready(){
		local this=$1
		:
	}


#-------------------------------------------------------------------------------
# PROMPTS
#-------------------------------------------------------------------------------


	function repair_home(){
		LUX_HOME="$1"
		lux_pre_config_set_homevars
		[ -d "$LUX_HOME" ] && unstat STATE_LUX_HOME_DEF || :
		dtrace "Repaired LUX Home ($LUX_HOME)"
	}

	function repair_binvars(){
		trace "try Resolve STATE_BASH_UBIN_DEF-(Sub Dirs)"
		BASH_USR_BIN="$1"
		if [ -n "$BASH_USR_BIN" ]; then
			QODEPARTY_INSTALL_DIR="$BASH_USR_BIN/qodeparty"
			LUX_INSTALL_DIR="$QODEPARTY_INSTALL_DIR/lux"
			LUX_INSTALL_BIN="$LUX_INSTALL_DIR/lux"
			dtrace "Repair BINVARS unsets"
			[ -n "$LUX_INSTALL_DIR" ] && [ -d "$LUX_INSTALL_DIR" ] && unstat STATE_LUX_INST_DEF || :
			[ -n "$LUX_INSTALL_BIN" ] && [ -f "$LUX_INSTALL_BIN" ] && { unstat STATE_LUX_IBIN_DEF; unstat STATE_LUX_IBIN_FILE; } || :

		else
			: #printf "Lux home not defined $LUX_HOME \n"
		fi
		#dtrace "Repaired Bin Vars ($BASH_USR_BIN)"
	}

	function repair_install_dir(){
		:
	}

	function prompt_home(){
		if confirm "${lambda} ${blue}LUX_HOME$x is not set. Set the location manually (y/n)"; then
			res=$(prompt_path "Where is \${blue}LUX_HOME\$x directory on \$blue\$HOSTNAME\$x" "Is this correct" "$LUX_HOME");ret=$?
			LUX_HOME="$res"
			#[ $ret -eq 1 ] && return 1;
		else
			:
		fi
	}


	function prompt_repos(){
		local res ret next
		if [ -z "$LUX_SEARCH_PATH" ]; then
			wtrace "Lux search path missing${x}"

			if confirm "${x}Do you want to run repo finder (y/n)"; then
				#reset_user_data
				  sleep 0.2
					#clear
					res=$(prompt_path "Where should Lux search for Repos ex: \$blue\$default\$x" "Search for Lux repos in" "$HOME/src");ret=$?
					[ $ret -eq 1 ] && return 1;

					lux_need_align_repos;ret=$?

					if [ $ret -eq 0 ]; then
							if [ -d "$res" ]; then
								pass "Found search path $res" #"$ret"
								lux_find_repos "$res"; ret=$?

								[ $ret -eq 0 ] && LUX_SEARCH_PATH="$res" || :

								dtrace "Search path was $res $LUX_SEARCH_PATH ($ret)"
								lux_align_repos;

							else
							  fatal "Unable to find search path -> $res"
							fi
					fi

				return 0
			else
				return 1
			fi

			#TODO:modularize this repeated code
			lux_need_align_repos;ret=$?
			res="$LUX_SEARCH_PATH"
			if [ $ret -eq 0 ]; then
					if [ -d "$res" ]; then
						pass "Found search path $res" #"$ret"
						lux_find_repos "$res"; ret=$?
						[ $ret -eq 0 ] && LUX_SEARCH_PATH="$res" || :
						#silly "Search path was $res $LUX_SEARCH_PATH"
						lux_align_repos;

					else
					  fatal "Unable to find search path -> $res"
					fi
			fi

		fi
		return 0
	}


#-------------------------------------------------------------------------------
# REPAIR
#-------------------------------------------------------------------------------


	function lux_pre_config(){
		trace "try Resolve STATE_DBIN_PATH"
		if is_error STATE_DBIN_PATH; then
			warn "Please run config again!"
			#fatal requires user step
		else
			: #pptrace "found DEV_BIN"
		fi
	}


	function lux_pre_config_cli(){
		trace "try Resolve STATE_LUX_CLI_DEF"
		if is_error STATE_LUX_CLI_DEF; then

			if [ -n "$LUX_CONFIG_HOME" ]; then
				LUX_CLI="$LUX_CONFIG_HOME"
				unstat STATE_LUX_CLI_DEF
			fi

		else
			: #pptrace "found CLI_DEF ($LUX_CONFIG_HOME)"
			#fatal requires user step
		fi
	}

	#not really implemented yet
	function lux_pre_config_bash_prof(){
		trace "try Resolve STATE_BASH_PROF_DEF"
		if is_error STATE_BASH_PROF_DEF; then
			warn "Prompt User for PROFILE or RC"
			#fatal requires user step
		else
			ptrace  "[SKIP]# Not implemented yet (STATE_BASH_PROF_DEF)"
		fi
	}

	function lux_pre_config_search_path(){
		trace "try Resolve STATE_LUX_SRC_DEF"
		if [ -z "$LUX_SEARCH_PATH" ]; then
			if [ $opt_skip_input -eq 1 ]; then
				#REQUIRES USER INPUT
				prompt_repos "$LUX_HOME";ret=$?

				[ $ret -eq 0 ] && unstat STATE_LUX_SRC_DEF || :
			else
				wtrace "No User Input for LUX_SEARCH_PATH"
				#RECORD USER INPUT NEED
			fi
		fi
	}

	function lux_pre_config_lux_home(){
		trace "try Resolve STATE_LUX_HOME_DEF"

		if is_error STATE_LUX_HOME_DEF; then

			if [ -n "$LUX_CSS" ]; then
				LUX_HOME="$LUX_CSS"
			else
				lux_pre_config_search_path
			fi

			if [ -d "$LUX_HOME" ]; then
				repair_home "$LUX_HOME"
			else
				wtrace "Cant find Lux Home"
				prompt_home
			  [ $opt_skip_input -eq 1 ] && lux_make_rc || :
			fi

			#fatal requires user step

			
		else
			: #dtrace "found LUX Home ($LUX_HOME)"
		fi

		trace "try Resolve STATE_LUX_HOME_DIR"
		if is_error STATE_LUX_HOME_DEF; then

			if [ -n "$LUX_HOME" ]; then
				: #in this case the dir doesnt exist but the var does oops
			else
				: #even the var doesnt exist here so um
			fi

		fi
	}



	function lux_pre_config_rc_file(){
		trace "try Resolve STATE_LUX_RC_FILE"
		if is_error STATE_LUX_RC_FILE; then
			warn "RC Files requires PROFILE"
			#Do you want to make RC FIle?
			#rc file without all needed params just make a dummy one
			[ $opt_skip_input -eq 1 ] && lux_make_rc || :
			#fatal requires user step
		else
			: #pptrace "found LUX_RC"
		fi
	}




	function lux_pre_config_set_homevars(){
		trace "try Resolve STATE_LUX_BUILD_DEF"
		trace "try Resolve STATE_LUX_DIST_DEF"
		if [ -n "$LUX_HOME" ]; then

			THIS_ROOT="$(dirname $LUX_HOME)"

			LUX_BUILD="$LUX_HOME/build"
			LUX_DIST="$LUX_HOME/dist"
			LUX_RES="$LUX_HOME/www/res"
			LUX_RBUILD="$LUX_RES/build"
			LUX_INST=1

			LUX_LIB="$LUX_HOME/src/lib"
			LUX_EXT="$LUX_LIB/plugin"
			LUX_DEFS="$LUX_LIB/defs"

			LUX_CORE="$LUX_HOME/src/styl/core"
			LUX_VARS="$LUX_HOME/src/styl/vars"
			LUX_UTIL="$LUX_HOME/src/styl/util"

			LUX_META_JS="$LUX_RES/js/lux-meta.js"

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



	function lux_pre_config_bin_dir(){
		trace "try Resolve STATE_BASH_UBIN_DEF"

		if is_error STATE_BASH_UBIN_DEF; then
				info "Error STATE UBIN"

				vars=( BASH_USR_BIN MY_BIN HOME_BIN USR_BIN QODE_BIN BIN)
				for this in ${vars[@]}; do
					: #dtrace "TRY $this => ${!this}" #devmode trace
					if [ -n "${!this}" ]; then
					  BASH_USR_BIN="${!this}"
					  repair_binvars "$BASH_USR_BIN"
					  break;
					fi
				done

				#prompt or create bin
				#if [ $opt_skip_input -eq 1 ]; then
				if [ -z "$BASH_USR_BIN" ]; then
					res=$(prompt_path "Cant find a default BIN directory var. What bin path to use (ex:\$HOME/bin) " "Set your home bin to")
					BASH_USR_BIN="$res"
					repair_binvars "$BASH_USR_BIN"
				fi

				unstat STATE_BASH_UBIN_DEF

		else
			: #ptrace "found BASH_USR_BIN ($BASH_USR_BIN) ??"
		fi


		trace "try Resolve STATE_BASH_UBIN_PATH"
		if is_error STATE_BASH_UBIN_PATH; then
			wtrace "PATH missing home bin, create rc file or set env var"
			#cant fix this in current subshell
			#once user restarts session it will load via rc
		else
			ptrace "[SKIP] # Not implemented (STATE_BASH_UBIN_PATH)"
		fi

		trace "try Resolve STATE_BASH_UBIN_DIR"
		if is_error STATE_BASH_UBIN_DIR; then
			[ ! -d "$BASH_USR_BIN" ] && mkdir -P "$BASH_USR_BIN" || :
			[ -d "$BASH_USR_BIN" ] && unstat STATE_BASH_UBIN_DIR || :
		else
			: #ptrace "# Not implemented (STATE_BASH_UBIN_DIR)"
		fi

	}



	function lux_pre_install(){
		trace "try Resolve STATE_LUX_INST_DEF"
		if is_error STATE_LUX_INST_DEF; then


			if [ -z "$LUX_INSTALL_BIN" ]; then
				#this isnt atomic
				if [  -n "$BASH_USR_BIN" ]; then
					repair_binvars "$BASH_USR_BIN"
				fi
			fi

			if [ -z "$QODEPARTY_INSTALL_DIR" ] || [ -z "$LUX_INSTALL_DIR" ]; then
				wtrace "Missing Dirs"
			fi

		else
			: #ptrace "#"
		fi

		trace "try Resolve STATE_LUX_INST_WRITE"
		if is_error STATE_LUX_INST_WRITE; then


			if [ $opt_skip_input -eq 1 ]; then
				if [ -n "$LUX_INSTALL_DIR" ]; then
					mkdir -p "$LUX_INSTALL_DIR"

					if [ ! -d "$LUX_INSTALL_DIR" ]; then
						wtrace "Cant write to or create bin install dir"
					else
						unstat STATE_LUX_INST_WRITE
					fi
				fi
			else
				: #skip input should we prompt?
			fi

		else
			: #ptrace "#"
		fi
	}


	function lux_want_dist(){
		:
	}


	function lux_want_install(){
		trace "try Resolve STATE_LUX_IBIN_DEF"
		if is_error STATE_LUX_IBIN_DEF; then

			if [ -z "$LUX_INSTALL_BIN" ]; then

				#this isnt atomic
				if [  -n "$BASH_USR_BIN" ]; then
					repair_binvars "$BASH_USR_BIN"
				fi

			fi


			if [ -n "$LUX_INSTALL_BIN" ]; then
				unstat STATE_LUX_IBIN_DEF;
			fi

		fi



		trace "try Resolve STATE_LUX_IBIN_FILE"

		if is_error STATE_LUX_IBIN_FILE; then
			if [ ! -f "$LUX_INSTALL_BIN" ]; then


				if [ -n "$LUX_DEV_BIN" ]; then
					this_exec="$LUX_DEV_BIN/luxbin"
					this_dist="$ROOT_DIR/dist/lux"
				fi


				if [ ! -f "$this_dist" ]; then
					wtrace "Distributable not found at $this_dist"
					if [ -n "$this_exec" ] && [ -f "$this_exec" ]; then


							if [[ "$script_entry" =~ "luxbin" ]]; then
								if [ $opt_skip_input -eq 1 ]; then
									opt_debug=0;
									make_cli_dist "$this_exec" "nocomments"
								else
									: #skip input -- prompt?
								fi
							else
								#probably already installed lol
								error "Cant compile lux from compiled lux! hehe nice try though! use <luxbin>"

							fi

					else
					 	error "Cant find luxbin executable! Probably deleted or not installed"
					 	#could prompt user but this is generally a fatal error
					fi

				fi


				#dist exists

				if [ -f "$this_dist" ]; then

					if [ $opt_skip_input -eq 1 ]; then
						#unstat STATE_LUX_DIST_FILE;
						#then just copy dist to bin
						[ -f "$LUX_INSTALL_BIN" ] && cp "$LUX_INSTALL_BIN" "${LUX_INSTALL_BIN}.bak" || :
						cp "$this_dist" "$LUX_INSTALL_BIN"
					else
						: #skip -- prompt?
					fi

				else
					warn "Unable to find dist file at $dist_file"
				fi

				if [ $opt_skip_input -eq 1 ]; then
					if [ ! -f "$LUX_INSTALL_BIN" ]; then
						#repair failed
						error "Repair Failed! Cannot build and install lux exec ($LUX_INSTALL_BIN)"
					else
						unstat STATE_LUX_IBIN_FILE;
						#unstat STATE_LUX_DIST_FILE; #dont need dist now
					fi
				fi

			fi
		else
			if [ -f "$LUX_INSTALL_BIN" ]; then
				dtrace "Already have LUX IBIN ($LUX_INSTALL_BIN)";
				unstat STATE_LUX_IBIN_FILE;
				#unstat STATE_LUX_DIST_FILE;
				dtrace "Final bin check!"
			fi
		fi
	}

