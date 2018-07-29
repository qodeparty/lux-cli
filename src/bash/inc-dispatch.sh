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


		for call in "$@"; do
			shift
			if [ $skip -eq 0 ]; then
				skip=1; continue
			fi
			case $call in
				check)  lux_checkup;    ret=$?;;
				link)   profile_link;   ret=$?;;
				unlink) profile_unlink; ret=$?;;
				rc*)    lux_dump_rc;    ret=$?;;
				mrc*)   lux_make_rc 1;  ret=$?;;
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

