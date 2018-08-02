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

		for call in "$@"; do
			shift
			if [ $skip -eq 0 ]; then
				skip=1; continue
			fi
			case $call in
				mcli)
					if [[ "script_entry" =~ "luxbin" ]]; then
						opt_debug=0;
						make_cli_dist "$1" "nocomments"
						#info "$1 $2"
						shift;
					else
						error "Cant compile lux from compiled lux! hehe nice try though"
					fi
					break;
				;;
				fc) dev_fast_clean;;
				check)  opt_skip_input=0; lux_checkup; ret=$?;;
				repair) opt_skip_input=1; lux_repair; ret=$?;;
				link)   profile_link;    ret=$?;;
				unlink) profile_unlink;  ret=$?;;
				rc*)    lux_dump_rc;     ret=$?;;
				mrc*)   lux_make_rc 1;   ret=$?;;
				vars)   lux_vars;;
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

