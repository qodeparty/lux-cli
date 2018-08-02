#!/usr/bin/env bash
#-------------------------------------------------------------------------------
#===============================================================================


#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
	function dispatch(){
		#log_debug "[fx:$FUNCNAME] args:$#"
		local call ret
		skip=1

		# if [ -f "$LUX_USER_CONF" ]; then
		# 	add_var "local_conf:true" "local_conf_path:$LUX_USER_CONF"
		# fi
		lux_load_rc

		if [ -f "$LUX_USER_CONF" ]; then
			add_var "local_conf:true" "local_conf_path:$LUX_USER_CONF"
		fi

		lux_var_refresh

		for call in "$@"; do
			shift
			if [ $skip -eq 0 ]; then
				skip=1; continue
			fi
			case $call in
				mcli) lux_make_cli;	break;;
				fc) dev_fast_clean;;
				check)  opt_skip_input=0; lux_checkup; ret=$?;;
				repair) opt_skip_input=1; lux_repair; ret=$?;;
				dist)   lux_make_cli && lux_publish_dist;;
				link)   profile_link;    ret=$?;;
				unlink) profile_unlink;  ret=$?;;
				find)   lux_search_files; break;;
				rc*)    lux_dump_rc;     ret=$?;;
				mrc*)   lux_make_rc 1;   ret=$?;;
				home)   quiet 0; echo "$LUX_HOME";;
				bin)    quiet 0; echo "$LUX_BIN";;
				mods)   opt_verbose=0; info "=> ${LUX_MODS[*]}";;
				list)   lux_genlist	;;
				build|make)
					case $1 in
						each) shift; lux_build_each;;
						all)  shift; lux_build_all;;
						"")   shift; lux_build;;
						*)    lux_build_mod "$1";;
					esac
					break;
				;;
				vars)   lux_vars;;
				vers*)
					opt_quiet=0
					lux_version
					exit 0
				;;
				help)   lux_usage;;
				skip)   break;;
				\.)     break;;
				--*)    break;;
				*)
					if [ ! -z "$call" ]; then
						fatal "Invalid command" $call;
						lux_usage;  ret=1
					fi
				;;
			esac
		done

		return $ret
	}

